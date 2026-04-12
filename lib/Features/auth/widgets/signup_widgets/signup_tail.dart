import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class SignupTail extends StatelessWidget {
  final String back;
  const SignupTail({super.key, required this.back});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        
        // Text(
        //   "Have an account?",
        //   style: TextStyle(
        //     color: AppColors.darkGreyColor,
        //     fontWeight: FontWeight.w400,
        //   ),
        // ),
        TextButton.icon(
          icon: 
          Icon(Icons.arrow_back,color: AppColors.blueColor,)
          ,
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
          , label: Text(
          back,
            style: TextStyle(
              color: AppColors.blueColor,
              fontSize:   17,
              fontWeight: FontWeight.bold,
            ),
          ),)
        
      ],
    );
  }
}
