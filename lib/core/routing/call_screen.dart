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
  RTCPeerConnection? _peerConn;
  MediaStream? _localStream;
  bool _muted = false;
  bool _connected = false;
  int _seconds = 0;
  Timer? _timer;
  String? _currentCallId;

  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _setupListeners();
    if (!widget.isIncoming) {
      _startCall();
    } else {
      _acceptCall();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _localStream?.getTracks().forEach((t) => t.stop());
    _peerConn?.close();
    super.dispose();
  }

  // ── setup socket listeners ─────────────────────────────────────────────────
  void _setupListeners() {
    // السيرفر بيبعت callInitiated بعد initiateCall
    widget.socketService.socket?.on('callInitiated', (data) async {
      _currentCallId = data['callId']?.toString();
      print("📞 callInitiated — callId: $_currentCallId");
      await _sendOffer();
    });

    // الطرف الثاني بعت offer (لما أنا incoming)
    widget.socketService.socket?.on('webrtcOffer', (data) async {
      print("🔗 webrtcOffer وصل");
      _currentCallId = data['callId']?.toString();
      await _peerConn!.setRemoteDescription(
        RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
      );
      final answer = await _peerConn!.createAnswer();
      await _peerConn!.setLocalDescription(answer);
      widget.socketService.socket?.emit('webrtcAnswer', {
        'receiverId': widget.receiverId,
        'answer': {'sdp': answer.sdp, 'type': answer.type},
        'callId': _currentCallId,
      });
      print("🔗 webrtcAnswer أُرسل");
    });

    // الطرف الثاني قبل offer بتاعتي
    widget.socketService.socket?.on('webrtcAnswer', (data) async {
      print("🔗 webrtcAnswer وصل — المكالمة شغالة ✅");
      await _peerConn!.setRemoteDescription(
        RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
      );
    });

    // ICE candidates
    widget.socketService.socket?.on('iceCandidate', (data) async {
      try {
        final c = data['candidate'];
        await _peerConn!.addCandidate(RTCIceCandidate(
          c['candidate'],
          c['sdpMid'],
          c['sdpMLineIndex'],
        ));
      } catch (e) {
        print("ICE error: $e");
      }
    });

    // انتهت المكالمة من الطرف الثاني
    widget.socketService.socket?.on('callEnded', (data) {
      if (mounted) {
        print("📵 callEnded");
        Navigator.pop(context);
      }
    });

    // رُفضت
    widget.socketService.socket?.on('callRejected', (_) {
      if (mounted) {
        print("❌ callRejected");
        Navigator.pop(context);
      }
    });
  }

  // ── setup WebRTC peer connection ───────────────────────────────────────────
  Future<void> _setupPeerConnection() async {
    _peerConn = await createPeerConnection(_iceServers);

    // لما يوصل ICE candidate — ابعته للسيرفر
    _peerConn!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        widget.socketService.socket?.emit('iceCandidate', {
          'receiverId': widget.receiverId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };

    // لما يوصل stream من الطرف الثاني
    _peerConn!.onTrack = (event) {
      print("🎥 Remote track وصل");
      if (event.streams.isNotEmpty) {
        // الصوت بيشتغل تلقائياً مع flutter_webrtc
      }
    };

    _peerConn!.onConnectionState = (state) {
      print("WebRTC state: $state");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        if (mounted) {
          setState(() => _connected = true);
          _startTimer();
        }
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        if (mounted) Navigator.pop(context);
      }
    };

    // اطلب الميكروفون
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    // أضف الـ tracks للـ peer connection
    for (final track in _localStream!.getTracks()) {
      await _peerConn!.addTrack(track, _localStream!);
    }
  }

  // ── بدء مكالمة (caller) ────────────────────────────────────────────────────
  Future<void> _startCall() async {
    await _setupPeerConnection();
    // بعت initiateCall → السيرفر هيرد بـ callInitiated
    widget.socketService.socket?.emit('initiateCall', {
      'receiverId': widget.receiverId,
      'callType': 'voice',
    });
    print("📞 initiateCall أُرسل");
  }

  // ── قبول مكالمة واردة (callee) ────────────────────────────────────────────
  Future<void> _acceptCall() async {
    await _setupPeerConnection();
    _currentCallId = widget.callId ??
        widget.incomingCallData?['callId']?.toString();
    // السيرفر هيبعت webrtcOffer وهنرد عليه في _setupListeners
    print("✅ جاهز لاستقبال الـ offer");
  }

  // ── إرسال WebRTC Offer ────────────────────────────────────────────────────
  Future<void> _sendOffer() async {
    final offer = await _peerConn!.createOffer({'offerToReceiveAudio': true});
    await _peerConn!.setLocalDescription(offer);
    widget.socketService.socket?.emit('webrtcOffer', {
      'receiverId': widget.receiverId,
      'offer': {'sdp': offer.sdp, 'type': offer.type},
      'callId': _currentCallId,
    });
    print("🔗 webrtcOffer أُرسل");
  }

  void _startTimer() {
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
    _localStream?.getAudioTracks().forEach((t) {
      t.enabled = _muted; // toggle
    });
    setState(() => _muted = !_muted);
  }

  void _endCall() {
    widget.socketService.socket?.emit('endCall', {
      'receiverId': widget.receiverId,
      'callId': _currentCallId,
      'duration': _seconds,
    });
    Navigator.pop(context);
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withOpacity(.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: const Icon(Icons.person, size: 54, color: Colors.white),
            ),
            const SizedBox(height: 24),
            // Name
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _connected
                  ? Text(
                      _duration,
                      key: const ValueKey('timer'),
                      style: const TextStyle(
                        color: Color(0xFF69F0AE),
                        fontSize: 18,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    )
                  : const Text(
                      'Calling...',
                      key: ValueKey('calling'),
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            // Sound wave (when connected)
            if (_connected && !_muted)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => _WaveBar(delay: i * 200),
                ),
              ),
            const Spacer(),
            // Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CtrlBtn(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    label: _muted ? 'Unmute' : 'Mute',
                    color: _muted
                        ? Colors.red.withOpacity(.8)
                        : Colors.white.withOpacity(.15),
                    onTap: _toggleMute,
                  ),
                  // End call
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(.4),
                            blurRadius: 20,
                            spreadRadius: 3,
                          )
                        ],
                      ),
                      child: const Icon(Icons.call_end,
                          color: Colors.white, size: 30),
                    ),
                  ),
                  _CtrlBtn(
                    icon: Icons.volume_up,
                    label: 'Speaker',
                    color: Colors.white.withOpacity(.15),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
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
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = Tween(begin: 6.0, end: 28.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
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

// ─── Control Button ───────────────────────────────────────────────────────────
class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      );
}