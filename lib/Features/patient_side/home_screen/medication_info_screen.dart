import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class MedicationInfoScreen extends StatelessWidget {
  const MedicationInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.blackColor),
        title: Text(
          "Medication Info",
          style: TextStyle(
              color: AppColors.blackColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoCard("Medication Name", "Panadol"),
            infoCard("Dosage", "500 mg"),
            infoCard("Usage", "Pain relief and fever"),
            infoCard("Side Effects", "Nausea, dizziness (rare)"),
            infoCard("Warnings", "Do not exceed recommended dose"),
          ],
        ),
      ),
    );
  }

  Widget infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                fontSize: 13, color: AppColors.greyColor),
          ),
        ],
      ),
    );
  }
}