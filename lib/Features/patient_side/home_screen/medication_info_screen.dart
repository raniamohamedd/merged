import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class MedicationInfoScreen extends StatelessWidget {
  final Map<String, dynamic> medication;

  const MedicationInfoScreen({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.blackColor),
        title: Text(
          medication["name"] ?? "Medication Info",
          style: TextStyle(
              color: AppColors.blackColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoCard("Medication Name", medication["name"] ?? "-"),
            infoCard("Dosage", medication["dosage"] ?? "-"),
            infoCard("Frequency", medication["frequency"] ?? "-"),
            infoCard("Reminder Time", medication["time"] ?? "-"),
            infoCard(
              "Side Effects",
              (medication["sideEffects"] == null ||
                      medication["sideEffects"].toString().trim().isEmpty)
                  ? "No side effects recorded"
                  : medication["sideEffects"].toString(),
            ),
            infoCard(
              "Warning Level",
              medication["warningLevel"] ?? "low",
            ),
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