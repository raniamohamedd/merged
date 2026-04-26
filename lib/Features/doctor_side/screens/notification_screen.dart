import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chat_details_screen.dart' hide AppColors;
import 'package:flutter_application_2/Features/doctor_side/screens/patient_detailsdoc.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

class DoctorNotificationItem {
  
  final String title;
  final String subtitle;
  final String time;
  final String type;
  final bool isUnread;
  final String patientName;
  final String chatId;

  DoctorNotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.isUnread,
    required this.patientName,
    required this.chatId,
  });

  DoctorNotificationItem copyWith({
    String? title,
    String? subtitle,
    String? time,
    String? type,
    bool? isUnread,
    String? patientName,
    String? chatId,
  }) {
    return DoctorNotificationItem(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      patientName: patientName ?? this.patientName,
      chatId: chatId ?? this.chatId,
    );
  }
}

class NotificationsPageDoctor extends StatefulWidget {
  const NotificationsPageDoctor({super.key});

  @override
  State<NotificationsPageDoctor> createState() =>
      _NotificationsPageDoctorState();
}

class _NotificationsPageDoctorState extends State<NotificationsPageDoctor> {
  String selectedFilter = "all";
@override
void initState() {
  super.initState();
  loadRequests();
}
  late List<DoctorNotificationItem> notifications = [
  ];
  bool isloading=true;
Future<void> loadRequests() async {
  try {
    final data = await ApiService.getDoctorRequests();
    print(data);

    setState(() {
      notifications = data;
      isloading = false;
    });
  } catch (e) {
    setState(() {
      isloading = false;
    });
    print(e);
  }
}
  List<DoctorNotificationItem> get filteredNotifications {
    if (selectedFilter == "all") return notifications;
    if (selectedFilter == "unread") {
      return notifications.where((e) => e.isUnread).toList();
    }
    return notifications.where((e) => e.type == selectedFilter).toList();
  }

  IconData getNotificationIcon(String type) {
    switch (type) {
      case "request":
        return Icons.person_add_alt_1_rounded;
      case "emergency":
        return Icons.warning_amber_rounded;
      case "message":
        return Icons.chat_bubble_outline_rounded;
      case "medication":
        return Icons.medication_outlined;
      case "symptom":
        return Icons.monitor_heart_outlined;
      case "success":
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color getNotificationColor(String type) {
    switch (type) {
      case "request":
        return Colors.blue;
      case "emergency":
        return Colors.red;
      case "message":
        return Colors.indigo;
      case "medication":
        return Colors.orange;
      case "symptom":
        return Colors.purple;
      case "success":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void markAllAsRead() {
    setState(() {
      notifications = notifications
          .map((e) => e.copyWith(isUnread: false))
          .toList();
    });
  }

  void markOneAsRead(DoctorNotificationItem item) {
    final index = notifications.indexOf(item);
    if (index != -1) {
      setState(() {
        notifications[index] = notifications[index].copyWith(isUnread: false);
      });
    }
  }

  void removeNotification(DoctorNotificationItem item) {
    setState(() {
      notifications.remove(item);
    });
  }

  void handleNotificationTap(DoctorNotificationItem item) {
    if (item.type == "request") {
      showRequestActionSheet(item);
      return;
    } 

    markOneAsRead(item);

    if (item.type == "message") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatsPageDoctor(doctorName: 'Dr. John Smith', chatId: '')
        ),
      );
      return;
    }

    if (item.type == "medication" ||
        item.type == "symptom" ||
        item.type == "emergency" ||
        item.type == "success") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailsPage(patientId: '',),
        ),
      );
      return;
    }
  }

  void showRequestActionSheet(DoctorNotificationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.blueColor.withOpacity(.10),
                child:
                

         
                IconButton(       
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientDetailsPage(patientId: item.chatId,),
                      ),
                    );
                  }, icon:  Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.blueColor,
                  size: 28,
                ),)
                
                
              ),
                            const SizedBox(height: 8),

           ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14,horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientDetailsPage(patientId: item.chatId,),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_outline),
                  label: const Text("View Patient Details"),
                ),
              const SizedBox(height: 14),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: 
                   () async {
  await ApiService.rejectRequest(item.chatId);

  Navigator.pop(context);

  setState(() {
    notifications.remove(item);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Connection request from ${item.patientName} declined",
      ),
      backgroundColor: Colors.red,
    ),
  );
},
child: const Text(
  "Decline",
  style: TextStyle(fontWeight: FontWeight.w600),
),   
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                     onPressed: () async {
  await ApiService.acceptRequest(item.chatId);

  Navigator.pop(context);

  setState(() {
    notifications.remove(item);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Connection request from ${item.patientName} accepted",
      ),
      backgroundColor: AppColors.blueColor,
    ),
  );
},
child: const Text(
  "Accept",
  style: TextStyle(fontWeight: FontWeight.w600),
),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.blueColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget buildNotificationCard(DoctorNotificationItem item) {
    final color = getNotificationColor(item.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isUnread
              ? color.withOpacity(.25)
              : Colors.grey.shade200,
          width: item.isUnread ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => handleNotificationTap(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  getNotificationIcon(item.type),
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: item.isUnread
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (item.isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.blueColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.time,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(.10),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            item.type[0].toUpperCase() + item.type.substring(1),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((e) => e.isUnread).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FAFC),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.blueColor),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: AppColors.blueColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: markAllAsRead,
            child: Text(
              "Mark all read",
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Container(
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
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
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
                          "Doctor Notifications",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "You have $unreadCount unread notifications",
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
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                buildFilterChip("All", "all"),
                const SizedBox(width: 8),
                buildFilterChip("Unread", "unread"),
                const SizedBox(width: 8),
                buildFilterChip("Requests", "request"),
                const SizedBox(width: 8),
                buildFilterChip("Emergency", "emergency"),
                const SizedBox(width: 8),
                buildFilterChip("Messages", "message"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Text(
                      "No notifications found",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return buildNotificationCard(
                        filteredNotifications[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}