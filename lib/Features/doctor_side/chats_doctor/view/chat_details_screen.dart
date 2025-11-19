import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:open_file/open_file.dart';

enum MessageType { text, image, audio, video, file }

class ChatsPageDoctor extends StatefulWidget {
  final String doctorName;
  final String chatId;

  const ChatsPageDoctor({super.key, required this.doctorName, required this.chatId, required String chatName});

  @override
  State<ChatsPageDoctor> createState() => _ChatsPageDoctorState();
}

class _ChatsPageDoctorState extends State<ChatsPageDoctor> {
  late final CollectionReference messages;
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    messages = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({'unreadCount_${currentUserId}': 0}).catchError((_) {});
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          children: [
            Container(
              color: AppColors.whiteColor,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 10,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.doctorName,
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 19)),
                      const SizedBox(height: 2),
                      Text("Online",
                          style: TextStyle(color: AppColors.greyColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child:
               StreamBuilder<QuerySnapshot>(
                stream: messages.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return  Center(
                        child: Text("Say hi 👋 to start the conversation",
                            style: TextStyle(fontSize: 16, color:AppColors.greyColor)));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final bool isMe = data['senderId'] == currentUserId;
                      final MessageType type = MessageType.values.firstWhere(
                          (e) => e.name == data['type'],
                          orElse: () => MessageType.text);

                      Widget messageContent;

                      switch (type) {
                        case MessageType.text:
                          messageContent = Text(
                            data['text'] ?? '',
                            style: TextStyle(
                              color: isMe ? AppColors.whiteColor : AppColors.blackColor,
                            ),
                          );
                          break;
                        case MessageType.image:
                          final filePath = data['filePath'] ?? '';
                          messageContent = ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: filePath.isNotEmpty && File(filePath).existsSync()
                                ? Image.file(File(filePath), width: 200, fit: BoxFit.cover)
                                : const SizedBox(width: 200, height: 150, child: Center(child: Text("Image not found"))),
                          );
                          break;
                     case MessageType.audio:
  final filePath = data['filePath'] ?? '';
  bool isPlaying = false; 
  final player = FlutterSoundPlayer();

  messageContent = StatefulBuilder(
    builder: (context, setState) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isPlaying ? Icons.stop : Icons.play_arrow,
            color: isMe ? AppColors.whiteColor : AppColors.blueColor,
          ),
          onPressed: () async {
            if (!isPlaying) {
              await player.openPlayer();
              await player.startPlayer(
                fromURI: filePath,
                whenFinished: () {
                  setState(() => isPlaying = false);
                },
              );
              setState(() => isPlaying = true);
            } else {
              await player.stopPlayer();
              setState(() => isPlaying = false);
            }
          },
        ),
        const SizedBox(width: 8),
        const Text("Voice message"),
      ],
    ),
  );
  break;
                        case MessageType.video:
                          final filePath = data['filePath'] ?? '';
                          messageContent = filePath.isNotEmpty && File(filePath).existsSync()
                              ? SizedBox(width: 200, height: 150, child: VideoPlayerWidget(filePath: filePath))
                              : const SizedBox(width: 200, height: 150, child: Center(child: Text("Video not found")));
                          break;
                        case MessageType.file:
                          final filePath = data['filePath'] ?? '';
                          final fileName = data['text'] ?? 'File';
                          messageContent = GestureDetector(
                            onTap: () async {
                              if (filePath.isNotEmpty && File(filePath).existsSync()) {
                                await OpenFile.open(filePath);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 Icon(Icons.insert_drive_file, color: AppColors.greyColor),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(fileName,
                                      style:  TextStyle(color: AppColors.blueColor, decoration: TextDecoration.underline)),
                                ),
                              ],
                            ),
                          );
                          break;
                      }

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.blueColor : AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow:  [BoxShadow(color: AppColors.blackColor, blurRadius: 3, offset: Offset(0, 2))],
                              ),
                              child: messageContent,
                            ),
                            Text(data['time'] ?? '', style: TextStyle(fontSize: 10, color: AppColors.greyColor)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            SafeArea(
              child: ChatInput(
                onSend: (msg, {type = MessageType.text, String? filePath}) async {
                  if (msg.trim().isEmpty && filePath == null) return;

                  await messages.add({
                    'text': msg,
                    'senderId': currentUserId,
                    'time': TimeOfDay.now().format(context),
                    'type': type.name,
                    'filePath': filePath,
                    'createdAt': DateTime.now(),
                    
                  });
                  
                  
                  

                  final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

                  await chatRef.set({
                    'lastMessage': msg.isNotEmpty
                        ? msg
                        : (type == MessageType.image
                            ? '📷 Photo'
                            : (type == MessageType.video
                                ? '🎬 Video'
                                : (type == MessageType.audio ? '🎤 Voice message' : '📎 File'))),
                    'updatedAt': FieldValue.serverTimestamp(),
                    'doctorId': FirebaseAuth.instance.currentUser!.uid,
                  }, SetOptions(merge: true));

                  await Future.delayed(const Duration(milliseconds: 200));
                  _scrollToBottom();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class VideoPlayerWidget extends StatefulWidget {
  final String filePath;
  const VideoPlayerWidget({super.key, required this.filePath});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            },
            
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                if (!_controller.value.isPlaying)
                   Icon(Icons.play_circle_fill,
                      size: 50, color: AppColors.whiteColor),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class ChatInput extends StatefulWidget {
  final Function(String, {MessageType type, String? filePath}) onSend;
  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool _isEmojiVisible = false;
  bool _isRecording = false;
  bool _hasText = false;
  int _recordDuration = 0;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });

    _initRecorder();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);

    setState(() {
      _isRecording = true;
      _recordDuration = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordDuration++);
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _recordDuration = 0;
    });

    if (path != null && File(path).existsSync()) {
      widget.onSend("Voice message",
          type: MessageType.audio, filePath: path);
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
      setState(() => _hasText = false);
    }
  }

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      widget.onSend(photo.path,
          type: MessageType.image, filePath: photo.path);
    }
  }

  Future<void> _attachFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      String path = result.files.first.path!;
      String name = result.files.first.name;

      MessageType type;
      if (name.endsWith('.png') ||
          name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.gif')) {
        type = MessageType.image;
      } else if (name.endsWith('.aac') ||
          name.endsWith('.mp3') ||
          name.endsWith('.m4a') ||
          name.endsWith('.wav')) {
        type = MessageType.audio;
      } else if (name.endsWith('.mp4') ||
          name.endsWith('.mov') ||
          name.endsWith('.avi')) {
        type = MessageType.video;
      } else {
        type = MessageType.file;
      }

      String messageText = (type == MessageType.file) ? name : "";

      widget.onSend(messageText, type: type, filePath: path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon:
                  Icon(Icons.emoji_emotions_outlined, color: AppColors.greyColor),
              onPressed: _toggleEmojiPicker,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText:
                      _isRecording ? "Recording..." : "Type a message...",
                  hintStyle: TextStyle(
                    color: _isRecording
                        ? Colors.redAccent
                        : AppColors.greyColor,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.attach_file, color: AppColors.greyColor),
              onPressed: _attachFile,
            ),
            IconButton(
              icon: Icon(CupertinoIcons.camera_fill, color: AppColors.greyColor),
              onPressed: _openCamera,
            ),
            const SizedBox(width: 6),
            ScaleTransition(
              scale: _isRecording ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _isRecording
                        ? Colors.redAccent
                        : AppColors.blueColor,
                    child: IconButton(
                      icon: Icon(
                        _hasText
                            ? Icons.send
                            : (_isRecording ? Icons.stop : Icons.mic),
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (_hasText) {
                          _sendMessage();
                        } else {
                          if (_isRecording) {
                            await _stopRecording();
                          } else {
                            await _startRecording();
                          }
                        }
                      },
                    ),
                  ),
                  if (_isRecording)
                    Positioned(
                      bottom: -20,
                      child: Text(
                        _formatDuration(_recordDuration),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        _isEmojiVisible
            ? SizedBox(
                height: 250,
                child: EmojiPicker(
                  textEditingController: _controller,
                  config: const Config(
                    emojiViewConfig:
                        EmojiViewConfig(emojiSizeMax: 32, columns: 7),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}