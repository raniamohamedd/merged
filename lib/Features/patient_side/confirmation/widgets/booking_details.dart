import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';


class BookingDetails extends StatelessWidget {
  const BookingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Booking Details:",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              spacing: 7,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Full Name:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color:AppColors.purpleColor),),
                Text("Age:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
                Text("Gender:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
                Text("Date & Time: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
                Text("Session Status:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),

              ],
            ),
            Column(
              spacing: 5,
              children: [
                Text("Mazen Shabara",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
                Text("22",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
                Text("Male",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
                Text("2:00 PM, [Insert Date]",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
                Text("Confirmed",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
              ],
            )
          ],
        ),

        Divider(color: Color(0xff6D7CCD),),
      ],
    );
  }
}
