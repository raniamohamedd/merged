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
class ChatsPagePatient extends StatefulWidget {
  final String doctorName;
  final String chatId;
  const ChatsPagePatient({
    super.key,
    required this.doctorName,
    required this.chatId,
    required chatName,
  });

  @override
  State<ChatsPagePatient> createState() => _ChatsPagePatientState();
}

class _ChatsPagePatientState extends State<ChatsPagePatient> {
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
        .update({'unreadCount_${currentUserId}': 0})
        .catchError((_) {});
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
        padding: const EdgeInsets.all(13.0),
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
                      Text(
                        'Dr. ${widget.doctorName}',
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Online",
                        style: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messages
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Say hi 👋 to start the conversation",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
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
                        orElse: () => MessageType.text,
                      );

                      Widget messageContent;

                      switch (type) {
                        case MessageType.text:
                          messageContent = Text(
                            data['text'] ?? '',
                            style: TextStyle(
                              color: isMe
                                  ? AppColors.whiteColor
                                  : AppColors.blackColor,
                            ),
                          );
                          break;
                        case MessageType.image:
                          final filePath = data['filePath'] ?? '';
                          messageContent = ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                filePath.isNotEmpty &&
                                    File(filePath).existsSync()
                                ? Image.file(
                                    File(filePath),
                                    width: 200,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox(
                                    width: 200,
                                    height: 150,
                                    child: Center(
                                      child: Text("Image not found"),
                                    ),
                                  ),
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
                                    color: isMe
                                        ? AppColors.whiteColor
                                        : AppColors.blueColor,
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
                          break;
                        case MessageType.video:
                          final filePath = data['filePath'] ?? '';
                          messageContent =
                              filePath.isNotEmpty && File(filePath).existsSync()
                              ? SizedBox(
                                  width: 200,
                                  height: 150,
                                  child: VideoPlayerWidget(filePath: filePath),
                                )
                              : const SizedBox(
                                  width: 200,
                                  height: 150,
                                  child: Center(child: Text("Video not found")),
                                );
                          break;
                        case MessageType.file:
                          final filePath = data['filePath'] ?? '';
                          final fileName = data['text'] ?? 'File';
                          messageContent = GestureDetector(
                            onTap: () async {
                              if (filePath.isNotEmpty &&
                                  File(filePath).existsSync()) {
                                await OpenFile.open(filePath);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    fileName,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          break;
                      }

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColors.blueColor
                                    : AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: messageContent,
                            ),
                            Text(
                              data['time'] ?? '',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.greyColor,
                              ),
                            ),
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
                onSend:
                    (msg, {type = MessageType.text, String? filePath}) async {
                      if (msg.trim().isEmpty && filePath == null) return;

                      await messages.add({
                        'text': msg,
                        'senderId': currentUserId,
                        'time': TimeOfDay.now().format(context),
                        'type': type.name,
                        'filePath': filePath,
                        'createdAt': DateTime.now(),
                      });

                      final chatRef = FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.chatId);

                      await chatRef.set({
                        'lastMessage': msg.isNotEmpty
                            ? msg
                            : (type == MessageType.image
                                  ? '📷 Photo'
                                  : (type == MessageType.video
                                        ? '🎬 Video'
                                        : (type == MessageType.audio
                                              ? '🎤 Voice message'
                                              : '📎 File'))),
                        'updatedAt': FieldValue.serverTimestamp(),
                        'patientId': FirebaseAuth.instance.currentUser!.uid,
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
                  const Icon(
                    Icons.play_circle_fill,
                    size: 50,
                    color: Colors.white,
                  ),
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

  bool _isEmojiVisible = false;
  bool _hasText = false;
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;

  late FlutterSoundRecorder _recorder;
  bool _recorderReady = false;
  String? _recordedFilePath;

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

    _recorder = FlutterSoundRecorder();
    _initRecorder();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));
    _recorderReady = true;
  }

  Future<void> _startRecording() async {
    if (!_recorderReady) return;

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);

    setState(() {
      _isRecording = true;
      _recordDuration = 0;
      _recordedFilePath = filePath;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordDuration++);
    });
  }

  Future<void> _stopRecording() async {
    if (!_recorderReady || !_isRecording) return;

    await _recorder.stopRecorder();
    _timer?.cancel();

    setState(() {
      _isRecording = false;
      _recordDuration = 0;
    });

    if (_recordedFilePath != null && File(_recordedFilePath!).existsSync()) {
      widget.onSend(
        "Voice message",
        type: MessageType.audio,
        filePath: _recordedFilePath,
      );
      _recordedFilePath = null;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text, type: MessageType.text);
    _controller.clear();
  }

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      widget.onSend("", type: MessageType.image, filePath: photo.path);
    }
  }

  Future<void> _attachFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      String path = result.files.first.path!;
      String name = result.files.first.name;
      MessageType type;

      if (name.toLowerCase().endsWith('.png') ||
          name.toLowerCase().endsWith('.jpg') ||
          name.toLowerCase().endsWith('.jpeg') ||
          name.toLowerCase().endsWith('.gif')) {
        type = MessageType.image;
      } else if (name.toLowerCase().endsWith('.aac') ||
          name.toLowerCase().endsWith('.mp3') ||
          name.toLowerCase().endsWith('.m4a') ||
          name.toLowerCase().endsWith('.wav')) {
        type = MessageType.audio;
      } else if (name.toLowerCase().endsWith('.mp4') ||
          name.toLowerCase().endsWith('.mov') ||
          name.toLowerCase().endsWith('.avi')) {
        type = MessageType.video;
      } else {
        type = MessageType.file;
      }

      String messageText = type == MessageType.file ? name : "";
      widget.onSend(messageText, type: type, filePath: path);
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
              onPressed: _toggleEmojiPicker,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: _isRecording ? "Recording..." : "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.attach_file, color: Colors.grey),
              onPressed: _attachFile,
            ),
            IconButton(
              icon: Icon(CupertinoIcons.camera_fill, color: Colors.grey),
              onPressed: _openCamera,
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 28,
              backgroundColor: _isRecording ? Colors.redAccent : Colors.blue,
              child: IconButton(
                icon: Icon(
                  _hasText
                      ? Icons.send
                      : (_isRecording ? Icons.stop : Icons.mic),
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (_hasText) {
                    sendMessage();
                  } else {
                    if (_isRecording)
                      await _stopRecording();
                    else
                      await _startRecording();
                  }
                },
              ),
            ),
          ],
        ),
        if (_isRecording)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatDuration(_recordDuration),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_isEmojiVisible)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              textEditingController: _controller,
              config: const Config(
                emojiViewConfig: EmojiViewConfig(emojiSizeMax: 32, columns: 7),
              ),
            ),
          ),
      ],
    );
  }
}
