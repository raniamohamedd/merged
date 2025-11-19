import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/sizes.dart';

class ForgotpasswordTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  
  const ForgotpasswordTextField({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0 ,horizontal: 30),
      child: TextFormField(
        controller: controller,
      
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.greyColor.withOpacity(0.02),
      
          labelText: label,
          labelStyle: TextStyle(color: AppColors.greyColor.withOpacity(0.5), fontSize: 14),
      
         
          focusColor: AppColors.blueColor,
      
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.textFieldSize),
          ),
      
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.greyColor.withOpacity(0.1),
              width: 1.5,
            ), 
            borderRadius: BorderRadius.circular(AppSizes.textFieldSize),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.blueColor,
              width: 2,
            ), // لما المستخدم يضغط عليه
            borderRadius: BorderRadius.circular(AppSizes.textFieldSize),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.redColor,
              width: 1.5,
            ), 
            borderRadius: BorderRadius.circular(AppSizes.textFieldSize),
          ),
        ),
      
       
      
      ),
    );
  }
}