import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';


class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Instructions / Notes:",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
        Text("   Please arrive 10 minutes before your appointment.",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: AppColors.purpleColor),),
        Divider(color: AppColors.purpleColor,),
      ],
    );
  }
}
