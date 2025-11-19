import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/splash&onboarding/splash.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/strings.dart';
import 'package:flutter_application_2/core2/constants/icons.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key, required this.Create, required this.Join});
  final String Create;
    final String Join;


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IconButton(
        //   onPressed: () {
        //     Navigator.of(context).pop(context);
        //   },
        //   icon: Icon(
        //     Icons.arrow_back_ios_new_rounded,
        //     size: 20,
        //     color: AppColors.greyColor,
        //   ),
        // ),
        
        // SizedBox(height: 2.5),

        SizedBox(height: 20),

        // Center(child: Image.asset(Strings.LogoPath, height: 50, width: 50)),
          Center(child: HealthcareLogo(logo: HealthcareIcons.stethoscope, color: AppColors.blueColor, isGradient: false,size: 80,iconSize: 20,)),
          SizedBox(height: 5,),
        Center(
          child: Text(
            Create,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.blackColor,
            ),
          ),
        ),
        Center(child: Text(
            Join,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.blackColor,
            ),
          ),),
        SizedBox(height: 5),
      ],
    );
  }
}
