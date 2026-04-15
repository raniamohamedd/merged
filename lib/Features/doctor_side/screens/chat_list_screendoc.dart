import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chat_details_screen.dart' hide AppColors;
import 'package:flutter_application_2/core/constants/colors.dart';

class DoctorChat {
  final String name;
  final String lastMessage;
  final String time;
  final String image;
  final int unreadCount;
  final bool isOnline;
  final String chatId;

  DoctorChat({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.image,
    required this.unreadCount,
    required this.isOnline,
    required this.chatId,
  });
}

final List<DoctorChat> staticDoctors = [
  DoctorChat(
    name: "John Doe",
    lastMessage: "Please take the medicine after meals",
    time: "10:20 AM",
    image: "lib/images/doc1(chat).jpg",
    unreadCount: 1,
    isOnline: true,
    chatId: "chat_1",
  ),
  DoctorChat(
    name: "Mary Smith",
    lastMessage: "Your test results look normal",
    time: "09:45 AM",
    image: "lib/images/doc2(chat).jpg",
    unreadCount: 0,
    isOnline: true,
    chatId: "chat_2",
  ),
  DoctorChat(
    name: "Michael Lee",
    lastMessage: "Don't forget your follow-up appointment",
    time: "Yesterday",
    image: "lib/images/doc3(chat).jpg",
    unreadCount: 1,
    isOnline: false,
    chatId: "chat_3",
  ),
  DoctorChat(
    name: "Olivia Wilson",
    lastMessage: "I have updated your prescription",
    time: "Mon",
    image: "lib/images/doc4(chat).jpg",
    unreadCount: 3,
    isOnline: true,
    chatId: "chat_4",
  ),
];

class ChatsListScreenDoctor extends StatefulWidget {
  const ChatsListScreenDoctor({super.key});

  @override
  State<ChatsListScreenDoctor> createState() => _ChatsListScreenDoctorState();
}

class _ChatsListScreenDoctorState extends State<ChatsListScreenDoctor> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  List<DoctorChat> get filteredDoctors {
    return staticDoctors.where((d) {
      return d.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          d.lastMessage.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  int get unreadChatsCount =>
      staticDoctors.where((e) => e.unreadCount > 0).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget buildTopCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chats",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$unreadChatsCount unread conversations",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Search chats...",
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(CupertinoIcons.search, color: AppColors.blueColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
              child: buildTopCard(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSearchBox(),
                    const SizedBox(height: 18),
                    Text(
                      "Messages",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.blueColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    filteredDoctors.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                "No chats found",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredDoctors.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final doctor = filteredDoctors[index];

                              return ChatTile(
                                name: doctor.name,
                                lastMessage: doctor.lastMessage,
                                time: doctor.time,
                                image: doctor.image,
                                unreadCount: doctor.unreadCount,
                                isOnline: doctor.isOnline,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatsPageDoctor(
                                        doctorName: doctor.name,
                                        chatId: doctor.chatId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String image;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.image,
    required this.unreadCount,
    required this.isOnline,
    required this.onTap,
  });

  String getInitials(String text) {
    final parts = text.trim().split(" ");
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : "C";
    }
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF0F2F5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.03),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.blueColor.withOpacity(.10),
                      backgroundImage: AssetImage(image),
                      onBackgroundImageError: (_, __) {},
                      // child: Text(
                      //   getInitials(name),
                      //   style: TextStyle(
                      //     color: AppColors.blueColor,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 16,
                      //   ),
                      // ),
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: -1,
                        right: -1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (unreadCount > 0)
                      Container(
                        constraints: const BoxConstraints(
                          minWidth: 22,
                          minHeight: 22,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}