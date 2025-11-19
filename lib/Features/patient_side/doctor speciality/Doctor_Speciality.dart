// import 'package:flutter/material.dart';
// // import 'package:health_care_app/Features/patient_side/home/home.dart';
// import 'package:health_care_app/Features/patient_side/home_screen/home_screen.dart';
// import 'package:health_care_app/Features/patient_side/home_screen/model/doctor_specialist.dart';
// import 'package:health_care_app/core/constants/colors.dart';
// import 'package:health_care_app/core/constants/sizes.dart';
// // import 'package:health_care_app/data/specialist_data.dart';

// class DoctorSpecialityAll extends StatelessWidget {
//   const DoctorSpecialityAll({super.key});



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
            
//              Navigator.push(context , 
//                 MaterialPageRoute(builder: (context) => HomeScreen()),
//               );
//             //  Navigator.pushReplacementNamed(context, AppRoutes.home);
//           },
//           icon: Icon(Icons.arrow_back_ios_new, color: AppColors.blackColor),
//         ),
//         title: Text("Doctor Speciality", style: AppFonts.titleBold),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GridView.builder(
//               itemCount: items.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//               ),
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.all(5.0),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           color: AppColors.surfaceColor,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(15.0),
//                           child: ClipOval(
//                             child: Image.asset(
//                               items[index].imgUrl,
//                               fit: BoxFit.fill,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(items[index].title, style: AppFonts.bodyRegular),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
