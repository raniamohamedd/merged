// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/Features/patient_side/auth/view/login_view.dart';
// import 'package:flutter_application_2/Features/patient_side/auth/view/signup_view.dart';
// import 'package:flutter_application_2/core/constants/colors.dart';
// import 'package:flutter_application_2/core/constants/strings.dart';

// class LoginOrSignup extends StatelessWidget {
//   const LoginOrSignup({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.whiteColor,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             // crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(Strings.LogoPath, width: 200, height: 200),
//               SizedBox(height: 10),
//               Text(
//                 "Health Care",
//                 style: TextStyle(
//                   color: AppColors.textColor,
//                   fontSize: 38,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 40),
//               Text(
//                 "Let's get started!",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.blackColor,
//                 ),
//               ),
//               // Text("Log")
//               SizedBox(height: 40),
//               SizedBox(
//                 width: 220,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.blueColor,
//                     foregroundColor: AppColors.whiteColor,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(vertical: 10.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()),
//                     );
//                   },
//                   child: Text(
//                     "Login",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),
//               SizedBox(
//                 width: 220,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.whiteColor,
//                     foregroundColor: AppColors.blueColor,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(vertical: 10.0),
//                     shape: RoundedRectangleBorder(
//                       side: BorderSide(color: AppColors.blueColor, width: 0.8),
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SignupView()),
//                     );
//                   },
//                   child: Text(
//                     "Sign Up",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
