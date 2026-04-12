enum MessageType { text, image, audio }

class Message {
  final String text;
  final bool isMe;
  final String time;
  final MessageType type;
  final String? filePath;

  Message({
    required this.text,
    required this.isMe,
    required this.time,
    required this.type,
    this.filePath,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] ?? '',
      isMe: json['isMe'] ?? false,
      time: json['time'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      filePath: json['filePath'],
    );
  }
}