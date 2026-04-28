import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/services/socket_service.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_detailsdoc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// ─── Enums ──────────────────────────────────────────────────────────────────
enum MessageType { text, image, audio, file }

late SocketService chatService;

// ─── Model ──────────────────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isMe;
  final MessageType type;
  final String time;
  final DateTime rawTime;
  final String? filePath;
  final String? fileUrl;
  final String? fileName;
  final Duration? audioDuration;
  final String? senderId;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.type,
    required this.time,
    required this.rawTime,
    this.filePath,
    this.fileUrl,
    this.fileName,
    this.audioDuration,
    this.senderId,
  });
}

// ─── Colors ─────────────────────────────────────────────────────────────────
class AppColors {
  static const blueColor = Color(0xFF1976D2);
  static const whiteColor = Colors.white;
  static const greyColor = Colors.grey;
  static const blackColor = Colors.black;
  static const backgroundColor = Color(0xFFF7FAFC);
  static const chatBubbleMe = Color(0xFF1976D2);
  static const chatBubbleOther = Colors.white;
}

String myUserId = "";

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  try {
    return DateTime.parse(value.toString()).toLocal();
  } catch (_) {
    return DateTime.now();
  }
}

String _formatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _dateLabel(DateTime dt) {
  final now = DateTime.now();
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day)
    return 'Today';
  final yesterday = now.subtract(const Duration(days: 1));
  if (dt.year == yesterday.year &&
      dt.month == yesterday.month &&
      dt.day == yesterday.day) return 'Yesterday';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ─── Parse message type ──────────────────────────────────────────────────────
// FIX: أكثر دقة في تحديد نوع الرسالة
MessageType _parseMessageType(dynamic val, {dynamic attachment}) {
  // لو في attachment يبقى صورة أو ملف
  if (attachment != null) {
    final attachType = (attachment['contentType'] ?? attachment['type'] ?? '').toString().toLowerCase();
    final attachName = (attachment['fileName'] ?? attachment['name'] ?? '').toString().toLowerCase();
    if (attachType.contains('image') || attachName.endsWith('.jpg') || attachName.endsWith('.jpeg') || attachName.endsWith('.png') || attachName.endsWith('.gif') || attachName.endsWith('.webp')) {
      return MessageType.image;
    }
    if (attachType.contains('audio') || attachName.endsWith('.m4a') || attachName.endsWith('.mp3') || attachName.endsWith('.aac') || attachName.endsWith('.wav')) {
      return MessageType.audio;
    }
    return MessageType.file;
  }

  final v = (val ?? '').toString().toLowerCase();
  if (v == 'image' || v.contains('image')) return MessageType.image;
  if (v == 'audio' || v.contains('audio')) return MessageType.audio;
  if (v == 'file' || v.contains('file') || v.contains('document')) return MessageType.file;
  return MessageType.text;
}

// ─── Upload helper ───────────────────────────────────────────────────────────
Future<String?> _uploadFileToServer(File file, String token) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://medpal-production-e325.up.railway.app/upload'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['url'] ??
          data['secure_url'] ??
          data['data']?['url'] ??
          data['data']?['secure_url'];
    }
    return null;
  } catch (e) {
    debugPrint('Upload error: $e');
    return null;
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class ChatsPageDoctor extends StatefulWidget {
  final String doctorName;
  final String chatId;
  final String? patientImageUrl;
  final String? patientProfileId;

  const ChatsPageDoctor({
    super.key,
    required this.doctorName,
    required this.chatId,
    this.patientImageUrl,
    this.patientProfileId,
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
  bool _isSendingMedia = false;

  String _accessToken = '';

  String get receiverId => widget.chatId;
  final List<ChatMessage> messages = [];

  // ── init socket ─────────────────────────────────────────────────────────────
  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("accessToken") ?? "";
    myUserId = prefs.getString("userId") ?? "";

    chatService = SocketService();
    chatService.connect(
      "https://medpal-production-e325.up.railway.app",
      "System $_accessToken",
    );

    // ── new message ──────────────────────────────────────────────────────────
    chatService.onMessage((msg) {
      if (!mounted) return;
      final dt = _parseDate(msg['createdAt']);
      final attachment = msg['attachment'];
      final msgType = _parseMessageType(
        msg['messageType'] ?? msg['type'],
        attachment: attachment,
      );

      final fileUrl = attachment?['secure_url'] ?? msg['fileUrl'] ?? msg['url'];
      final fileName = attachment?['fileName'] ?? msg['fileName'];

      setState(() {
        messages.insert(
          0,
          ChatMessage(
            text: msg['message'] ?? msg['text'] ?? "",
            isMe: msg['senderId'] != receiverId,
            type: msgType,
            time: _formatTime(dt),
            rawTime: dt,
            fileUrl: fileUrl?.toString(),
            fileName: fileName?.toString(),
            senderId: msg['senderId']?.toString(),
          ),
        );
      });
    });

    // ── history ──────────────────────────────────────────────────────────────
    chatService.onHistory((data) {
      if (!mounted) return;
      final List msgs = data['messages'] ?? [];
      setState(() {
        messages.clear();
        for (var m in msgs.reversed) {
          final dt = _parseDate(m['createdAt']);
          final attachment = m['attachment'];
          final msgType = _parseMessageType(
            m['messageType'] ?? m['type'],
            attachment: attachment,
          );

          final fileUrl =
              attachment?['secure_url'] ?? m['fileUrl'] ?? m['url'];
          final fileName = attachment?['fileName'] ?? m['fileName'];

          messages.add(ChatMessage(
            text: m['message'] ?? m['text'] ?? "",
            isMe: m['senderId'] != receiverId,
            type: msgType,
            time: _formatTime(dt),
            rawTime: dt,
            fileUrl: fileUrl?.toString(),
            fileName: fileName?.toString(),
            senderId: m['senderId']?.toString(),
          ));
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
      setState(() => _isPlayingAudio = state == PlayerState.playing);
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
    // chatService.disconnect();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ── SEND TEXT ────────────────────────────────────────────────────────────────
  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;
    chatService.sendMessage(receiverId: receiverId, message: text);
    final now = DateTime.now();
    setState(() {
      messages.insert(
          0,
          ChatMessage(
            text: text,
            isMe: true,
            type: MessageType.text,
            time: _formatTime(now),
            rawTime: now,
          ));
    });
  }

  // ── SEND MEDIA ───────────────────────────────────────────────────────────────
  Future<void> _sendMediaMessage({
    required File file,
    required MessageType type,
    String? fileName,
  }) async {
    setState(() => _isSendingMedia = true);

    // أضف الرسالة محلياً فوراً بدون URL
    final now = DateTime.now();
    final tempMsg = ChatMessage(
      text: fileName ?? _typeLabel(type),
      isMe: true,
      type: type,
      time: _formatTime(now),
      rawTime: now,
      filePath: file.path,
      fileName: fileName,
    );

    setState(() => messages.insert(0, tempMsg));

    try {
      // Upload file
      final url = await _uploadFileToServer(file, _accessToken);

      // Emit via socket
      chatService.socket?.emit('sendMessage', {
        'receiverId': receiverId,
        'message': fileName ?? _typeLabel(type),
        'type': type.name,
        if (url != null)
          'attachment': {
            'secure_url': url,
            'fileName': fileName ?? '',
            'contentType': _contentType(type),
          }
      });

      // Update message with URL
      if (url != null && mounted) {
        setState(() {
          final idx = messages.indexOf(tempMsg);
          if (idx != -1) {
            messages[idx] = ChatMessage(
              text: tempMsg.text,
              isMe: true,
              type: type,
              time: tempMsg.time,
              rawTime: tempMsg.rawTime,
              filePath: file.path,
              fileUrl: url,
              fileName: fileName,
            );
          }
        });
      }
    } catch (e) {
      _showSnack('Error sending media: $e');
    } finally {
      if (mounted) setState(() => _isSendingMedia = false);
    }
  }

  String _contentType(MessageType t) {
    switch (t) {
      case MessageType.image:
        return 'image/jpeg';
      case MessageType.audio:
        return 'audio/m4a';
      default:
        return 'application/octet-stream';
    }
  }

  String _typeLabel(MessageType t) {
    switch (t) {
      case MessageType.image:
        return '📷 Image';
      case MessageType.audio:
        return '🎤 Voice message';
      case MessageType.file:
        return '📎 File';
      default:
        return '';
    }
  }

  // ── PICK IMAGE ───────────────────────────────────────────────────────────────
  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return;
      await _sendMediaMessage(
          file: File(image.path), type: MessageType.image);
    } catch (e) {
      _showSnack('Could not pick image');
    }
  }

  Future<void> _captureImageFromCamera() async {
    try {
      final image = await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 80);
      if (image == null) return;
      await _sendMediaMessage(
          file: File(image.path), type: MessageType.image);
    } catch (e) {
      _showSnack('Could not open camera');
    }
  }

  // ── PICK FILE ────────────────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx'],
      );
      if (result == null) return;
      final f = result.files.first;
      if (f.path == null) return;
      await _sendMediaMessage(
        file: File(f.path!),
        type: MessageType.file,
        fileName: f.name,
      );
    } catch (e) {
      _showSnack('Could not pick file');
    }
  }

  // ── RECORDING ────────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _showSnack('Microphone permission denied');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });
      _tickRecordTimer();
    } catch (e) {
      _showSnack('Could not start recording');
    }
  }

  void _tickRecordTimer() async {
    while (_isRecording && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) setState(() => _recordSeconds++);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
      if (path != null && File(path).existsSync()) {
        await _sendMediaMessage(
          file: File(path),
          type: MessageType.audio,
          fileName: 'voice_message.m4a',
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });
      _showSnack('Recording error');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
    } catch (_) {}
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  // ── PLAY AUDIO ───────────────────────────────────────────────────────────────
  Future<void> _toggleAudio(ChatMessage msg) async {
    final localPath = msg.filePath;
    final remoteUrl = msg.fileUrl;
    final source = (localPath != null && File(localPath).existsSync())
        ? localPath
        : remoteUrl;

    if (source == null) return;

    if (_currentlyPlayingPath == source && _isPlayingAudio) {
      await _audioPlayer.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      await _audioPlayer.stop();
      try {
        if (localPath != null && File(localPath).existsSync()) {
          await _audioPlayer.play(DeviceFileSource(localPath));
        } else if (remoteUrl != null) {
          await _audioPlayer.play(UrlSource(remoteUrl));
        }
        setState(() {
          _currentlyPlayingPath = source;
          _isPlayingAudio = true;
        });
      } catch (e) {
        _showSnack('Cannot play audio');
      }
    }
  }

  // ── OPEN FILE externally (only for real files, not images) ──────────────────
  Future<void> _openFileExternal(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _showSnack('Cannot open file');
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+201000000000');
    if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatRecordTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── Patient avatar ──────────────────────────────────────────────────────────
  Widget _buildPatientAvatar({double radius = 20}) {
    final imageUrl = widget.patientImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: () {
        final profileId = widget.patientProfileId ?? widget.chatId;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PatientDetailsPage(patientId: profileId)));
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white.withOpacity(.2),
        backgroundImage:
            hasImage ? NetworkImage(imageUrl) as ImageProvider : null,
        child: !hasImage
            ? Text(
                widget.doctorName.isNotEmpty
                    ? widget.doctorName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.8),
              )
            : null,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FIX: فتح الصورة داخل التطبيق بالحجم الكامل
  // ─────────────────────────────────────────────────────────────────────────────
  void _viewFullImage(ChatMessage msg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageView(msg: msg),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(children: [
        _buildHeader(),
        if (_isSendingMedia)
          LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.blueColor),
          ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final msg = messages[i];
              Widget? separator;
              if (i == messages.length - 1) {
                separator = _buildDateSeparator(msg.rawTime);
              } else {
                final next = messages[i + 1];
                if (msg.rawTime.day != next.rawTime.day ||
                    msg.rawTime.month != next.rawTime.month ||
                    msg.rawTime.year != next.rawTime.year) {
                  separator = _buildDateSeparator(msg.rawTime);
                }
              }
              return Column(children: [
                if (separator != null) separator,
                _buildMessage(msg),
              ]);
            },
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
      ]),
    );
  }

  // ── Date separator ───────────────────────────────────────────────────────────
  Widget _buildDateSeparator(DateTime dt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(_dateLabel(dt),
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ]),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 44, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1976D2)]),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          _buildPatientAvatar(radius: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.doctorName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Row(children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: Color(0xFF69F0AE),
                            shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Online',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ]),
                ]),
          ),
          IconButton(
            onPressed: _makePhoneCall,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.call_rounded,
                  color: Colors.white, size: 20),
            ),
            padding: EdgeInsets.zero,
          ),
        ]),
      ),
    );
  }

  // ── Recording bar ─────────────────────────────────────────────────────────────
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
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(children: [
        _PulseIcon(),
        const SizedBox(width: 10),
        Text(
          '🎤 Recording... ${_formatRecordTime(_recordSeconds)}',
          style: const TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w600,
              fontSize: 15),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _cancelRecording,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14)),
            child:
                const Icon(Icons.delete_outline, color: Colors.red, size: 22),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.send_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ]),
    );
  }

  // ── Message bubble ────────────────────────────────────────────────────────────
  Widget _buildMessage(ChatMessage msg) {
    return Align(
      alignment:
          msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 8),
          Container(
            margin: EdgeInsets.only(
              left: msg.isMe ? 60 : 0,
              right: msg.isMe ? 12 : 60,
              top: 4,
              bottom: 4,
            ),
            padding: _msgPadding(msg),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            decoration: BoxDecoration(
              color: msg.isMe
                  ? AppColors.chatBubbleMe
                  : AppColors.chatBubbleOther,
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
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildContent(msg),
                const SizedBox(height: 4),
                Text(msg.time,
                    style: TextStyle(
                        fontSize: 10,
                        color: msg.isMe
                            ? Colors.white54
                            : Colors.grey.shade400)),
              ],
            ),
          ),
          if (msg.isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  EdgeInsets _msgPadding(ChatMessage msg) =>
      msg.type == MessageType.image
          ? const EdgeInsets.all(4)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10);

  // ─────────────────────────────────────────────────────────────────────────────
  // FIX: Message content – الصورة تفتح داخل التطبيق
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildContent(ChatMessage msg) {
    switch (msg.type) {

      // ── TEXT ──────────────────────────────────────────────────────────────────
      case MessageType.text:
        return Text(msg.text,
            style: TextStyle(
                color: msg.isMe ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.35));

      // ── IMAGE ─────────────────────────────────────────────────────────────────
      case MessageType.image:
        Widget imageWidget;
        final hasLocal =
            msg.filePath != null && File(msg.filePath!).existsSync();
        final hasRemote = msg.fileUrl != null && msg.fileUrl!.isNotEmpty;

        if (hasLocal) {
          imageWidget = Image.file(File(msg.filePath!),
              width: 220, height: 200, fit: BoxFit.cover);
        } else if (hasRemote) {
          imageWidget = Image.network(
            msg.fileUrl!,
            width: 220,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const SizedBox(
                    width: 220,
                    height: 200,
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2))),
            errorBuilder: (_, __, ___) => Container(
              width: 220,
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                  child: Icon(Icons.broken_image,
                      size: 50, color: Colors.grey)),
            ),
          );
        } else {
          imageWidget = Container(
            width: 220,
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        // FIX: onTap يفتح الصورة داخل التطبيق مش خارجه
        return GestureDetector(
          onTap: () => _viewFullImage(msg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                imageWidget,
                // أيقونة صغيرة تدل إن الصورة ممكن تتكبر
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.zoom_in,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        );

      // ── AUDIO ─────────────────────────────────────────────────────────────────
      case MessageType.audio:
        final source = (msg.filePath != null &&
                File(msg.filePath!).existsSync())
            ? msg.filePath!
            : msg.fileUrl;
        final isThisPlaying =
            _currentlyPlayingPath == source && _isPlayingAudio;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: source != null ? () => _toggleAudio(msg) : null,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? Colors.white.withOpacity(.25)
                      : const Color(0xFF1976D2).withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isThisPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: msg.isMe
                      ? Colors.white
                      : const Color(0xFF1976D2),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                      color: msg.isMe
                          ? Colors.white38
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 5),
              Text('Voice Message',
                  style: TextStyle(
                      color: msg.isMe
                          ? Colors.white70
                          : Colors.grey.shade600,
                      fontSize: 12)),
            ]),
          ],
        );

      // ── FILE ──────────────────────────────────────────────────────────────────
      case MessageType.file:
        return GestureDetector(
          onTap: () {
            if (msg.fileUrl != null) {
              _openFileExternal(msg.fileUrl!);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? Colors.white.withOpacity(.2)
                      : const Color(0xFF1976D2).withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insert_drive_file_rounded,
                    color: msg.isMe
                        ? Colors.white
                        : const Color(0xFF1976D2),
                    size: 22),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg.fileName ?? msg.text,
                          style: TextStyle(
                              color: msg.isMe
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      if (msg.fileUrl != null)
                        Text('Tap to open',
                            style: TextStyle(
                                color: msg.isMe
                                    ? Colors.white60
                                    : Colors.blue,
                                fontSize: 11)),
                    ]),
              ),
            ],
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIX: شاشة الصورة الكاملة داخل التطبيق مع زووم
// ─────────────────────────────────────────────────────────────────────────────
class _FullScreenImageView extends StatelessWidget {
  final ChatMessage msg;

  const _FullScreenImageView({required this.msg});

  @override
  Widget build(BuildContext context) {
    final hasLocal =
        msg.filePath != null && File(msg.filePath!).existsSync();
    final hasRemote = msg.fileUrl != null && msg.fileUrl!.isNotEmpty;

    Widget imageWidget;
    if (hasLocal) {
      imageWidget = Image.file(File(msg.filePath!), fit: BoxFit.contain);
    } else if (hasRemote) {
      imageWidget = Image.network(
        msg.fileUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(
                child: CircularProgressIndicator(color: Colors.white)),
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white, size: 80),
        ),
      );
    } else {
      imageWidget = const Center(
        child: Icon(Icons.broken_image, color: Colors.white, size: 80),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // زر Download لو في URL
          if (hasRemote)
            IconButton(
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              onPressed: () async {
                final uri = Uri.parse(msg.fileUrl!);
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              },
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: imageWidget,
        ),
      ),
    );
  }
}

// ─── Pulse indicator ──────────────────────────────────────────────────────────
class _PulseIcon extends StatefulWidget {
  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.5, end: 1.0).animate(_ctrl);
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: Color.fromRGBO(229, 57, 53, _anim.value),
              shape: BoxShape.circle),
        ),
      );
}

// ─── Chat Input ───────────────────────────────────────────────────────────────
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
    _controller.addListener(
        () => setState(() => _hasText = _controller.text.trim().isNotEmpty));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (!_hasText) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
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
                  offset: const Offset(0, -2))
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
              ]),
        ),
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
                offset: const Offset(0, -2))
          ],
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () =>
                setState(() => _showAttachMenu = !_showAttachMenu),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showAttachMenu
                    ? const Color(0xFF1976D2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _showAttachMenu
                    ? Icons.close_rounded
                    : Icons.attach_file_rounded,
                color: _showAttachMenu
                    ? Colors.white
                    : Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _hasText
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: _send,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  )
                : GestureDetector(
                    key: const ValueKey('mic'),
                    onTap: widget.onStartRecord,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(Icons.mic_rounded,
                          color: Colors.grey.shade600, size: 22),
                    ),
                  ),
          ),
        ]),
      ),
    ]);
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}