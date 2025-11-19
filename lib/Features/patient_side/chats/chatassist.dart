import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class Chatassist extends StatefulWidget {
const Chatassist({super.key});

@override
State<Chatassist> createState() => _ChatUIState();
}

class _ChatUIState extends State<Chatassist> {
final TextEditingController _controller = TextEditingController();
bool _isEmojiVisible = false;
bool _hasText = false;

void _toggleEmojiPicker() {
setState(() {
_isEmojiVisible = !_isEmojiVisible;
});
}

@override
void initState() {
super.initState();
_controller.addListener(() {
setState(() {
_hasText = _controller.text.trim().isNotEmpty;
});
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
  backgroundColor: Colors.white,
appBar: AppBar(
  backgroundColor: Colors.white,
  toolbarHeight: 100,
// backgroundColor: AppColors.blueColor,
title: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children:  [
Text('Chat Assistant', style: TextStyle(color: AppColors.blueColor,fontSize: 20,fontWeight: FontWeight.bold)),
// Text('Online', style: TextStyle(fontSize: 12)),
],
),
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_rounded),
onPressed:   () => Navigator.pop(context),
),

),
// extendBodyBehindAppBar: true,
body: Column(
children: [
Expanded(
child: ListView.builder(
reverse: true,
padding: const EdgeInsets.all(10),
itemCount: 10, // dummy messages
itemBuilder: (context, index) {
bool isMe = index % 2 == 0;
return Align(
alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
child: Container(
margin: const EdgeInsets.symmetric(vertical: 6),
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: isMe ? Colors.blue : Colors.grey[200],
borderRadius: BorderRadius.circular(16),
),
child: Text(
isMe ? "Hello, how are you?" : "Hi! I'm fine, thanks!",
style: TextStyle(color: isMe ? Colors.white : Colors.black),
),
),
);
},
),
),
const Divider(height: 1),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
child: Row(
children: [
IconButton(
icon: const Icon(Icons.emoji_emotions_outlined),
onPressed: _toggleEmojiPicker,
),
Expanded(
child: TextField(
controller: _controller,
decoration: const InputDecoration(
hintText: "Type a message...",
border: InputBorder.none,
),
),
),
IconButton(
icon: const Icon(Icons.attach_file),
onPressed: () {},
),
IconButton(
icon: const Icon(CupertinoIcons.camera_fill),
onPressed: () {},
),
CircleAvatar(
radius: 24,
backgroundColor: Colors.blue,
child: IconButton(
icon: Icon(_hasText ? Icons.send : Icons.mic, color: Colors.white),
onPressed: () {},
),
),
],
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
),
);
}
}
