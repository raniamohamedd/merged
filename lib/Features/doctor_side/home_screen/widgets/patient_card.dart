// import 'package:flutter/material.dart';
// import 'package:health_care_app/core/constants/colors.dart';
//
// class PatientCard extends StatelessWidget {
//   const PatientCard({
//     super.key,
//     required this.name,
//     required this.status,
//     required this.imgPath,
//   });
//   final String name;
//   final String status;
//   final String imgPath;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.maxFinite,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: AppColors.greyColor),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Row(
//           children: [
//             CircleAvatar(radius: 20, backgroundImage: AssetImage(imgPath)),
//             SizedBox(width: 7),
//             Column(
//               children: [
//                 Text(
//                   name,
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: AppColors.blackColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   status,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: AppColors.greyColor,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),
//             CircleAvatar(
//               radius: 20,
//               backgroundColor: AppColors.greenColor,
//               foregroundColor: AppColors.whiteColor,
//               child: Icon(Icons.check),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }