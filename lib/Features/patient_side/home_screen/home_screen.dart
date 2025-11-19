import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/model/doctor_specialist.dart';
// مش ضروري تستورد موديل الريكومينديشن هنا لو مش هتستخدم Lists محلية
// import 'package:health_care_app/Features/patient_side/home_screen/model/recomendation_doctor.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/CarsouseSlide.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/DoctorSpecialist.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/RecomendationDoc.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
import 'package:flutter_application_2/Features/patient_side/recommendation_doctor/recommendation.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/sizes.dart';
import 'package:flutter_application_2/shared/widgets/sea_all.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //    scroll automatic
  final List<String> imageView = [
    "lib/images/ListView3.png",
    "lib/images/ListView1.jpeg",
    "lib/images/listView2.jpeg",
    "lib/images/listView4.jpeg",
  ];

  // search
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return
     Scaffold(
      backgroundColor: Colors.white,
      body: 
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                const HeaderWidget(),
                // SizedBox(height: AppFonts.spaceMedium),
                // CarsouseSlide(imageView: imageView),

              //   // search
              //   SizedBox(height: AppFonts.spaceMedium),
              //   Divider(color: AppColors.backgroundGrey, thickness: 1.25),
              //   SizedBox(height: AppFonts.spaceSmall),

              //   TextField(
              //     controller: searchController,
              //     decoration: InputDecoration(
              //       hint: Text(
              //         'Search by name or specialist',
              //         style: TextStyle(
              //           color: AppColors.greyColor.withOpacity(0.8),
              //           fontSize: 16,
              //         ),
              //       ),
              //       prefixIcon: const Icon(Icons.search),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12),
              //         borderSide: BorderSide(
              //           color: AppColors.greyColor,
              //           width: 1,
              //         ),
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12),
              //         borderSide: BorderSide(
              //           color: AppColors.greyColor,
              //           width: 1,
              //         ),
              //       ),
              //       enabledBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12),
              //         borderSide: BorderSide(
              //           color: AppColors.greyColor,
              //           width: 1,
              //         ),
              //       ),
              //     ),
              //     onChanged: (value) => setState(() => searchQuery = value),
              //     onSubmitted: (value) {
              //       setState(() => searchQuery = value);
              //       searchController.clear();
              //     },
              //   ),

              //   SizedBox(height: AppFonts.spaceSmall),
              //   Divider(color: AppColors.backgroundGrey, thickness: 1.25),
              //   SizedBox(height: AppFonts.spaceSmall),

              //   // Doctor Speciality
              //   DoctorSpecialistWidget(
              //     items: items,
              //     onSelect: (spec) {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => Recommendation(initialSpec: spec),
              //         ),
              //       );
              //     },
              //   ),
              //   // Recommendation doctor
              //   Column(
              //     children: [
              //       Row(
              //         children: [
              //           Text(
              //             "Recommendation Doctor",
              //             style: AppFonts.bodyLarge.copyWith(
              //               color: AppColors.textColorBlack,
              //             ),
              //           ),
              //           const Spacer(),
              //           SEAALL(
              //             onTap: () {
              //               // افتح صفحة الـ See All واعمل فيها نفس فكرة الـ Stream + فلترة بالسيرش
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => Recommendation(
              //                     initialQuery: searchQuery,
              //                     initialSpec:
              //                         '', // عدّل صفحة Recommendation تقبل ده
              //                   ),
              //                 ),
              //               );
              //             },
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: AppFonts.spaceSmall),

              //       // بنمرر الـ searchQuery اختيارياً للفلترة داخل الويجد
              //       RecomendationDoc(searchQuery: searchQuery),
              //     ],
            ],
            ),
          ),
        ),
      ),
    );
  
  }
}
