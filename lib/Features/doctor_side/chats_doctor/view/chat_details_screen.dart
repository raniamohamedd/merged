import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_detailsdoc.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

/// ---------------- ENUM ----------------
enum MessageType { text, image, audio, file }

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

  const ChatsPageDoctor({
    super.key,
    required this.doctorName,
    required String chatId,
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
  bool _isPlaying = false;

  final List<ChatMessage> messages = [
    ChatMessage(
      text: "Please take the medicine after meals.",
      isMe: false,
      type: MessageType.text,
      time: "10:20 AM",
    ),
    ChatMessage(
      text: "Hi Doctor",
      isMe: true,
      type: MessageType.text,
      time: "10:01 AM",
    ),
    ChatMessage(
      text: "Hello Rania",
      isMe: false,
      type: MessageType.text,
      time: "10:00 AM",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingPath = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _nowTime() => TimeOfDay.now().format(context);

  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.insert(
        0,
        ChatMessage(
          text: text.trim(),
          isMe: true,
          type: MessageType.text,
          time: _nowTime(),
        ),
      );
    });

    _scrollToTop();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
          fileName: image.name,
        ),
      );
    });

    _scrollToTop();
  }

  Future<void> _captureImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
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
          fileName: image.name,
        ),
      );
    });

    _scrollToTop();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

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

    _scrollToTop();
  }

  Future<void> _toggleAudioPlay(String path) async {
    try {
      if (_currentlyPlayingPath == path && _isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
          _currentlyPlayingPath = null;
        });
        return;
      }

      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(path));

      setState(() {
        _currentlyPlayingPath = path;
        _isPlaying = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to play audio: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '123');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot open phone dialer"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 40, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.blueColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withOpacity(.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Material(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child:  IconButton(
                onPressed:(){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientDetailsPage(
                                        ),
                        
                        // (route) => false,
                      ));
                },
                
                 icon: Icon(Icons.person,color: Colors.white,) ,
                
               
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF4ADE80),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _makePhoneCall,
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.call_outlined,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final bool isMe = msg.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .72,
            ),
            padding: msg.type == MessageType.image
                ? const EdgeInsets.all(6)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppColors.blueColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 6),
                bottomRight: Radius.circular(isMe ? 6 : 18),
              ),
              border: isMe
                  ? null
                  : Border.all(color: const Color(0xFFF0F2F5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.03),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildMessageContent(msg),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              msg.time,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.greyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.text:
        return Text(
          msg.text,
          style: TextStyle(
            color: msg.isMe ? Colors.white : AppColors.blackColor,
            fontSize: 14,
            height: 1.4,
          ),
        );

      case MessageType.image:
        if (msg.filePath == null) {
          return const Text("Image unavailable");
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(msg.filePath!),
            width: 210,
            height: 220,
            fit: BoxFit.cover,
          ),
        );

      case MessageType.file:
        return InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Selected file: ${msg.fileName ?? 'File'}"),
                backgroundColor: AppColors.blueColor,
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: msg.isMe ? Colors.white : AppColors.blueColor,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  msg.fileName ?? msg.text,
                  style: TextStyle(
                    color: msg.isMe ? Colors.white : AppColors.blackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: msg.filePath == null
                  ? null
                  : () => _toggleAudioPlay(msg.filePath!),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? Colors.white.withOpacity(.18)
                      : AppColors.blueColor.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _currentlyPlayingPath == msg.filePath && _isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: msg.isMe ? Colors.white : AppColors.blueColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.graphic_eq_rounded,
              color: msg.isMe ? Colors.white70 : AppColors.blueColor,
            ),
            const SizedBox(width: 8),
            Text(
              msg.audioDuration != null
                  ? "${msg.audioDuration!.inSeconds}s voice"
                  : "Voice message",
              style: TextStyle(
                color: msg.isMe ? Colors.white : AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
    }
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
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          ChatInput(
            onSend: _sendTextMessage,
            onPickImage: _pickImageFromGallery,
            onCamera: _captureImageFromCamera,
            onPickFile: _pickFile,
            onSendAudio: (path, duration) {
              setState(() {
                messages.insert(
                  0,
                  ChatMessage(
                    text: "Voice Message",
                    isMe: true,
                    type: MessageType.audio,
                    time: _nowTime(),
                    filePath: path,
                    audioDuration: duration,
                  ),
                );
              });
              _scrollToTop();
            },
          ),
        ],
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
  final Function(String path, Duration duration) onSendAudio;

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
  final AudioRecorder _recorder = AudioRecorder();

  bool isRecording = false;
  DateTime? recordStart;

  @override
  void dispose() {
    _controller.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _send() {
    widget.onSend(_controller.text);
    _controller.clear();
  }

  Future<void> _toggleRecord() async {
    try {
      if (!isRecording) {
        final hasPermission = await _recorder.hasPermission();
        if (!hasPermission) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Microphone permission denied"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(),
          path: path,
        );

        setState(() {
          isRecording = true;
          recordStart = DateTime.now();
        });
      } else {
        final path = await _recorder.stop();
        final duration = DateTime.now().difference(recordStart!);

        setState(() {
          isRecording = false;
          recordStart = null;
        });

        if (path != null) {
          widget.onSendAudio(path, duration);
        }
      }
    } catch (e) {
      setState(() {
        isRecording = false;
        recordStart = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Voice recording error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _squareButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE9EDF3),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppColors.blueColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0F2F5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _squareButton(
              icon: Icons.attach_file_rounded,
              onTap: widget.onPickFile,
            ),
            const SizedBox(width: 8),
            _squareButton(
              icon: Icons.photo_outlined,
              onTap: widget.onPickImage,
            ),
            const SizedBox(width: 8),
            _squareButton(
              icon: Icons.camera_alt_outlined,
              onTap: widget.onCamera,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE9EDF3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "Type your message",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleRecord,
                      icon: Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                        color: isRecording ? Colors.red : AppColors.blueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.blueColor,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _send,
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}