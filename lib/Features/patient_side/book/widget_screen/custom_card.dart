import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final String date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? AppColors.blueColor : Color(0xffF2F4F7)),
          color: isSelected ? AppColors.blueColor : Color(0xffF2F4F7),
        ),
        child: Center(
          child: Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.whiteColor : Color(0xffC2C2C2),
            ),
          ),
        ),
      ),
    );
  }
}
