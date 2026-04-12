// import 'package:flutter/material.dart';
// import 'package:health_care_app/core/constants/colors.dart';
// import 'package:health_care_app/core/constants/sizes.dart';

// class CustomHospitalField extends StatelessWidget {
//   const CustomHospitalField({super.key , required this.hospitalController});
//  final TextEditingController hospitalController;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(height: 20),

//         TextFormField(
//           controller: hospitalController,
//           decoration: InputDecoration(
//             fillColor: AppColors.greyLightColor.withOpacity(0.3),
//             filled: true,
//             label: Text(
//               "Hospital Name",
//               style: TextStyle(color: AppColors.greyColor, fontSize: 14),
//             ),
//             prefixIcon: Icon(Icons.local_hospital_rounded),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(AppSizes.textFieldSize),
//             ),

//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(
//                 color: AppColors.greyColor.withOpacity(0.1),
//                 width: 1.5,
//               ),
//               borderRadius: BorderRadius.circular(AppSizes.textFieldSize),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: AppColors.blueColor, width: 2),
//               borderRadius: BorderRadius.circular(AppSizes.textFieldSize),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: AppColors.redColor, width: 1.5),
//               borderRadius: BorderRadius.circular(AppSizes.textFieldSize),
//             ),
//           ),

//           validator: (value) {
//             if (value == null ||
//                 value.trim().isEmpty ||
//                 value.trim().length < 3) {
//               return 'Please enter your hospital name';
//             }
//             ;
//           },
//           // onChanged: (value) => hospitalName = value.trim(),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }
