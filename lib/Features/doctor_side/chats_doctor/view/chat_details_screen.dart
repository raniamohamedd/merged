import 'package:flutter/material.dart';

/// ---------------- ENUM ----------------
enum MessageType { text, image, audio }

/// ---------------- MODEL ----------------
class ChatMessage {
  final String text;
  final bool isMe;
  final MessageType type;
  final String time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.type,
    required this.time,
  });
}

/// ---------------- COLORS ----------------
class AppColors {
  static const blueColor = Color(0xFF1976D2);
  static const whiteColor = Colors.white;
  static const greyColor = Colors.grey;
  static const blackColor = Colors.black;
}

/// ---------------- SCREEN ----------------
class ChatsPageDoctor extends StatefulWidget {
  final String doctorName;

  const ChatsPageDoctor({
    super.key,
    required this.doctorName,
    required String chatId, // موجود عشان ما يكسرش الكود القديم
  });

  @override
  State<ChatsPageDoctor> createState() => _ChatsPageDoctorState();
}

class _ChatsPageDoctorState extends State<ChatsPageDoctor> {
  final ScrollController _scrollController = ScrollController();

  /// 🔹 Static Messages
  final List<ChatMessage> messages = [
    ChatMessage(
      text: "Plese take the medicine after meals",
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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.insert(
        0,
        ChatMessage(
          text: text,
          isMe: true,
          type: MessageType.text,
          time: TimeOfDay.now().format(context),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        children: [
          /// 🔹 App Bar
          Container(
            padding: EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctorName,
                      style: const TextStyle(color: AppColors.blueColor,
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Online",
                      style: TextStyle(
                          fontSize: 12, color: AppColors.greyColor),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// 🔹 Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment:
                      msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: msg.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg.isMe
                              ? AppColors.blueColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isMe
                                ? Colors.white
                                : AppColors.blackColor,
                          ),
                        ),
                      ),
                      Text(
                        msg.time,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.greyColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// 🔹 Input
          ChatInput(
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// ---------------- INPUT ----------------
class ChatInput extends StatefulWidget {
  final Function(String) onSend;

  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _showEmoji = false;

  void _send() {
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return      Container(
              height: 85,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                      Container(width:40 ,height: 40,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),border: Border.all(                            color: const Color.fromARGB(255, 228, 219, 219))),
                        child: IconButton(
                                            onPressed: (){},
                                            icon: const Icon(Icons.photo_outlined, size: 20),
                                          ),
                      ),
                      SizedBox(width: 10,),
                  Container(width: 40,height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),border: Border.all(                            color: const Color.fromARGB(255, 228, 219, 219))),
                    child: IconButton(
                      onPressed: (){},
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    ),
                  ),
                                        SizedBox(width: 10,),

              
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 228, 219, 219)),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Type your message",
                            border: InputBorder.none,
                          ),
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
                      onPressed: (){},
                      icon: const Icon(Icons.send, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            );
            
 
  }

}
