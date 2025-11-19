import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class CustomDoctorInfoRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditable;
  final VoidCallback onEditTap;

  const CustomDoctorInfoRow({
    super.key,
    required this.controller,
    required this.isEditable,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric( vertical: 0),
      child: Row(
        children: [

          
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEditable,

              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w400,
                color: isEditable
                    ? AppColors.blackColor.withOpacity(0.9)
                    : AppColors.blackColor.withOpacity(0.6), 
              ),

              decoration: InputDecoration(
                isDense: true,
                // contentPadding:
                //     const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                labelStyle: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 20,
                ),
                fillColor: Colors.transparent,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isEditable ? Icons.check : Icons.mode_edit_outline_outlined,
              color: isEditable
                  ? Colors.blue 
                  : AppColors.blueColor, 
              size: 24,
              
            ),
            highlightColor: AppColors.blueColor.withOpacity(0.1),
            onPressed: onEditTap,
          ),
        ],
      ),
    );
  }
}
