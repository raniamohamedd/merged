// /*import 'package:flutter/material.dart';
// import 'package:health_care_app/core/constants/colors.dart';

// class UserDoctorSelector extends StatefulWidget {
//   final void Function(String userType, String? specialization)
//   onSelectionChanged;

//   const UserDoctorSelector({super.key, required this.onSelectionChanged});

//   @override
//   State<UserDoctorSelector> createState() => _UserDoctorSelectorState();
// }

// class _UserDoctorSelectorState extends State<UserDoctorSelector> {
//   String _selectedRole = 'User';
//   String? _selectedSpecialization;

//   final List<String> _specializations = [
//     'Cardiology',
//     'Dermatology',
//     'Pediatrics',
//     'Neurology',
//     'Orthopedics',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 Radio<String>(
//                   value: 'Doctor',
//                   groupValue: _selectedRole,
//                   activeColor: const Color(0xFF007BFF),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedRole = value!;
//                       _selectedSpecialization = null;
//                     });
//                     widget.onSelectionChanged(
//                       _selectedRole,
//                       _selectedSpecialization,
//                     );
//                   },
//                 ),
//                 const Text(
//                   "Doctor",
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 100),
//             Row(
//               children: [
//                 Radio<String>(
//                   value: 'User',
//                   groupValue: _selectedRole,
//                   activeColor: const Color(0xFF007BFF),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedRole = value!;
//                       _selectedSpecialization = null;
//                     });
//                     widget.onSelectionChanged(
//                       _selectedRole,
//                       _selectedSpecialization,
//                     );
//                   },
//                 ),
//                 const Text(
//                   "User",
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ],
//         ),

//         const SizedBox(height: 10),

//         // Dropdown بيظهر لو النوع Doctor
//         if (_selectedRole == 'Doctor')
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300, width: 1),
//               borderRadius: BorderRadius.circular(15),
//               color: Colors.white,
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: _selectedSpecialization,
//                 dropdownColor: Colors.white.withOpacity(0.9),
//                 hint: Text(
//                   "Choose Your Specialization",
//                   style: TextStyle(color: AppColors.greyColor),
//                 ),
//                 isExpanded: true,
//                 icon: const Icon(
//                   Icons.keyboard_arrow_down_rounded,
//                   color: Colors.blue,
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedSpecialization = value;
//                   });
//                   widget.onSelectionChanged(
//                     _selectedRole,
//                     _selectedSpecialization,
//                   );
//                 },
//                 items: _specializations.map((spec) {
//                   return DropdownMenuItem<String>(
//                     value: spec,

//                     child: Text(
//                       spec,
//                       style: const TextStyle(color: Colors.black87),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
// */

// //    mazen shabara edit

// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/core/constants/colors.dart';
// // 👇 مهم: استيراد موديل التخصصات والقائمة الجاهزة بالصور
// import 'package:flutter_application_2/Features/patient_side/home_screen/model/doctor_specialist.dart';

// class UserDoctorSelector extends StatefulWidget {
//   final void Function(String userType, String? specialization)
//   onSelectionChanged;

//   const UserDoctorSelector({super.key, required this.onSelectionChanged});

//   @override
//   State<UserDoctorSelector> createState() => _UserDoctorSelectorState();
// }

// class _UserDoctorSelectorState extends State<UserDoctorSelector> {
//   String _selectedRole = 'User';

//   // بدل الـ String: هنستخدم الكائن DoctorSpecialist عشان نعرض صورة + اسم
//   DoctorSpecialist? _selectedSpec;
//   final List<DoctorSpecialist> _specialists = items; // القائمة اللي عندك بالصور

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // اختيار النوع
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 Radio<String>(
//                   value: 'Doctor',
//                   groupValue: _selectedRole,
//                   activeColor: const Color(0xFF007BFF),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedRole = value!;
//                       _selectedSpec = null; // نفرغ الاختيار
//                     });
//                     widget.onSelectionChanged(_selectedRole, null);
//                   },
//                 ),
//                 const Text(
//                   "Doctor",
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 100),
//             Row(
//               children: [
//                 Radio<String>(
//                   value: 'User',
//                   groupValue: _selectedRole,
//                   activeColor: const Color(0xFF007BFF),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedRole = value!;
//                       _selectedSpec = null;
//                     });
//                     widget.onSelectionChanged(_selectedRole, null);
//                   },
//                 ),
//                 const Text(
//                   "User",
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ],
//         ),

//         const SizedBox(height: 10),

//         // Dropdown يظهر فقط لو النوع Doctor
//         if (_selectedRole == 'Doctor')
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 15 , vertical: 4),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300, width: 1),
//               borderRadius: BorderRadius.circular(15),
//               color: Colors.white,
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<DoctorSpecialist>(
//                 value: _selectedSpec,
//                 dropdownColor: Colors.white.withOpacity(0.95),
//                 isExpanded: true,
//                 hint: Text(
//                   "Choose Your Specialization",
//                   style: TextStyle(color: AppColors.greyColor),
//                 ),
//                 icon: const Icon(
//                   Icons.keyboard_arrow_down_rounded,
//                   color: Colors.blue,
//                 ),

//                 // لما يختار: نخزن الكائن ونبعت العنوان (title) للأب
//                 onChanged: (value) {
//                   setState(() => _selectedSpec = value);
//                   widget.onSelectionChanged(
//                     _selectedRole,
//                     _selectedSpec?.title,
//                   );
//                 },

//                 // عناصر القائمة: صورة صغيرة + اسم
//                 items: _specialists.map((spec) {
//                   return DropdownMenuItem<DoctorSpecialist>(
//                     value: spec,
//                     child: Row(
//                       children: [
//                         Image.asset(
//                           spec.imgUrl,
//                           width: 20,
//                           height: 20,
//                           fit: BoxFit.contain,
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           spec.title,
//                           style: const TextStyle(color: Colors.black87),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
