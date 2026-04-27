import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/services/socket_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

enum MessageType { text, image, audio, file }

late SocketService chatService;

class ChatMessage {
  final String text;
  final bool isMe;
  final MessageType type;
  final String time;
  final String? filePath;
  final String? fileName;
  final Duration? audioDuration;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.type,
    required this.time,
    this.filePath,
    this.fileName,
    this.audioDuration,
  });
}

class AppColors {
  static const blueColor = Color(0xFF1976D2);
  static const whiteColor = Colors.white;
  static const greyColor = Colors.grey;
  static const blackColor = Colors.black;
  static const backgroundColor = Color(0xFFF7FAFC);
  static const chatBubbleMe = Color(0xFF1976D2);
  static const chatBubbleOther = Colors.white;
}

String myId = "";

class ChatsPageDoctor extends StatefulWidget {
  final String doctorName;
  final String chatId;

  const ChatsPageDoctor({
    super.key,
    required this.doctorName,
    required this.chatId,
  });

  @override
  State<ChatsPageDoctor> createState() => _ChatsPageDoctorState();
}

class _ChatsPageDoctorState extends State<ChatsPageDoctor>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();

  String? _currentlyPlayingPath;
  bool _isPlayingAudio = false;
  bool _isRecording = false;
  int _recordSeconds = 0;

  String get receiverId => widget.chatId;
  final List<ChatMessage> messages = [];

  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? "";
    myId = prefs.getString("userId") ?? "";

    chatService = SocketService();
    chatService.connect(
      "https://medpal-production-e325.up.railway.app",
      "System $token",
    );

    Future.delayed(const Duration(seconds: 1), () {
      chatService.socket?.onAny((event, data) {
        debugPrint("📡 EVENT: $event");
      });
    });

    chatService.onMessage((msg) {
      if (!mounted) return;
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            text: msg['message'] ?? "",
            isMe: msg['senderId'] != receiverId,
            type: MessageType.text,
            time: _nowTime(),
          ),
        );
      });
    });

    chatService.onHistory((data) {
      if (!mounted) return;
      final List msgs = data['messages'] ?? [];
      setState(() {
        messages.clear();
        for (var m in msgs) {
          messages.insert(
            0,
            ChatMessage(
              text: m['message'] ?? "",
              isMe: m['senderId'] != receiverId,
              type: MessageType.text,
              time: _nowTime(),
            ),
          );
        }
      });
    });

    chatService.getHistory(receiverId);
  }

  @override
  void initState() {
    super.initState();
    _initSocket();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlayingAudio = state == PlayerState.playing;
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _currentlyPlayingPath = null;
        _isPlayingAudio = false;
      });
    });
  }

  @override
  void dispose() {
    chatService.disconnect();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _nowTime() => TimeOfDay.now().format(context);

  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;
    chatService.sendMessage(receiverId: receiverId, message: text);
    setState(() {
      messages.insert(0, ChatMessage(
        text: text, isMe: true, type: MessageType.text, time: _nowTime(),
      ));
    });
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    setState(() {
      messages.insert(0, ChatMessage(
        text: "", isMe: true, type: MessageType.image,
        time: _nowTime(), filePath: image.path,
      ));
    });
  }

  Future<void> _captureImageFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image == null) return;
    setState(() {
      messages.insert(0, ChatMessage(
        text: "", isMe: true, type: MessageType.image,
        time: _nowTime(), filePath: image.path,
      ));
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx'],
    );
    if (result == null) return;
    final file = result.files.first;
    setState(() {
      messages.insert(0, ChatMessage(
        text: file.name, isMe: true, type: MessageType.file,
        time: _nowTime(), filePath: file.path, fileName: file.name,
      ));
    });
  }

  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });

    // Timer
    _startRecordTimer();
  }

  void _startRecordTimer() async {
    while (_isRecording && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) {
        setState(() => _recordSeconds++);
      }
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });

    if (path != null) {
      setState(() {
        messages.insert(0, ChatMessage(
          text: "🎤 Voice Message",
          isMe: true,
          type: MessageType.audio,
          time: _nowTime(),
          filePath: path,
        ));
      });
    }
  }

  Future<void> _cancelRecording() async {
    await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  Future<void> _toggleAudioPlayback(String path) async {
    if (_currentlyPlayingPath == path && _isPlayingAudio) {
      await _audioPlayer.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(path));
      setState(() {
        _currentlyPlayingPath = path;
        _isPlayingAudio = true;
      });
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+201000000000');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  String _formatRecordTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (_, i) => _buildMessage(messages[i]),
            ),
          ),
          _isRecording
              ? _buildRecordingBar()
              : ChatInput(
                  onSend: _sendTextMessage,
                  onPickImage: _pickImageFromGallery,
                  onCamera: _captureImageFromCamera,
                  onPickFile: _pickFile,
                  onStartRecord: _startRecording,
                ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 44, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1565C0), const Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(.2),
              child: Text(
                widget.doctorName.isNotEmpty ? widget.doctorName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF69F0AE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Online',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _makePhoneCall,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _PulseIcon(),
          const SizedBox(width: 10),
          Text(
            '🎤 Recording... ${_formatRecordTime(_recordSeconds)}',
            style: const TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          // Cancel
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          // Send
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: msg.isMe ? 60 : 12,
          right: msg.isMe ? 12 : 60,
          top: 4, bottom: 4,
        ),
        padding: _getMessagePadding(msg),
        decoration: BoxDecoration(
          color: msg.isMe ? AppColors.chatBubbleMe : AppColors.chatBubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMessageContent(msg),
            const SizedBox(height: 4),
            Text(
              msg.time,
              style: TextStyle(
                fontSize: 10,
                color: msg.isMe ? Colors.white54 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _getMessagePadding(ChatMessage msg) {
    if (msg.type == MessageType.image) {
      return const EdgeInsets.all(4);
    }
    return const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
  }

  Widget _buildMessageContent(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.text:
        return Text(
          msg.text,
          style: TextStyle(
            color: msg.isMe ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.35,
          ),
        );

      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(msg.filePath!),
            width: 220,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
          ),
        );

      case MessageType.audio:
        final isThisPlaying = _currentlyPlayingPath == msg.filePath && _isPlayingAudio;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _toggleAudioPlayback(msg.filePath!),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: msg.isMe ? Colors.white.withOpacity(.25) : const Color(0xFF1976D2).withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: msg.isMe ? Colors.white : const Color(0xFF1976D2),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                    color: msg.isMe ? Colors.white38 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Voice Message',
                  style: TextStyle(
                    color: msg.isMe ? Colors.white70 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );

      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: msg.isMe ? Colors.white.withOpacity(.2) : const Color(0xFF1976D2).withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: msg.isMe ? Colors.white : const Color(0xFF1976D2),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                msg.fileName ?? msg.text,
                style: TextStyle(
                  color: msg.isMe ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }
}

// Pulsing record indicator
class _PulseIcon extends StatefulWidget {
  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.5, end: 1.0).animate(_ctrl);
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
        width: 12, height: 12,
        decoration: BoxDecoration(
          color: Color.fromRGBO(229, 57, 53, _anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Input Bar ──────────────────────────────────────────────────────────────────
class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onPickImage;
  final VoidCallback onCamera;
  final VoidCallback onPickFile;
  final VoidCallback onStartRecord;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.onPickImage,
    required this.onCamera,
    required this.onPickFile,
    required this.onStartRecord,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _showAttachMenu = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  void _send() {
    if (!_hasText) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Attach menu
        if (_showAttachMenu)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    setState(() => _showAttachMenu = false);
                    widget.onPickImage();
                  },
                ),
                _AttachOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    setState(() => _showAttachMenu = false);
                    widget.onCamera();
                  },
                ),
                _AttachOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'File',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    setState(() => _showAttachMenu = false);
                    widget.onPickFile();
                  },
                ),
              ],
            ),
          ),

        // Main input
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Attach button
              GestureDetector(
                onTap: () => setState(() => _showAttachMenu = !_showAttachMenu),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _showAttachMenu
                        ? const Color(0xFF1976D2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _showAttachMenu ? Icons.close_rounded : Icons.attach_file_rounded,
                    color: _showAttachMenu ? Colors.white : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Text field
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send or mic
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _hasText
                    ? GestureDetector(
                        key: const ValueKey('send'),
                        onTap: _send,
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    : GestureDetector(
                        key: const ValueKey('mic'),
                        onTap: widget.onStartRecord,
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.mic_rounded,
                            color: Colors.grey.shade600,
                            size: 22,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}