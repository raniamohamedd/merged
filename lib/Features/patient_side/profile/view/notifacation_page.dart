import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/shared/custom_appbar.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/notification/notification_Row.dart';

class NotifacationPage extends StatelessWidget {
  const NotifacationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Notification", textColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            NotificationRow(title: "App Notification"),
            SizedBox(height: 10),
            Divider(color: Colors.grey, thickness: 0.2),
            NotificationRow(title: "Sound"),
            SizedBox(height: 10),
            Divider(color: Colors.grey, thickness: 0.2),
            NotificationRow(title: "Vibration"),
            SizedBox(height: 10),
            Divider(color: Colors.grey, thickness: 0.2),
            NotificationRow(title: "New Updates"),
            SizedBox(height: 10),
            Divider(color: Colors.grey, thickness: 0.2),
            NotificationRow(title: "Special Offers"),
            SizedBox(height: 10),
            Divider(color: Colors.grey, thickness: 0.2),
          ],
        ),
      ),
    );
  }
}
