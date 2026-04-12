import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/data/models/doctor_model.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import '../widgets/make_appointment_button.dart';

class DoctorDetailsAboutScreen extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorDetailsAboutScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    // UserSession.currentDoctor = doctor;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        children: [
          // ===== Main Details List =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                children: [
                  _buildSection(
                    "About Me",
                    
                    doctor.aboutMe?.isNotEmpty == true
                        ? doctor.aboutMe!
                        : "No information available.",
                  ),
                  _buildSection(
                    "Hospital Name",
                    "${doctor.hospital}",
                  ),
                  _buildSection(
                    "Working Time",
                    doctor.workingTime?.isNotEmpty == true
                        ? doctor.workingTime!
                        : "Not specified.",
                  ),
                  _buildSection("Phone number", UserSession.currentUser!.phoneNum.toString()),
                  
                  _buildSection("STR", doctor.STR.toString()),
                  _buildSection("Price", "\$${doctor.price.toStringAsFixed(2)}"),
                ],
              ),
            ),
          ),

          // ===== Appointment Button =====
          MakeAppointmentButton(
            doctorName: doctor.name,
            specialty: doctor.specialization,
            hospitalName: doctor.hospital,
            rating: doctor.rating,
            doctorImageUrl: doctor.imageUrl,
            numberOfReviews: doctor.reviews,
            workingDays: doctor.workingTime ?? "",
            workingHours: doctor.workingTime ?? "",
            price: doctor.price, 
            docModel: doctor,
          ),
          
        ],
      ),
    );
  }

  /// Helper to extract years from workingTime text (if any)
  String _extractYears(String? text) {
    if (text == null || text.isEmpty) return "Not available";
    final match = RegExp(r'(\d+)\s*years?').firstMatch(text);
    return match != null ? match.group(0)! : "Not available";
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: AppColors.greyColor),
          ),
        ],
      ),
    );
  }
}
