import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class HeaderBookingConfirmation extends StatelessWidget {
  const HeaderBookingConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.greenColor,
          child: Icon(Icons.check, color: AppColors.whiteColor, size: 50),
        ),
        Text("Booking has been \nrescheduled",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: AppColors.blackColor),),

      ],
    );
  }
}
