import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chat_details_screen.dart';

// 🔹 Colors (لو عندك AppColors استخدميه بدل ده)
class AppColors {
  static const Color blueColor = Color(0xFF1976D2);
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
  static const Color greenColor = Colors.green;
}

// 🔹 Model
class DoctorChat {
  final String name;
  final String lastMessage;
  final String time;
  final String image;
  final int unreadCount;

  DoctorChat({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.image,
    required this.unreadCount,
  });
}

// 🔹 Static Data (4 Doctors)
final List<DoctorChat> staticDoctors = [
  DoctorChat(
    name: "Dr. John Smith",
    lastMessage: "Please take the medicine after meals",
    time: "10:20 AM",
    image: "lib/images/doc1(chat).jpg",
    unreadCount: 1,
  ),
  DoctorChat(
    name: "Dr. Emma Brown",
    lastMessage: "Your test results look normal",
    time: "09:45 AM",
    image: "lib/images/doc2(chat).jpg",
    unreadCount: 0,
  ),
  DoctorChat(
    name: "Dr. Michael Lee",
    lastMessage: "Don't forget your follow-up appointment",
    time: "Yesterday",
    image: "lib/images/doc3(chat).jpg",
    unreadCount: 1,
  ),
  DoctorChat(
    name: "Dr. Olivia Wilson",
    lastMessage: "I have updated your prescription",
    time: "Mon",
    image: "lib/images/doc4(chat).jpg",
    unreadCount: 3,
  ),
];

// 🔹 Screen
class ChatsListScreenDoctor extends StatefulWidget {
  const ChatsListScreenDoctor({super.key});

  @override
  State<ChatsListScreenDoctor> createState() =>
      _ChatsListScreenDoctorState();
}

class _ChatsListScreenDoctorState extends State<ChatsListScreenDoctor> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = staticDoctors
        .where((d) =>
            d.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height:60),

            // 🔹 Title
         Center(
          child: Text(
            "Chats",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.blueColor,
            ),
          ),
                     ),

            const SizedBox(height: 20),

            // 🔹 Search
            Container(
              decoration: BoxDecoration(
                color: AppColors.greyColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(CupertinoIcons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // // 🔹 Active Now
            // const Text(
            //   "Active Now",
            //   style:
            //       TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            // ),
            // const SizedBox(height: 12),

            // SizedBox(
            //   height: 85,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: filteredDoctors.length,
            //     itemBuilder: (context, index) {
            //       final doctor = filteredDoctors[index];

            //       return Padding(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 8),
            //         child: Stack(
            //           children: [
            //             CircleAvatar(
            //               radius: 33,
            //               backgroundImage:
            //                   AssetImage(doctor.image),
            //             ),
            //             Positioned(
            //               top: 2,
            //               right: 2,
            //               child: Container(
            //                 width: 18,
            //                 height: 18,
            //                 decoration: BoxDecoration(
            //                   color: AppColors.greenColor,
            //                   shape: BoxShape.circle,
            //                   border: Border.all(
            //                       color: AppColors.whiteColor,
            //                       width: 2),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // ),

            // const SizedBox(height: 12),

            // // 🔹 Messages
            const Text(
              "Messages",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 1),

            Expanded(
              child: ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];

                  return ChatTile(
                    name: doctor.name,
                    lastMessage: doctor.lastMessage,
                    time: doctor.time,
                    image: doctor.image,
                    unreadCount: doctor.unreadCount,
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatsPageDoctor(doctorName: 'Dr. John Smith', chatId: ''),
    ),
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

// 🔹 Chat Tile
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    time,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyColor),
                  ),
                  const SizedBox(height: 20),
                  if (unreadCount > 0)
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.blueColor,
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12),
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