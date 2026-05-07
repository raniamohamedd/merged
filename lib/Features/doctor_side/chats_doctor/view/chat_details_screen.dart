import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routing/call_screen.dart';
import 'package:flutter_application_2/core/services/socket_service.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_detailsdoc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
   print('object');
  final yesterday = now.subtract(const Duration(days: 1));
  if (dt.year == yesterday.year &&
      dt.month == yesterday.month &&
      dt.day == yesterday.day) return 'Yesterday';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ─── Upload Helper ───────────────────────────────────────────────────────────
Future<Map<String, dynamic>?> _uploadAndGetResponse(
    File file, String token, String receiverId) async {
  try {
    final ext = file.path.split('.').last.toLowerCase();
    String mimeType;
    if (['jpg', 'jpeg'].contains(ext)) {
      mimeType = 'image/jpeg';
    } else if (ext == 'png') {
      mimeType = 'image/png';
    } else if (ext == 'gif') {
      mimeType = 'image/gif';
    } else if (ext == 'pdf') {
      mimeType = 'application/pdf';
    } else if (['m4a', 'aac', 'mp3'].contains(ext)) {
      mimeType = 'audio/mpeg';
    } else if (ext == 'webm') {
      mimeType = 'audio/webm';
    } else if (ext == 'mp4') {
      mimeType = 'video/mp4';
    } else {
      mimeType = 'application/octet-stream';
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://medpal-production-01b6.up.railway.app/chat/upload/$receiverId'),
    );
    request.headers['authorization'] = 'System $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await file.readAsBytes(),
        filename: file.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    print("📤 UPLOAD STATUS: ${response.statusCode}");
    print("📤 UPLOAD BODY: ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  } catch (e) {
    print("📤 UPLOAD ERROR: $e");
    return null;
  }
}


MessageType _parseMessageType(dynamic val) {
  final v = (val ?? '').toString().toLowerCase();
  if (v.contains('image')) return MessageType.image;
  if (v.contains('audio')) return MessageType.audio;
  if (v.contains('file')) return MessageType.file;
  return MessageType.text;
}

MessageType _parseMessageTypeFromMsg(Map<String, dynamic> msg) {
  final attachment = msg['attachment'];
  if (attachment != null) {
    final mime = (attachment['mimeType'] ?? '').toString().toLowerCase();
    final fileName = (attachment['fileName'] ?? '').toString().toLowerCase();
    if (mime.startsWith('image/') || fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') || fileName.endsWith('.png') ||
        fileName.endsWith('.gif') || fileName.endsWith('.webp')) {
      return MessageType.image;
    }
    if (mime.startsWith('audio/') || fileName.endsWith('.m4a') ||
        fileName.endsWith('.mp3') || fileName.endsWith('.aac') ||
        fileName.endsWith('.webm')) {
      return MessageType.audio;
    }
  }
  return _parseMessageType(msg['messageType'] ?? msg['type']);
}

// ─── Screen ─────────────────────────────────────────────────────────────────
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

  // ── init socket ────────────────────────────────────────────────────────────
  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("accessToken") ?? "";
    myUserId = prefs.getString("userId") ?? "";

    chatService = SocketService();
    chatService.connect(
      "https://medpal-production-01b6.up.railway.app",
      "System $_accessToken",
    );

    chatService.onMessage((msg) {
      if (!mounted) return;

      final senderId = msg['senderId']?.toString() ?? '';

      // ✅ تجاهل رسائلي أنا — اتضافت محلياً بالفعل
      if (senderId == myUserId) return;

      final dt = _parseDate(msg['createdAt']);
      final msgType = _parseMessageTypeFromMsg(msg);
      final attachment = msg['attachment'];
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            text: msg['message'] ?? msg['text'] ?? "",
            isMe: false,
            type: msgType,
            time: _formatTime(dt),
            rawTime: dt,
            fileUrl: attachment != null
                ? attachment['secure_url']
                : msg['fileUrl'],
            fileName: attachment != null
                ? attachment['fileName']
                : msg['fileName'],
            senderId: senderId,
          ),
        );
      });
    });

    chatService.onHistory((data) {
      if (!mounted) return;
      final list = data is List ? data : (data['messages'] ?? []);
      final parsed = <ChatMessage>[];
      for (final m in list) {
        final dt = _parseDate(m['createdAt']);
        final msgType = _parseMessageTypeFromMsg(m);
        final attachment = m['attachment'];
        parsed.add(ChatMessage(
          text: m['message'] ?? m['text'] ?? "",
          isMe: m['senderId'] != receiverId,
          type: msgType,
          time: _formatTime(dt),
          rawTime: dt,
          fileUrl:
              attachment != null ? attachment['secure_url'] : m['fileUrl'],
          fileName:
              attachment != null ? attachment['fileName'] : m['fileName'],
          senderId: m['senderId'],
        ));
      }
      setState(() {
        messages.clear();
        messages.addAll(parsed.reversed.toList());
      });
    });

    chatService.getHistory(receiverId);

    // ── incoming call ──────────────────────────────────────────────────────
    chatService.onIncomingCall((data) {
      if (!mounted) return;
      _showIncomingCallDialog(data);
    });
  }

  void _showIncomingCallDialog(dynamic data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Incoming Call'),
        // content: Text('\${data['callerName'] ?? 'Patient'} is calling...'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.call_end, color: Colors.red),
            label: const Text('Reject', style: TextStyle(color: Colors.red)),
            onPressed: () {
              chatService.rejectCall(callerId: data['callerId']?.toString() ?? '');
              Navigator.pop(context);
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            icon: const Icon(Icons.call, color: Colors.white),
            label: const Text('Accept', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    callerName: data['callerName'] ?? widget.doctorName,
                    receiverId: data['callerId']?.toString() ?? '',
                    isIncoming: true,
                    socketService: chatService,
                    callId: data['callId']?.toString(),
                    incomingCallData: data,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
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

  // ── SEND TEXT ─────────────────────────────────────────────────────────────
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
        ),
      );
    });
  }

  // ── SEND MEDIA ────────────────────────────────────────────────────────────
  // ✅ Upload endpoint already saves the message — no extra socket emit needed
  Future<void> _sendMediaMessage({
    required File file,
    required MessageType type,
    String? fileName,
  }) async {
    setState(() => _isSendingMedia = true);
    try {
      final uploadResponse =
          await _uploadAndGetResponse(file, _accessToken, receiverId);
      if (uploadResponse == null) {
        _showSnack('Upload failed. Check your connection.');
        return;
      }

      final url = uploadResponse['attachment']?['secure_url']
          ?? uploadResponse['secure_url']
          ?? uploadResponse['url'];

      if (url == null) {
        _showSnack('Upload failed: no URL returned.');
        return;
      }

      // ✅ detect real type from mimeType
      final mime = (uploadResponse['attachment']?['mimeType'] ?? '').toString().toLowerCase();
      final fName = (uploadResponse['attachment']?['fileName'] ?? '').toString().toLowerCase();
      MessageType realType;
      if (mime.startsWith('image/') || fName.endsWith('.jpg') || fName.endsWith('.jpeg') ||
          fName.endsWith('.png') || fName.endsWith('.gif') || fName.endsWith('.webp')) {
        realType = MessageType.image;
      } else if (mime.startsWith('audio/') || fName.endsWith('.m4a') ||
          fName.endsWith('.mp3') || fName.endsWith('.aac') || fName.endsWith('.webm')) {
        realType = MessageType.audio;
      } else {
        realType = type;
      }

      final resolvedName = uploadResponse['attachment']?['fileName']
          ?? fileName
          ?? file.path.split('/').last;

      final now = DateTime.now();
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            text: resolvedName,
            isMe: true,
            type: realType,
            time: _formatTime(now),
            rawTime: now,
            filePath: file.path,
            fileUrl: url,
            fileName: resolvedName,
          ),
        );
      });
    } catch (e) {
      _showSnack('Error sending media: $e');
    } finally {
      if (mounted) setState(() => _isSendingMedia = false);
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

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("URL launch error: $e");
    }
  }

  // ── PICK IMAGE ────────────────────────────────────────────────────────────
  Future<void> _pickImageFromGallery() async {
    final image = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    await _sendMediaMessage(file: File(image.path), type: MessageType.image);
  }

  Future<void> _captureImageFromCamera() async {
    final image = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 80);
    if (image == null) return;
    await _sendMediaMessage(file: File(image.path), type: MessageType.image);
  }

  // ── PICK FILE ─────────────────────────────────────────────────────────────
  Future<void> _pickFile() async {
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
  }

  // ── RECORDING ─────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) return;
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _tickRecordTimer();
  }

  void _tickRecordTimer() async {
    while (_isRecording && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) setState(() => _recordSeconds++);
    }
  }

  Future<void> _stopRecording() async {
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
  }

  Future<void> _cancelRecording() async {
    await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  // ── PLAY AUDIO ────────────────────────────────────────────────────────────
  Future<void> _toggleAudio(ChatMessage msg) async {
    final source =
        msg.filePath != null && File(msg.filePath!).existsSync()
            ? msg.filePath!
            : msg.fileUrl;
    if (source == null) return;

    if (_currentlyPlayingPath == source && _isPlayingAudio) {
      await _audioPlayer.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      await _audioPlayer.stop();
      if (msg.filePath != null && File(msg.filePath!).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(msg.filePath!));
      } else if (msg.fileUrl != null) {
        await _audioPlayer.play(UrlSource(msg.fileUrl!));
      }
      setState(() {
        _currentlyPlayingPath = source;
        _isPlayingAudio = true;
      });
    }
  }

  void _initiateCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerName: widget.doctorName,
          receiverId: receiverId,
          isIncoming: false,
          socketService: chatService,
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatRecordTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── Patient avatar ─────────────────────────────────────────────────────────
  Widget _buildPatientAvatar({double radius = 20}) {
    final imageUrl = widget.patientImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: () {
        final profileId = widget.patientProfileId ?? receiverId;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PatientDetailsPage(patientId: profileId)),
        );
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white24,
        backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
        child: !hasImage
            ? Icon(Icons.person, color: Colors.white, size: radius)
            : null,
      ),
    );
  }

  void _viewFullImage(ChatMessage msg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: msg.filePath != null &&
                      File(msg.filePath!).existsSync()
                  ? Image.file(File(msg.filePath!))
                  : msg.fileUrl != null
                      ? Image.network(msg.fileUrl!)
                      : const Icon(Icons.broken_image,
                          color: Colors.white, size: 80),
            ),
          ),
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          if (_isSendingMedia)
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFE3F0FF),
              color: AppColors.blueColor,
            ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _buildItems().length,
              itemBuilder: (_, i) {
                final item = _buildItems()[i];
                if (item is String) return _buildDateDivider(item);
                return _buildMessage(item as ChatMessage);
              },
            ),
          ),
          if (_isRecording) _buildRecordingBar(),
          ChatInput(
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

  List<dynamic> _buildItems() {
   
    return messages;
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 8,
        right: 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.blueColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
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
                        color: Color(0xFF69F0AE), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  const Text('Online',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ],
            ),
          ),
          IconButton(
            onPressed: _initiateCall,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.call_rounded,
                  color: Colors.white, size: 20),
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style:
                const TextStyle(fontSize: 12, color: Colors.black54)),
      ),
    );
  }

  // ── MESSAGE BUBBLE ────────────────────────────────────────────────────────
  Widget _buildMessage(ChatMessage msg) {
    final isMe = msg.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 60 : 0,
          right: isMe ? 12 : 60,
          top: 3,
          bottom: 3,
        ),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.chatBubbleMe
              : AppColors.chatBubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: _msgPadding(msg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMessageContent(msg),
            const SizedBox(height: 3),
            Text(
              msg.time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white60 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _msgPadding(ChatMessage msg) {
    if (msg.type == MessageType.image) {
      return const EdgeInsets.all(4);
    }
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  }

  Widget _buildMessageContent(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.image:
        Widget imageWidget;
        if (msg.filePath != null && File(msg.filePath!).existsSync()) {
          imageWidget = Image.file(File(msg.filePath!),
              width: 220, height: 200, fit: BoxFit.cover);
        } else if (msg.fileUrl != null) {
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
            errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                size: 60,
                color: Colors.grey),
          );
        } else {
          imageWidget = const Icon(Icons.broken_image,
              size: 60, color: Colors.grey);
        }
        return GestureDetector(
          onTap: () => _viewFullImage(msg),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageWidget),
        );

      case MessageType.audio:
        final source =
            msg.filePath != null && File(msg.filePath!).existsSync()
                ? msg.filePath!
                : msg.fileUrl;
        final isThisPlaying =
            _currentlyPlayingPath == source && _isPlayingAudio;
        return GestureDetector(
          onTap: source != null ? () => _toggleAudio(msg) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? Colors.white.withOpacity(.25)
                      : AppColors.blueColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isThisPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: msg.isMe ? Colors.white : AppColors.blueColor,
                  size: 22,
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
                      color: msg.isMe
                          ? Colors.white38
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Voice Message',
                    style: TextStyle(
                      color: msg.isMe
                          ? Colors.white70
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case MessageType.file:
        return GestureDetector(
          onTap: () {
            if (msg.fileUrl != null) openUrl(msg.fileUrl!);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? Colors.white.withOpacity(.2)
                      : AppColors.blueColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.insert_drive_file_rounded,
                  color: msg.isMe ? Colors.white : AppColors.blueColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.fileName ?? msg.text,
                      style: TextStyle(
                        color: msg.isMe
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (msg.fileUrl != null)
                      Text(
                        'Tap to open',
                        style: TextStyle(
                          color: msg.isMe
                              ? Colors.white60
                              : Colors.blue,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return Text(
          msg.text,
          style: TextStyle(
            color: msg.isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        );
    }
  }

  // ── RECORDING BAR ─────────────────────────────────────────────────────────
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
          )
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
                fontSize: 15),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulse Icon ────────────────────────────────────────────────────────────────
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
        vsync: this,
        duration: const Duration(milliseconds: 800))
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
            shape: BoxShape.circle,
          ),
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

  Widget _attachOption(IconData icon, String label, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        setState(() => _showAttachMenu = false);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showAttachMenu)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachOption(Icons.photo_library_rounded, 'Gallery',
                    Colors.purple, widget.onPickImage),
                _attachOption(Icons.camera_alt_rounded, 'Camera',
                    Colors.blue, widget.onCamera),
                _attachOption(Icons.insert_drive_file_rounded, 'File',
                    Colors.orange, widget.onPickFile),
              ],
            ),
          ),
        Container(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 8,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>
                    setState(() => _showAttachMenu = !_showAttachMenu),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _showAttachMenu
                        ? AppColors.blueColor.withOpacity(.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _showAttachMenu ? Icons.close : Icons.attach_file_rounded,
                    color: _showAttachMenu
                        ? AppColors.blueColor
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _hasText ? _send : widget.onStartRecord,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _hasText ? Icons.send_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 20,
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