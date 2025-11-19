import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/appointment/widgets/canceled.dart';
import 'package:flutter_application_2/Features/doctor_side/appointment/widgets/completed.dart';
import 'package:flutter_application_2/Features/doctor_side/appointment/widgets/upcoming.dart';
import '../../../core/constants/colors.dart';

class DoctorAppointment extends StatelessWidget {
  const DoctorAppointment({super.key, this.initialTabIndex = 0});

  /// 🟢 متغير لتحديد التبويب اللي نبدأ منه (مثلاً 0 = Upcoming)
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          title: const Text(
            "My Appointments",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.blueColor,
            unselectedLabelColor: AppColors.greyColor,
            indicatorColor: AppColors.blueColor,
            labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Canceled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Upcoming(), // ✅ التبويب الأول
             Completed(), // ✅ التبويب الثاني
             Canceled(),  // ✅ التبويب الثالث
          ],
        ),
        backgroundColor: AppColors.whiteColor,
      ),
    );
  }
}