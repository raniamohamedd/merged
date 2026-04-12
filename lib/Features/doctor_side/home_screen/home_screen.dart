import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/Features/doctor_side/appointment/doctor_appoinment.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import '../../../data/models/appiontment_model.dart';
import '../../../shared/user_session.dart';

class HomeScreenD extends StatelessWidget {
  HomeScreenD({super.key});

  final String doctorId = UserSession.currentDoctor?.doctorId ?? '';

  @override
  Widget build(BuildContext context) {
    final CollectionReference appointmentsRef =
    FirebaseFirestore.instance.collection('appointments');
    final CollectionReference notificationsRef =
    FirebaseFirestore.instance.collection('notifications');

    // ✅ Stream لجلب كل المواعيد
    Stream<List<AppointmentModel>> getAllAppointments() {
      return appointmentsRef.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) =>
            AppointmentModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    }

    // ✅ دالة لإضافة إشعار للمريض
    Future<void> addNotification(String patientId, String title, String body) async {
      await notificationsRef.add({
        'receiverId': patientId,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // ✅ دالة لإلغاء الموعد + إرسال إشعار
    void cancelAppointment(AppointmentModel appointment, BuildContext context) async {
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
      } catch (e) {
        debugPrint('❌ Error canceling appointment: $e');
      }
    }

    // ✅ دالة لتعيين الموعد كمكتمل + إرسال إشعار
    void completeAppointment(AppointmentModel appointment, BuildContext context) async {
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                "Hi, Dr. ${UserSession.currentDoctor?.name ?? 'Doctor'}!",
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                "How are you today?",
                style: TextStyle(color: AppColors.greyColor),
              ),
              const SizedBox(height: 20),

              // ✅ الكارد الخاصة بأقرب موعد
              StreamBuilder<List<AppointmentModel>>(
                stream: getAllAppointments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox(
                      height: 150,
                      child: Center(child: Text("No upcoming appointments")),
                    );
                  }

                  final upcomingAppointments = snapshot.data!
                      .where((app) =>
                  app.doctorId == doctorId &&
                      app.status == 'upcoming')
                      .toList();

                  if (upcomingAppointments.isEmpty) {
                    return const SizedBox(
                      height: 150,
                      child: Center(child: Text("No upcoming appointments")),
                    );
                  }

                  final appointment = upcomingAppointments.first;

                  return Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius:
                      const BorderRadius.all(Radius.circular(20)),
                      color: AppColors.cyanColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CircleAvatar(
                                backgroundImage:
                                AssetImage('lib/images/img.png'),
                              ),
                              Column(
                                children: [
                                  Text(
                                    appointment.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.whiteColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    appointment.appointmentType,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                backgroundColor: AppColors.whiteColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.asset(
                                    "lib/images/message-text.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                              color: AppColors.darkBlueColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month,
                                      color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    "${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year} | ${appointment.appointmentTime}",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // ✅ قائمة المواعيد القادمة
              Row(
                children: [
                  const Text(
                    "Upcoming Appointments",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DoctorAppointment()),
                      );
                    },
                    child: Text("See All",
                        style: TextStyle(color: AppColors.blueColor)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<AppointmentModel>>(
                stream: getAllAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
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
                      .where((app) =>
                  app.doctorId == doctorId &&
                      app.status == 'upcoming')
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
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctorAppointments.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 7),
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
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                    AssetImage('lib/images/img.png'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appointment.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          appointment.appointmentType,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          "${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year} | ${appointment.appointmentTime}",
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, bottom: 5, top: 5),
                                child: Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          cancelAppointment(appointment, context),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize:
                                        const Size(120, 35),
                                        side: BorderSide(
                                            color: AppColors.blueColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                            color: AppColors.blackColor),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () =>
                                          completeAppointment(appointment, context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        AppColors.blueColor,
                                        minimumSize:
                                        const Size(120, 35),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: const Text(
                                        "Done",
                                        style: TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}