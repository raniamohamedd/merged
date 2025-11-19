import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/appiontment_model.dart';
import '../../../../shared/user_session.dart';
import 'custom_card_appoinment.dart';

class Completed extends StatelessWidget {
   Completed({super.key});

  final String doctorId = UserSession.currentDoctor?.doctorId ?? '';

  Stream<List<AppointmentModel>> getCompletedAppointments() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
      }).where((app) => app.doctorId == doctorId && app.status == 'done').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppointmentModel>>(
      stream: getCompletedAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No completed appointments yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final completedList = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: completedList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 7),
          itemBuilder: (context, index) {
            final appointment = completedList[index];
            return CustomCardAppointment(
              appointmentStatue: "Appointment Done",
              day:
              "${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}",
              time: appointment.appointmentTime,
              color: const Color(0xff62B66F),
              name: appointment.name,
              status: appointment.appointmentType,
              imgPath: "lib/images/img.png",
            );
          },
        );
      },
    );
  }
}