// ══════════════════════════════════════════════════════════════════════════════
// lib/Features/patient_side/home_screen/widget/header.dart
// ══════════════════════════════════════════════════════════════════════════════
//
// التعديل: أضفنا أيقونة "My Doctors" جنب أيقونة الشات بوت في الـ Header
// الـ import الجديد المطلوب:
//   import 'package:flutter_application_2/Features/patient_side/my_doctors/my_doctors_screen.dart';
//
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/doctors_screen.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
// 👇 أضف الـ import ده
// 👇 import الـ chatbot screen بتاعك (اعدّل المسار حسب مشروعك)
// import 'package:flutter_application_2/Features/patient_side/chatbot/chatassist.dart';

// ── HeaderWidget ──────────────────────────────────────────────────────────────

class HeaderWidget extends StatefulWidget {
  final Function(String)? onUserNameLoaded;

  const HeaderWidget({super.key, this.onUserNameLoaded});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  String userName = 'User';
  bool hasNewNotification = false;

  // أضف هنا أي logic لجلب اسم المستخدم من الـ API

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 👋 عنوان الداشبورد
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Patient Dashboard",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueColor,
                ),
              ),
            ],
          ),

          // 🔵 الأيقونتين جنب بعض
          Row(
            children: [
              // ── أيقونة My Doctors (الجديدة) ──────────────────────────
              _HeaderIconButton(
                icon: Icons.people_alt_rounded,
                tooltip: "My Doctors",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyDoctorsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(width: 10),

              // ── أيقونة الشات بوت (الموجودة) ──────────────────────────
              Stack(
                children: [
                  _HeaderIconButton(
                    icon: Icons.chat,
                    tooltip: "Chat Assistant",
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const Chatassist(),
                      //   ),
                      // );
                    },
                  ),
                  // 🔴 النقطة الحمراء (لو في إشعار)
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
        ],
      ),
    );
  }
}

// ── Reusable Icon Button ──────────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
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
          child: Icon(
            icon,
            size: 24,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}