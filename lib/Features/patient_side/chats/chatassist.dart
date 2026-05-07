import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors2.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Chatassist extends StatefulWidget {
  const Chatassist({super.key});

  @override
  State<Chatassist> createState() => _ChatassistState();
}

class _ChatassistState extends State<Chatassist> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final ScrollController scrollController = ScrollController();
  bool _isLoading = false;

@override
void initState() {
  super.initState();
  loadMessages(); // This now loads from API + handles welcome message
}

  void _addInitialBotMessage() {
    if (messages.isEmpty) {
      messages.add({
        "text": "Hello! I'm your healthcare assistant. How can I help you today?",
        "isUser": false,
        "image": null,
        "timestamp": DateTime.now().toString(),
      });
      saveMessages();
      setState(() {});
      _scrollToBottom();
    }
  }

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encoded = messages.map((msg) => jsonEncode(msg)).toList();
    prefs.setStringList("chat_messages", encoded);
  }
Future<void> loadMessages() async {
  try {
    final history = await ApiService.getChatHistory();
    
    if (history.isNotEmpty) {
      messages.clear();
      for (final msg in history) {
        messages.add({
          "text": msg["content"] ?? "",
          "isUser": msg["role"] == "user",
          "image": null,
          "timestamp": msg["createdAt"] ?? DateTime.now().toString(),
        });
      }
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    } else {
      // No history — show welcome message
      _addInitialBotMessage();
    }
  } catch (e) {
    // Fallback to local storage on error
    final prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList("chat_messages");
    if (saved != null && saved.isNotEmpty) {
      messages.clear();
      messages.addAll(saved.map((msg) => jsonDecode(msg)));
      setState(() {});
    } else {
      _addInitialBotMessage();
    }
  }
}
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    controller.clear();
    messages.add({
      "text": text,
      "isUser": true,
      "image": null,
      "timestamp": DateTime.now().toString(),
    });
    saveMessages();
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      final response = await http.post(
        Uri.parse('https://medpal-production-01b6.up.railway.app/chatbot'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': text}),
      );

      print(response.body);

      String replyText;
  if (response.statusCode == 200 || response.statusCode == 201) 
{
        final data = jsonDecode(response.body);
        // ✅ reply أولاً وبعدين باقي الـ fields
        final raw = data['reply'] ??
            data['response'] ??
            data['answer'] ??
            data['message'] ??
            'Sorry, I could not understand the response.';
        // ✅ fix الـ \n عشان يتعرض صح في Flutter
        replyText = raw.toString().replaceAll('\\n', '\n');
      } else {
        replyText = 'Server error (${response.statusCode}). Please try again.';
      }

      messages.add({
        "text": replyText,
        "isUser": false,
        "image": null,
        "timestamp": DateTime.now().toString(),
      });
    } catch (e) {
      messages.add({
        "text": 'Connection error. Please check your internet and try again.',
        "isUser": false,
        "image": null,
        "timestamp": DateTime.now().toString(),
      });
    } finally {
      saveMessages();
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> pickCamera() async {
    final XFile? img = await picker.pickImage(source: ImageSource.camera);
    if (img == null) return;
    messages.add({
      "text": "",
      "isUser": true,
      "image": img.path,
      "timestamp": DateTime.now().toString(),
    });
    saveMessages();
    setState(() {});
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 500), () {
      messages.add({
        "text": "Nice image! How can I assist you further?",
        "isUser": false,
        "image": null,
        "timestamp": DateTime.now().toString(),
      });
      saveMessages();
      setState(() {});
      _scrollToBottom();
    });
  }

  Future<void> pickGallery() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;
    messages.add({
      "text": "",
      "isUser": true,
      "image": img.path,
      "timestamp": DateTime.now().toString(),
    });
    saveMessages();
    setState(() {});
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 500), () {
      messages.add({
        "text": "Nice photo! How can I help you?",
        "isUser": false,
        "image": null,
        "timestamp": DateTime.now().toString(),
      });
      saveMessages();
      setState(() {});
      _scrollToBottom();
    });
  }

  void showFullImage(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Center(child: Image.file(File(path))),
        ),
      ),
    );
  }

  String formatTime(String? timestamp) {
    if (timestamp == null) return "";
    DateTime time = DateTime.parse(timestamp);
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (bottomInset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Column(
          children: [
            const SizedBox(height: 50),

            // ── Header ──
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      width: 33,
                      height: 33,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: BoxBorder.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: Colors.black),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Chat Assistant",
                    style: TextStyle(
                      color: AppColors.blueColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Messages ──
            Expanded(
              child: Container(
                color: const Color(0xffF7F7F7),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Typing indicator
                    if (_isLoading && index == messages.length) {
                      return Container(
                        color: const Color(0xffF7F7F7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xffE8F0FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.smart_toy, size: 22, color: Colors.blue),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const _TypingDots(),
                            ),
                          ],
                        ),
                      );
                    }

                    final msg = messages[index];
                    final bool isUser = msg["isUser"];

                    return Container(
                      color: const Color(0xffF7F7F7),
                      child: Row(
                        mainAxisAlignment:
                            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xffE8F0FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.smart_toy, size: 22, color: Colors.blue),
                            ),
                          if (!isUser) const SizedBox(width: 10),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isUser ? AppColors.blueColor : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: isUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  msg["image"] != null
                                      ? GestureDetector(
                                          onTap: () => showFullImage(msg["image"]),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(File(msg["image"]), width: 200),
                                          ),
                                        )
                                      : Text(
                                          // ✅ replaceAll عشان الـ \n يتعرض صح
                                          (msg["text"] ?? "").replaceAll('\\n', '\n'),
                                          softWrap: true,
                                          style: TextStyle(
                                            color: isUser ? Colors.white : Colors.black,
                                            fontSize: 15,
                                            height: 1.4,
                                          ),
                                        ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatTime(msg["timestamp"]),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isUser ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Input Area ──
            Container(
              height: 85,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: const Color.fromARGB(255, 228, 219, 219)),
                  //   ),
                  //   child: IconButton(
                  //     onPressed: pickGallery,
                  //     icon: const Icon(Icons.photo_outlined, size: 20),
                  //   ),
                  // ),
                  // const SizedBox(width: 10),
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: const Color.fromARGB(255, 228, 219, 219)),
                  //   ),
                  //   child: IconButton(
                  //     onPressed: pickCamera,
                  //     icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  //   ),
                  // ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color.fromARGB(255, 228, 219, 219)),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: "Type your message",
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => sendMessage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Color(0xff2F80ED),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : sendMessage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 22),
                    ),
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

// ── Typing Dots Widget ──────────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3 + 0.7 * _controllers[i].value),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}