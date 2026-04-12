import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/splash&onboarding/splash.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/icons.dart';

class LoginHeader extends StatelessWidget {
  final String Smart;
  final String Connect;
  const LoginHeader({super.key, required this.Smart, required this.Connect});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only( top:20, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
    
        children: [
          
          HealthcareLogo(logo:HealthcareIcons.stethoscope , color: AppColors.blueColor, isGradient: false,size: 90,),
          SizedBox(height: 15,),
          Center(
            child: Text(
              Smart,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.blueColor,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
Connect,            style: TextStyle(fontSize: 15, color: AppColors.greyColor),
            overflow: TextOverflow.fade,
          ),
    
        ],
      ),
    );
  }
}
