import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/services/socket_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// ---------------- ENUM ----------------
enum MessageType { text, image, audio, file }

late SocketService chatService;

/// ---------------- MODEL ----------------
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

/// ---------------- COLORS ----------------
class AppColors {
  static const blueColor = Color(0xFF1976D2);
  static const whiteColor = Colors.white;
  static const greyColor = Colors.grey;
  static const blackColor = Colors.black;
  static const backgroundColor = Color(0xFFF7FAFC);
}

/// ---------------- SCREEN ----------------
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

class _ChatsPageDoctorState extends State<ChatsPageDoctor> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();

  String? _currentlyPlayingPath;
  final bool _isPlaying = false;

  String get receiverId => widget.chatId;

  final List<ChatMessage> messages = [];

  /// ---------------- SOCKET INIT ----------------
  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? "";

    chatService = SocketService();

    chatService.connect(
      "https://medpal-production-e325.up.railway.app",
      "Bearer $token",
    );

    print("🔌 SOCKET CONNECTING...");

    /// بعد الاتصال
    Future.delayed(const Duration(seconds: 1), () {
      chatService.socket?.onAny((event, data) {
        print("📡 EVENT: $event");
        print("📦 DATA: $data");
      });
    });

    /// استقبال الرسائل
    chatService.onMessage((msg) {
      print("📩 SERVER MESSAGE: $msg");

      setState(() {
        messages.insert(
          0,
          ChatMessage(
            text: msg['message'] ?? "",
            isMe: false,
            type: MessageType.text,
            time: _nowTime(),
          ),
        );
      });
    });

    /// التاريخ
    chatService.onHistory((data) {
      print("📜 HISTORY: $data");

      final List msgs = data['messages'] ?? [];

      setState(() {
        messages.clear();
        for (var m in msgs.reversed) {
          messages.insert(
            0,
            ChatMessage(
              text: m['message'] ?? "",
              isMe: false,
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

  /// ---------------- SEND MESSAGE ----------------
  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;

    print("📤 SENDING MESSAGE: $text");

    chatService.sendMessage(
      receiverId: receiverId,
      message: text,
    );

    setState(() {
      messages.insert(
        0,
        ChatMessage(
          text: text,
          isMe: true,
          type: MessageType.text,
          time: _nowTime(),
        ),
      );
    });
  }

  /// ---------------- IMAGE ----------------
  Future<void> _pickImageFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      messages.insert(
        0,
        ChatMessage(
          text: "",
          isMe: true,
          type: MessageType.image,
          time: _nowTime(),
          filePath: image.path,
        ),
      );
    });
  }

  Future<void> _captureImageFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      messages.insert(
        0,
        ChatMessage(
          text: "",
          isMe: true,
          type: MessageType.image,
          time: _nowTime(),
          filePath: image.path,
        ),
      );
    });
  }

  /// ---------------- FILE ----------------
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = result.files.first;

    setState(() {
      messages.insert(
        0,
        ChatMessage(
          text: file.name,
          isMe: true,
          type: MessageType.file,
          time: _nowTime(),
          filePath: file.path,
          fileName: file.name,
        ),
      );
    });
  }

  /// ---------------- CALL ----------------
  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '123');
    await launchUrl(phoneUri);
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
              itemCount: messages.length,
              itemBuilder: (_, i) => _buildMessage(messages[i]),
            ),
          ),
          ChatInput(
            onSend: _sendTextMessage,
            onPickImage: _pickImageFromGallery,
            onCamera: _captureImageFromCamera,
            onPickFile: _pickFile,
            onSendAudio: (path, duration) {},
          ),
        ],
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 40, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.blueColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.doctorName,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: _makePhoneCall,
              icon: const Icon(Icons.call, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- MESSAGE UI ----------------
  Widget _buildMessage(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isMe ? AppColors.blueColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: msg.type == MessageType.text
            ? Text(
                msg.text,
                style: TextStyle(
                  color: msg.isMe ? Colors.white : Colors.black,
                ),
              )
            : msg.type == MessageType.image
                ? Image.file(File(msg.filePath!))
                : Text(msg.text),
      ),
    );
  }
}

/// ---------------- INPUT ----------------
class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onPickImage;
  final VoidCallback onCamera;
  final VoidCallback onPickFile;
  final Function(String, Duration) onSendAudio;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.onPickImage,
    required this.onCamera,
    required this.onPickFile,
    required this.onSendAudio,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  void _send() {
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: widget.onPickFile),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "Message"),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _send),
        ],
      ),
    );
  }
}