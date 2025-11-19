import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'chat_details_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenPatientState();
}

class _ChatsListScreenPatientState extends State<ChatsListScreen> {
  User? currentUser;
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
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }



    final currentUserId = currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        toolbarHeight: 100,
        title:  Text(
          "Message",
          style: TextStyle(color: AppColors.blackColor,fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(height: 60,
              decoration: BoxDecoration(
                color: AppColors.greyColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                onChanged: _filterChats,
                decoration: const InputDecoration(
                  hintText: "Search doctors",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          SizedBox(height: 40,),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('patientId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['doctorName'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                chats.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['updatedAt'] ??
                      (a.data() as Map<String, dynamic>)['createdAt'];
                  final bTime = (b.data() as Map<String, dynamic>)['updatedAt'] ??
                      (b.data() as Map<String, dynamic>)['createdAt'];
                  if (aTime is Timestamp && bTime is Timestamp) return bTime.compareTo(aTime);
                  return 0;
                });

                if (chats.isEmpty) {
                  return const Center(child: Text("No chats yet"));
                }
                  
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final data = chats[index].data() as Map<String, dynamic>;
                    final chatId = chats[index].id;
                    final doctorName = data['doctorName'] ?? 'Unknown';

final lastMessage = data['lastMessage'];
final displayMessage = (lastMessage == null || lastMessage.isEmpty) 
    ? 'Say hi 👋' 
    : lastMessage;                    final unreadCount = data['unreadCountForPatient'] ?? 0;
                    final chatTime = data['updatedAt'] != null
                        ? (data['updatedAt'] as Timestamp).toDate()
                        : DateTime.now();

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatsPagePatient(
                                chatId: chatId, chatName: doctorName, doctorName: doctorName),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                        child: Column(
                          children: [
                      Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('doctors')
          .doc(data['doctorId'])
          .get(),
      builder: (context, snapshotDoctor) {
        String speciality = 'General';
        String hospital = 'hospital';
        String imagee = 'lib/images/patientt.png'; 
        String doctorImage = data['doctorImage'] ?? '';

        if (snapshotDoctor.hasData && snapshotDoctor.data!.exists) {
          final doctorData = snapshotDoctor.data!.data() as Map<String, dynamic>;
          speciality = doctorData['specialization'] ?? 'General';
          hospital = doctorData['hospital'] ?? 'hospital';
          imagee = doctorData['imageUrl'] ?? 'lib/images/patientt.png';
        }

        final imageToUse = (doctorImage.isEmpty) ? doctorImage : imagee;

        return Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: _getDoctorImage(imageToUse),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. $doctorName',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      speciality,
                      style: TextStyle(fontSize: 13, color: AppColors.greyColor),
                    ),
                    const SizedBox(width: 5),
                    const Text('|'),
                    const SizedBox(width: 5),
                    Text(
                      hospital,
                      style: TextStyle(fontSize: 13, color: AppColors.greyColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 210,
                  child: Text(
                    displayMessage,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyColor,
                        height: 1.7),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
    
    
    
    
    
    
    
    
    
    
    
    const Spacer(),
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${chatTime.hour}:${chatTime.minute.toString().padLeft(2,'0')}",
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
      const SizedBox(height: 10),
                            const Divider(height: 20, endIndent: 10, indent: 10,thickness: .6,),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

ImageProvider _getDoctorImage(dynamic imagePath) {
  if (imagePath == null || imagePath.toString().isEmpty) {
    return const AssetImage('lib/images/patientt.png');
  }

  final image = imagePath.toString();

  if (image.startsWith('http')) {
    return NetworkImage(image);
  } else if (image.startsWith('lib/images/')) {
    return AssetImage(image);
  } else {
    return const AssetImage('lib/images/patientt.png');
  }
}



}