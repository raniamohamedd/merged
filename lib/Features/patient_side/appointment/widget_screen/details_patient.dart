import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class DetailsPatient extends StatelessWidget {
  const DetailsPatient({super.key, required this.bookingFor, required this.fullName, required this.age, required this.gender});
 final String bookingFor;
  final String fullName;
  final String age;
  final String gender;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Booking for:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
            Text(bookingFor,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.darkGreyColor),),

          ],
        ),
        SizedBox(height: 8,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Full Name:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
            Text(fullName,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.darkGreyColor),),
          ],
        ),
        SizedBox(height: 8,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Age:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
            Text(age,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.darkGreyColor),),

          ],
        ),
        SizedBox(height: 8,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Gender:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color:AppColors.purpleColor),),
            Text(gender,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.darkGreyColor),),
          ],
        ),
      ],
    );
  }
}
