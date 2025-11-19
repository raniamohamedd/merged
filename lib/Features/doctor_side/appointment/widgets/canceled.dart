import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/appiontment_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/user_session.dart';

class Canceled extends StatelessWidget {
  final String doctorId = UserSession.currentDoctor?.doctorId ?? '';
  Canceled({super.key});

  final CollectionReference appointmentsRef =
  FirebaseFirestore.instance.collection('appointments');

  Stream<List<AppointmentModel>> getCanceledAppointments() {
    return appointmentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppointmentModel>>(
      stream: getCanceledAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No canceled appointments yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // ✅ تم تصحيح الفلترة لتستخدم doctorId بدل patientId
        final canceledAppointments = snapshot.data!
            .where((app) => app.doctorId == doctorId && app.status == 'canceled')
            .toList();

        if (canceledAppointments.isEmpty) {
          return const Center(
            child: Text(
              "No canceled appointments yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: canceledAppointments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 7),
          itemBuilder: (context, index) {
            final appointment = canceledAppointments[index];
            return Card(
              elevation: 2,
              color: AppColors.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppColors.greyColor,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Appointment Canceled",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff9B0A0A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year} | ${appointment.appointmentTime}",
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('lib/images/img.png'),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blackColor,
                              ),
                            ),
                            Text(
                              appointment.appointmentType,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.greyColor,
                              ),
                            ),
                          ],
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