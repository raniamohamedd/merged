import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/signup_view.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/strings.dart';

class LoginTail extends StatelessWidget {
  final String signUp;
    final String create;

  const LoginTail({super.key, required this.signUp, required this.create});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SizedBox(height: 15,),
        Divider(indent: 20,endIndent: 20,thickness: .3,),
        // Padding(
        //   padding: const EdgeInsets.only(left: 30 , right: 5 , top: 50),
        //   child: Text(Strings.loginTail , textAlign: TextAlign.center,style: TextStyle(fontSize: 12 , color: AppColors.greyColor.withOpacity(0.8)),),
       
          
        // ),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

        Text(create, style: TextStyle(color: AppColors.darkGreyColor , fontWeight: FontWeight.w400),),
        TextButton(onPressed:(){
          Navigator.push(context,
          MaterialPageRoute(builder:(context) => SignupView())
          );
        }, child: Text(signUp,style: TextStyle(color: AppColors.blueColor,fontSize:18,fontWeight: FontWeight.bold),))
        ],)
      ],
    );
  }
}