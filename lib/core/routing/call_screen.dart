import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_application_2/core/services/socket_service.dart';

class CallScreen extends StatefulWidget {
  final String callerName;
  final String receiverId;
  final bool isIncoming;
  final String? callId;
  final SocketService socketService;
  final dynamic incomingCallData;

  const CallScreen({
    super.key,
    required this.callerName,
    required this.receiverId,
    required this.isIncoming,
    required this.socketService,
    this.callId,
    this.incomingCallData,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // ─── WebRTC ───────────────────────────────────────────────────────────────
  RTCPeerConnection? _peerConn;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // ─── State ────────────────────────────────────────────────────────────────
  bool _muted = false;
  bool _speakerOn = false;
  bool _connected = false;
  bool _isSettingUp = true;
  int _seconds = 0;
  Timer? _timer;
  String? _currentCallId;
  String _statusText = 'Connecting...';

  // ─── STUN/TURN Servers ────────────────────────────────────────────────────
  static const Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    _initRenderers().then((_) {
      _setupSocketListeners();
      if (!widget.isIncoming) {
        // ── CALLER: أنا بدأت المكالمة
        _setupPeerConnection().then((_) {
          _initiateCallFlow();
        });
      } else {
        // ── CALLEE: وصلني incomingCall → جهّز PeerConnection وانتظر الـ Offer
        _currentCallId = widget.callId ??
            widget.incomingCallData?['callId']?.toString();
        _setupPeerConnection().then((_) {
          setState(() => _statusText = 'Ringing...');
          print("✅ Callee ready — callId: $_currentCallId");
        });
      }
    });
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cleanupMedia();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _cleanupMedia() {
    _localStream?.getTracks().forEach((t) => t.stop());
    _remoteStream?.getTracks().forEach((t) => t.stop());
    _peerConn?.close();
    _localStream = null;
    _remoteStream = null;
    _peerConn = null;
  }

  // =========================================================================
  // 🔊 SETUP PEER CONNECTION
  // =========================================================================
  Future<void> _setupPeerConnection() async {
    _peerConn = await createPeerConnection(_iceServers);

    // ── ICE Candidate → ابعت للسيرفر
    _peerConn!.onIceCandidate = (candidate) {
      if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
        widget.socketService.sendIceCandidate(
          receiverId: widget.receiverId,
          candidate: {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        );
      }
    };

    // ── Remote Track وصل
    _peerConn!.onTrack = (event) {
      print("🎵 onTrack: ${event.track.kind}");
      if (event.streams.isNotEmpty && mounted) {
        setState(() {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
        });
      }
    };

    // ── Remote Stream (fallback)
    _peerConn!.onAddStream = (stream) {
      print("🎵 onAddStream");
      if (mounted) {
        setState(() {
          _remoteStream = stream;
          _remoteRenderer.srcObject = stream;
        });
      }
    };

    // ── Connection State
    _peerConn!.onConnectionState = (state) {
      print("🔗 WebRTC state: $state");
      if (!mounted) return;

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        setState(() {
          _connected = true;
          _isSettingUp = false;
          _statusText = 'Connected';
        });
        _startTimer();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        setState(() => _statusText = 'Connection failed');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        setState(() => _statusText = 'Disconnected');
      }
    };

    // ── اطلب الميكروفون
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
          'sampleRate': 48000,
        },
        'video': false,
      });

      _localRenderer.srcObject = _localStream;

      // أضف كل track للـ peer connection
      for (final track in _localStream!.getTracks()) {
        await _peerConn!.addTrack(track, _localStream!);
        print("🎤 Local track added: ${track.kind}");
      }

      setState(() => _isSettingUp = false);
    } catch (e) {
      print("❌ getUserMedia error: $e");
      setState(() => _statusText = 'Microphone access denied');
    }
  }

  // =========================================================================
  // 📞 CALL FLOW
  // =========================================================================

  /// CALLER: الخطوة 1 — أرسل initiateCall للسيرفر
  void _initiateCallFlow() {
    setState(() => _statusText = 'Calling...');
    widget.socketService.initiateCall(
      receiverId: widget.receiverId,
      callType: 'voice',
    );
    print("📞 initiateCall sent to: ${widget.receiverId}");
  }

  /// CALLER: الخطوة 2 — بعد callInitiated ابعت Offer
  Future<void> _sendOffer(String? callId) async {
    try {
      final offer = await _peerConn!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      await _peerConn!.setLocalDescription(offer);

      widget.socketService.sendWebrtcOffer(
        receiverId: widget.receiverId,
        offer: {'sdp': offer.sdp, 'type': offer.type},
        callId: callId,
      );

      setState(() => _statusText = 'Ringing...');
      print("🔗 webrtcOffer sent");
    } catch (e) {
      print("❌ sendOffer error: $e");
    }
  }

  /// CALLEE: الخطوة 3 — استقبل Offer وابعت Answer
  Future<void> _handleOffer(Map<String, dynamic> offer, String? callId) async {
    try {
      await _peerConn!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      final answer = await _peerConn!.createAnswer();
      await _peerConn!.setLocalDescription(answer);

      widget.socketService.sendWebrtcAnswer(
        receiverId: widget.receiverId,
        answer: {'sdp': answer.sdp, 'type': answer.type},
        callId: callId,
      );

      setState(() => _statusText = 'Connecting...');
      print("🔗 webrtcAnswer sent");
    } catch (e) {
      print("❌ handleOffer error: $e");
    }
  }

  /// CALLER: الخطوة 4 — استقبل Answer
  Future<void> _handleAnswer(Map<String, dynamic> answer) async {
    try {
      await _peerConn!.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );
      print("✅ Remote description set — call active!");
    } catch (e) {
      print("❌ handleAnswer error: $e");
    }
  }

  // =========================================================================
  // 🔌 SOCKET LISTENERS
  // =========================================================================
  void _setupSocketListeners() {
    final s = widget.socketService;

    // ── CALLER يسمع: السيرفر رد على initiateCall → ابعت Offer
    s.onCallInitiated((data) async {
      print("📞 callInitiated: $data");
      _currentCallId = data['callId']?.toString();
      await _sendOffer(_currentCallId);
    });

    // ── CALLEE يسمع: وصل Offer → ابعت Answer
    s.onWebrtcOffer((data) async {
      print("🔗 webrtcOffer received");
      _currentCallId ??= data['callId']?.toString();
      await _handleOffer(
        data['offer'] as Map<String, dynamic>,
        _currentCallId,
      );
    });

    // ── CALLER يسمع: وصل Answer → المكالمة شغالة
    s.onWebrtcAnswer((data) async {
      print("🔗 webrtcAnswer received");
      await _handleAnswer(data['answer'] as Map<String, dynamic>);
    });

    // ── الطرفين: ICE Candidates
    s.onIceCandidate((data) async {
      try {
        final c = data['candidate'];
        if (c == null) return;
        await _peerConn!.addCandidate(RTCIceCandidate(
          c['candidate']?.toString(),
          c['sdpMid']?.toString(),
          c['sdpMLineIndex'] as int?,
        ));
        print("✅ ICE candidate added");
      } catch (e) {
        print("⚠️ ICE error: $e");
      }
    });

    // ── المكالمة اترفضت
    s.onCallRejected((_) {
      if (mounted) {
        setState(() => _statusText = 'Call rejected');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });

    // ── المكالمة انتهت من الطرف الثاني
    s.onCallEnded((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  // =========================================================================
  // 🎛️ CONTROLS
  // =========================================================================
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  String get _duration {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _toggleMute() {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = _muted; // لو كان muted=true → enable التراك والعكس
    });
    setState(() => _muted = !_muted);
  }

  void _toggleSpeaker() async {
    try {
      await Helper.setSpeakerphoneOn(!_speakerOn);
      setState(() => _speakerOn = !_speakerOn);
    } catch (e) {
      print("Speaker toggle error: $e");
    }
  }

  void _endCall() {
    widget.socketService.endCall(
      receiverId: widget.receiverId,
      callId: _currentCallId,
      duration: _seconds,
    );
    Navigator.pop(context);
  }

  // =========================================================================
  // 🎨 UI
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D1B2A), Color(0xFF1A2F4A), Color(0xFF0D1B2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Hidden renderers — ضروري للصوت حتى لو مفيش فيديو
          Offstage(
            offstage: true,
            child: RTCVideoView(_localRenderer),
          ),
          Offstage(
            offstage: true,
            child: RTCVideoView(_remoteRenderer),
          ),

          // Main UI
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // ── Avatar
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withOpacity(.5),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person, size: 60, color: Colors.white),
                ),

                const SizedBox(height: 28),

                // ── Name
                Text(
                  widget.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Status / Timer
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _connected
                      ? Text(
                          _duration,
                          key: const ValueKey('timer'),
                          style: const TextStyle(
                            color: Color(0xFF69F0AE),
                            fontSize: 20,
                            fontFamily: 'monospace',
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          _statusText,
                          key: ValueKey(_statusText),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // ── Remote stream indicator
                AnimatedOpacity(
                  opacity: _remoteStream != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF69F0AE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Audio Active',
                        style: TextStyle(
                          color: Color(0xFF69F0AE),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── Sound Wave (when connected)
                if (_connected && !_muted)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      7,
                      (i) => _WaveBar(delay: i * 100),
                    ),
                  ),

                const Spacer(),

                // ── Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 60, left: 40, right: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mute
                      _ControlButton(
                        icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        label: _muted ? 'Unmute' : 'Mute',
                        backgroundColor: _muted
                            ? Colors.red.withOpacity(.3)
                            : Colors.white.withOpacity(.12),
                        iconColor: _muted ? Colors.red.shade300 : Colors.white,
                        onTap: _toggleMute,
                      ),

                      // End Call — center, bigger
                      GestureDetector(
                        onTap: _endCall,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(.5),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      // Speaker
                      _ControlButton(
                        icon: _speakerOn
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        label: _speakerOn ? 'Speaker' : 'Earpiece',
                        backgroundColor: _speakerOn
                            ? const Color(0xFF1976D2).withOpacity(.3)
                            : Colors.white.withOpacity(.12),
                        iconColor: _speakerOn
                            ? const Color(0xFF42A5F5)
                            : Colors.white,
                        onTap: _toggleSpeaker,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wave Bar Animation ───────────────────────────────────────────────────────
class _WaveBar extends StatefulWidget {
  final int delay;
  const _WaveBar({required this.delay});

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + widget.delay),
    )..repeat(reverse: true);
    _anim = Tween(begin: 6.0, end: 30.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 4,
        height: _anim.value,
        decoration: BoxDecoration(
          color: const Color(0xFF69F0AE),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// ─── Control Button ───────────────────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}