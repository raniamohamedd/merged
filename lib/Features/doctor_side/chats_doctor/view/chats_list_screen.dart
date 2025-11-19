import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chat_details_screen.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class ChatsListScreenDoctor extends StatefulWidget {
  const ChatsListScreenDoctor({super.key});

  @override
  State<ChatsListScreenDoctor> createState() => _ChatsListScreenDoctorState();
}

class _ChatsListScreenDoctorState extends State<ChatsListScreenDoctor> {
  User? currentUser;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void _filterChats(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentUserId = currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: const Text(
          "Chats",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              decoration: BoxDecoration(
                color: AppColors.greyColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterChats,
                decoration: const InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(CupertinoIcons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Active Now",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),


            SizedBox(
              height: 85,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('doctorId', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No active patients."));
                  }

                  final activeChats = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name =
                        (data['patientName'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: activeChats.length,
                    itemBuilder: (context, index) {
                      final data =
                          activeChats[index].data() as Map<String, dynamic>;
                      final chatId = activeChats[index].id;
                      final patientId = data['patientId'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(patientId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const SizedBox();
                          }

                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          final patientName = userData['name'] ?? 'Unknown';
                          final patientImage =
                              userData['image'] ?? 'lib/images/patientt.png';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatsPageDoctor(
                                    chatId: chatId,
                                    chatName: patientName,
                                    doctorName: patientName,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 33,
                                    backgroundImage: patientImage
                                            .toString()
                                            .startsWith('http')
                                        ? NetworkImage(patientImage)
                                        : AssetImage(patientImage)
                                            as ImageProvider,
                                  ),
                                  Positioned(
                                    top: .1,
                                    right: .1,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.greenColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.whiteColor,
                                            width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Messages",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('doctorId', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No chats yet."));
                  }

                  final chats = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name =
                        (data['patientName'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  chats.sort((a, b) {
                    final aTime = (a.data() as Map<String, dynamic>)['updatedAt'] ??
                        (a.data() as Map<String, dynamic>)['createdAt'];
                    final bTime = (b.data() as Map<String, dynamic>)['updatedAt'] ??
                        (b.data() as Map<String, dynamic>)['createdAt'];
                    if (aTime is Timestamp && bTime is Timestamp) {
                      return bTime.compareTo(aTime);
                    }
                    return 0;
                  });

                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final data = chats[index].data() as Map<String, dynamic>;
                      final chatId = chats[index].id;
                      final patientId = data['patientId'];
                      final lastMessage =
                          data['lastMessage'] ?? "Say hi 👋";
                      final unreadCount = data['unreadCount'] ?? 0;
                      final timestamp = data['updatedAt'] ?? data['createdAt'];
                      String time = "";

                      if (timestamp is Timestamp) {
                        final date = timestamp.toDate();
                        time =
                            "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(patientId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const SizedBox();
                          }

                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          final patientName = userData['name'] ?? 'Unknown';
                          final patientImage =
                              userData['image'] ?? 'lib/images/patientt.png';

                          return ChatTile(
                            name: patientName,
                            lastMessage: lastMessage,
                            time: time,
                            image: patientImage,
                            unreadCount: unreadCount,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatsPageDoctor(
                                    chatId: chatId,
                                    chatName: patientName,
                                    doctorName: patientName,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
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
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.image,
    required this.unreadCount,
    required this.onTap,
  });

  bool get isPhotoMessage {
    final msg = lastMessage.toLowerCase();
    return msg == 'photo' ||
        msg.contains('image') ||
        msg.contains('.jpg') ||
        msg.contains('.png');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: image.toString().startsWith('http')
                    ? NetworkImage(image)
                    : AssetImage(image) as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Unknown',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (isPhotoMessage)
                      Row(
                        children: [
                          Icon(Icons.photo,
                              size: 16, color: AppColors.greyColor),
                          const SizedBox(width: 5),
                          Text(
                            "Photo",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: 210,
                        child: Text(
                          lastMessage.isNotEmpty ? lastMessage : 'Say hi 👋',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.greyColor,
                            height: 1.7,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    time.isNotEmpty ? time : '',
                    style: TextStyle(fontSize: 12, color: AppColors.greyColor),
                  ),
                  const SizedBox(height: 38),
                  if (unreadCount > 0)
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.blueColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: TextStyle(
                            color: AppColors.whiteColor, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
