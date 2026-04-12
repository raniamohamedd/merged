import 'package:flutter/material.dart';
// import 'package:health_care_app/Features/patient_side/appointment/your_appointment.dart';
import 'package:flutter_application_2/Features/patient_side/book/book_appointment.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/data/models/doctor_model.dart';

class MakeAppointmentButton extends StatelessWidget {
  const MakeAppointmentButton({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.hospitalName,
    required this.rating,
    required this.doctorImageUrl,
    required this.numberOfReviews,
    required this.workingDays,
    required this.workingHours,
    required this.price,
    required this.docModel,
  });

  final String doctorName;
  final DoctorModel docModel;
  final String specialty;
  final String hospitalName;
  final double rating;
  final String doctorImageUrl;
  final int numberOfReviews;
  final String workingDays;
  final String workingHours;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3), // changes position of shadow
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookAppointment(
                docModel: docModel,
                doctorName: doctorName,
                specialty: specialty,
                hospitalName: hospitalName,
                rating: rating,
                doctorImageUrl: doctorImageUrl,
                numberOfReviews: numberOfReviews,
                workingDays: workingDays,
                workingHours: workingHours,
                price: price,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Make An Appointment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
