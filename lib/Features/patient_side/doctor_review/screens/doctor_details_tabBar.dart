import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/services/firestore_services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/doctor_model.dart';
import '../widgets/doctor_header_card.dart';
import 'doctor_details_about_screen.dart';
import 'doctor_details_review_screen.dart';

class DoctorDetailsTabbarScreen extends StatelessWidget {
  const DoctorDetailsTabbarScreen({
    super.key,
    required this.docModel,
    required this.doctorId,
  });

  final String doctorId;
  final DoctorModel docModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          centerTitle: true,
          title: const Text(
            "Doctor Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          children: [
            StreamBuilder<DoctorModel>(
              stream: FirestoreService().streamDoctorData(doctorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                // ✅ الكارت العلوي لمعلومات الدكتور
                if (!snapshot.hasData || snapshot.hasError) {
                  return DoctorHeaderCard(
                    doctorId: docModel.doctorId,
                    doctorName: docModel.name,
                    specialty: docModel.specialization,
                    hospital: docModel.hospital,
                    rating: docModel.rating,
                    numberOfReviews: docModel.reviews,
                    doctorImageUrl: docModel.imageUrl,
                  );
                }

                final updatedDoctor = snapshot.data!;

                return DoctorHeaderCard(
                  doctorId: updatedDoctor.doctorId,
                  doctorName: updatedDoctor.name,
                  specialty: updatedDoctor.specialization,
                  hospital: updatedDoctor.hospital,
                  rating: updatedDoctor.rating,
                  numberOfReviews: updatedDoctor.reviews,
                  doctorImageUrl: updatedDoctor.imageUrl,
                );
              },
            ),

            // ✅ التاب بار
            TabBar(
              labelColor: AppColors.blueColor,
              unselectedLabelColor: AppColors.greyColor,
              indicatorColor: AppColors.blueColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "About"),
                Tab(text: "Reviews"),
              ],
            ),

            // ✅ محتوى كل تاب
            Expanded(
              child: TabBarView(
                children: [
                  FutureBuilder<DoctorModel>(
                    future: FirestoreService().getDoctor(doctorId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(
                          child: Text('Error loading doctor'),
                        );
                      }
                      final doctor = snapshot.data!;
                      return DoctorDetailsAboutScreen(doctor: doctor);
                    },
                  ),

                  // ✅ هنا نمرر الـ doctorId القادم من Firestore
                  DoctorDetailsReviewScreen(doctorId: doctorId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
