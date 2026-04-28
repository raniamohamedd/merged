// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_2/Features/patient_side/home_screen/model/doctor_specialist.dart';
// import 'package:flutter_application_2/core/constants/colors.dart';
// import 'package:flutter_application_2/core/constants/sizes.dart';
// import 'package:flutter_application_2/Features/patient_side/recommendation_doctor/recommendation.dart';

// class Speciality extends StatelessWidget {
//   const Speciality({super.key, required this.items, this.onSelect});

//   // قائمة التخصصات
//   final List<DoctorSpecialist> items;

//   // كولباك اختياري (لو حابب تستخدمه بدل النافيجيشن)
//   final void Function(String spec)? onSelect;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Doctor Speciality",
//           style: AppFonts.titleSmall.copyWith(color: AppColors.textColorBlack),
//         ),
//         centerTitle: true,
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: GridView.builder(
//           itemCount: items.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             mainAxisSpacing: 16,
//             crossAxisSpacing: 16,
//             childAspectRatio: 0.9,
//           ),
//           itemBuilder: (context, index) {
//             final spec = items[index];
//             return InkWell(
//               onTap: () {
//                 SystemSound.play(SystemSoundType.click);

//                 //  لو في كولباك مبعوت من برّه، نفّذه
//                 if (onSelect != null) {
//                   onSelect!(spec.title);
//                   return;
//                 }

//                 //  وإلا نعمل Navigation لشاشة التوصيات مع فلترة التخصص
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => Recommendation(initialSpec: spec.title),
//                   ),
//                 );
//               },
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 65,
//                     height: 65,
//                     decoration: BoxDecoration(
//                       color: AppColors.backgroundColorBlue.withOpacity(0.08),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(15.0),
//                       child: ClipOval(
//                         child: Image.asset(spec.imgUrl, fit: BoxFit.contain),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: AppFonts.spaceMedium),
//                   Text(
//                     spec.title,
//                     style: AppFonts.bodyMedium,
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
