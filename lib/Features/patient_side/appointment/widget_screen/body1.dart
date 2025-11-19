import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class Body1 extends StatelessWidget {
  final DateTime appointmentDate;
  final String appointmentTime;

  const Body1({super.key, required this.appointmentDate, required this.appointmentTime});

  @override
  Widget build(BuildContext context) {
    // تحويل التاريخ لعرض اليوم والشهر والسنة فقط
    final dateOnly = "${appointmentDate.day.toString().padLeft(2,'0')}/${appointmentDate.month.toString().padLeft(2,'0')}/${appointmentDate.year}";

    return Column(
      children: [
        Container(
          height: 37,
          width: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.redColor),
            color: AppColors.redColor,
          ),
          child: Center(
            child: Text(
              dateOnly, // 🟢 عرض التاريخ فقط
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 37,
          width: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.redColor),
            color: AppColors.whiteColor,
          ),
          child: Center(
            child: Text(
              appointmentTime,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.blackColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
