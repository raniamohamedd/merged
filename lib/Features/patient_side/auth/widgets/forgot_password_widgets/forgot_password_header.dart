import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/login_view.dart';
import 'package:flutter_application_2/Features/patient_side/splash&onboarding/splash.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/strings.dart';
import 'package:flutter_application_2/core2/constants/icons.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 50,),
        IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
        }, icon: Icon(Icons.arrow_back_ios_new_outlined,size: 20,color: AppColors.greyColor,))
      ,SizedBox(height: 80,),

                Center(child: HealthcareLogo(logo:HealthcareIcons.stethoscope , color: AppColors.blueColor, isGradient: false,size: 90,)),

          SizedBox(height: 10,),

          Padding(
            padding: const EdgeInsets.only(left:40.0,top: 40 ,right: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Forgot Password" , style: TextStyle(color: AppColors.blueColor,fontSize: 24 , fontWeight: FontWeight.bold),),
                 SizedBox(height: 20,),
                 Text(Strings.forgotPass,style:TextStyle(color: AppColors.greyColor,fontWeight: FontWeight.w300,fontSize: 14))
              ],
            ),
          )
      
      ],
    );
  }
}