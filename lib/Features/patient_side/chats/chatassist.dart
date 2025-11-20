
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core2/constants/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Chatassist extends StatefulWidget {
  const Chatassist({super.key});

  @override
  State<Chatassist> createState() => _ChatassistState();
}
class _ChatassistState extends State<Chatassist> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final ScrollController scrollController = ScrollController(); // 👈 إضافة ScrollController

@override
void initState() {
  super.initState();
  loadMessages(); // تحميل الرسائل عند البداية
  _addInitialBotMessage(); // إضافة رسالة البوت الأولية
}

void _addInitialBotMessage() {
  // تحقق إذا كانت الرسائل فارغة
  if (messages.isEmpty) {
    messages.add({
      "text": "Hello! I'm your healthcare assistant. How can I help you today?",
      "isUser": false,
      "image": null,
      "timestamp": DateTime.now().toString(),
    });
    saveMessages(); // حفظ الرسائل
    setState(() {});

    // النزول لآخر رسالة
    _scrollToBottom();
  }
}


  // ---------- حفظ الرسائل ----------
  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encoded = messages.map((msg) => jsonEncode(msg)).toList();
    prefs.setStringList("chat_messages", encoded);
  }

  // ---------- تحميل الرسائل ----------
  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList("chat_messages");

    if (saved != null) {
      messages.clear();
      messages.addAll(saved.map((msg) => jsonDecode(msg)));
      setState(() {});

      // 👈 النزول تلقائيًا لآخر رسالة بعد تحميلها
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  // ---------- النزول لآخر رسالة ----------
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

  // ---------- إرسال رسالة نصية ----------
  void sendMessage() {
    if (controller.text.trim().isEmpty) return;

    messages.add({
      "text": controller.text.trim(),
      "isUser": true,
      "image": null,
      "timestamp": DateTime.now().toString(),
    });

    controller.clear();
    saveMessages();
    setState(() {});
    _scrollToBottom(); // 👈 النزول لآخر رسالة

    Future.delayed(const Duration(milliseconds: 500), () {
      messages.add({
        "text":
            "I'm here to help with any questions about your medications, appointments, or health reports. How can I assist you?",
        "isUser": false,
        "image": null,
        "timestamp": DateTime.now().toString(),
      });

      saveMessages();
      setState(() {});
      _scrollToBottom(); // 👈 النزول بعد رد المساعد
    });
  }

  // ---------- التقاط صورة من الكاميرا ----------
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

  // ---------- اختيار صورة من المعرض ----------
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

  // ---------- عرض الصورة بالحجم الكامل ----------
  void showFullImage(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(child: Image.file(File(path))),
        ),
      ),
    );
  }

  // ---------- تنسيق الوقت ----------
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

  // إذا الكيبورد مفتوح (bottomInset > 0) نزّل للآخر
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
      
      backgroundColor:  Colors.white,

      // appBar: AppBar(
      //   foregroundColor: Colors.white,
      //   shadowColor: Colors.white,
      //   toolbarHeight: 80,
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Container(width: 33,height: 33,

      //       child:
      //      const Icon(Icons.arrow_back, size: 18,
      //      color: Colors.black
      //      )
      //      ,decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(8),
      //       border: BoxBorder.all(color: Colors.grey)),),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: Text(
      //     "Chat Assistant",
      //     style: TextStyle(
      //         color: AppColors.blueColor,
      //         fontSize: 18,
      //         fontWeight: FontWeight.bold),
      //   ),
      // ),

      body: Padding(
        padding: const EdgeInsets.only(left:0 ,right: 0),
        child: Column(

          children: [
            SizedBox(height: 50,),

            Container(
              color: Colors.white,
              child: Row(children: [
                
                
                IconButton(
                        icon: Container(width: 33,height: 33,
              
              child:
                         const Icon(Icons.arrow_back, size: 18,
                         color: Colors.black
                         )
                         ,decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: BoxBorder.all(color: Colors.grey)),),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "Chat Assistant",
                        style: TextStyle(
                color: AppColors.blueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
                      ),
              
              
              ],),
            ),


            SizedBox(height: 20,),
            Expanded(
              child: Container(
                            color: const Color(0xffF7F7F7), // خلي لون الخلفية هنا جراي

                child: ListView.builder(
                  
                  controller: scrollController, // 👈 ربط ScrollController
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isUser = msg["isUser"];
                        
                    return Container(
                            // backgroundColor: const Color(0xffF7F7F7),
                
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
                              child: const Icon(Icons.smart_toy,
                                  size: 22, color: Colors.blue),
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
                              crossAxisAlignment:
                                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // النص أو الصورة
                                msg["image"] != null
                                    ? GestureDetector(
                      onTap: () => showFullImage(msg["image"]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(msg["image"]),
                          width: 200,
                        ),
                      ),
                                      )
                                    : Text(
                      msg["text"] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 15,
                        height: 1.4,
                      ),
                                      ),
                                const SizedBox(height: 4), // مسافة بسيطة بين الرسالة والوقت
                                Text(
                                  formatTime(msg["timestamp"]),
                                  style: TextStyle(fontSize: 11, color:isUser? Colors.white:Colors.grey),
                                ),
                              ],
                                  ),
                                ),
                              )
                      // ,    SizedBox(height: 20,),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        
            // -------- الكتابة والإرسال --------
            Container(
              height: 85,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                      Container(width:40 ,height: 40,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),border: Border.all(                            color: const Color.fromARGB(255, 228, 219, 219))),
                        child: IconButton(
                                            onPressed: pickGallery,
                                            icon: const Icon(Icons.photo_outlined, size: 20),
                                          ),
                      ),
                      SizedBox(width: 10,),
                  Container(width: 40,height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),border: Border.all(                            color: const Color.fromARGB(255, 228, 219, 219))),
                    child: IconButton(
                      onPressed: pickCamera,
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
                          controller: controller,
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
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white, size: 22),
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
