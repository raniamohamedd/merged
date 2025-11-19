import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/Features/patient_side/chats/chatassist.dart';
import 'package:flutter_application_2/Features/patient_side/chats/view/chats_list_screen.dart';
import 'package:flutter_application_2/Features/patient_side/notification/notification_screen.dart';
import 'package:flutter_application_2/Features/patient_side/profile/view/profile_view.dart';
import 'package:flutter_application_2/core2/constants/colors.dart';

class HeaderWidget extends StatefulWidget {
  final ValueChanged<String>? onUserNameLoaded;
  // 👆 دي دالة callback ترجع اسم المستخدم بعد تحميله

  const HeaderWidget({Key? key, this.onUserNameLoaded}) : super(key: key);

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  String userName = '';
  bool hasNewNotification = true; // مؤقت لحين الربط بفايربيز Notifications

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final name = (data?['name'] as String?)?.trim() ?? 'User';

        setState(() {
          userName = name;
        });

        // ✅ نرجع الاسم للصفحة اللي استخدمت الودجت
        if (widget.onUserNameLoaded != null) {
          widget.onUserNameLoaded!(name);
        }
      } else {
        setState(() => userName = 'User');
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching user data: $e');
      setState(() => userName = 'User');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 👋 الترحيب بالمستخدم (UI)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Patient Dashboard",
                style:  TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color:AppColors.blueColor,
                ),
              ),
              const SizedBox(height: 5),
              // const Text(
              //   "Welcome back 👋",
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors.grey,
              //   ),
              // ),
            ],
          ),

          // 🔔 زر الإشعارات
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.chat,
                    size: 28,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Chatassist(),
                      ),
                    );
                  },
                ),
              ),

              // 🔴 النقطة الحمراء (تنبيه جديد)
              if (hasNewNotification)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
