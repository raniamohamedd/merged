import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/models/appiontment_model.dart';
import 'package:flutter_application_2/shared/user_session.dart';

class Upcoming extends StatelessWidget {
  const Upcoming({super.key});

  @override
  Widget build(BuildContext context) {
    final String doctorId = UserSession.currentDoctor?.doctorId ?? '';
    final CollectionReference appointmentsRef =
    FirebaseFirestore.instance.collection('appointments');
    final CollectionReference notificationsRef =
    FirebaseFirestore.instance.collection('notifications');

    // ✅ دالة لإرسال إشعار إلى المريض
    Future<void> addNotification(String patientId, String title, String body) async {
      await notificationsRef.add({
        'receiverId': patientId,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // ✅ دالة لإلغاء الموعد + إشعار المريض
    Future<void> cancelAppointment(AppointmentModel appointment, BuildContext context) async {
     
      try {
        final docRef = appointmentsRef.doc(appointment.appointmentId);
        await docRef.update({'status': 'canceled'});

        await addNotification(
          appointment.patientId,
          'Appointment Canceled',
          'Dr. ${UserSession.currentDoctor?.name ?? 'Your doctor'} canceled your appointment scheduled on '
              '${appointment.appointmentDate.day}/${appointment.appointmentDate.month} at ${appointment.appointmentTime}.',
        );


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment canceled & notification sent")),
        );
      } 
      catch (e) {
        debugPrint('❌ Error canceling appointment: $e');
      }
    }

    // ✅ دالة لتعيين الموعد كمكتمل + إشعار المريض
    Future<void> completeAppointment(AppointmentModel appointment, BuildContext context) async {
      try {
        final docRef = appointmentsRef.doc(appointment.appointmentId);
        await docRef.update({'status': 'done'});

        await addNotification(
          appointment.patientId,
          'Appointment Completed',
          'Dr. ${UserSession.currentDoctor?.name ?? 'Your doctor'} marked your appointment as completed.',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment done & notification sent")),
        );
      } catch (e) {
        debugPrint('❌ Error completing appointment: $e');
      }
    }

    // ✅ جلب كل المواعيد
    Stream<List<AppointmentModel>> getAllAppointments() {
      return appointmentsRef.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) =>
            AppointmentModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    }

    // ✅ واجهة المستخدم
    return StreamBuilder<List<AppointmentModel>>(
      stream: getAllAppointments(),
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No upcoming appointments yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final doctorAppointments = snapshot.data!
            .where((app) => app.doctorId == doctorId && app.status == 'upcoming')
            .toList();

        if (doctorAppointments.isEmpty) {
          return const Center(
            child: Text(
              "No upcoming appointments yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: doctorAppointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 7),
          itemBuilder: (context, index) {
            final appointment = doctorAppointments[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppColors.greyColor.withOpacity(0.8),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('lib/images/img.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                appointment.appointmentType,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                "${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year} | ${appointment.appointmentTime}",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ❌ Cancel
                        OutlinedButton(
                          onPressed: () =>
                              cancelAppointment(appointment, context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 35),
                            side: BorderSide(color: AppColors.blueColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: AppColors.blackColor),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ✅ Done
                        ElevatedButton(
                          onPressed: () =>
                              completeAppointment(appointment, context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueColor,
                            minimumSize: const Size(120, 35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Done",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}