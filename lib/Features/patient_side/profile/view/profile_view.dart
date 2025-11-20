import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/home_screen.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/shared/custom_appbar.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/user_profile/custom_profile_container.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/shared/user_image_profile.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/shared/widgets/navigator.dart';

class ProfilePatientScreen extends StatefulWidget {
  const ProfilePatientScreen({super.key});

  @override
  State<ProfilePatientScreen> createState() => _ProfilePatientScreenState();
}

class _ProfilePatientScreenState extends State<ProfilePatientScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // backgroundColor: Colors.white,
      appBar: 
      AppBar(
        toolbarHeight: 80,
          automaticallyImplyLeading: false, 
      backgroundColor: Colors.transparent, 
      // elevation: 0,

      centerTitle: true,
      title: Text(
        'My profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // leading: IconButton(onPressed: () {  }, icon: ,
      //   // icon:  Icon(
      //   //   Icons.arrow_back_ios_rounded,
      //   //   color: textColor,
      //   //   size: 22,
      //   // ),
      //   // onPressed: onBack ?? () => Navigator.pop(context),
      // ),
    ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color:AppColors.blueColor,
            ),
            child: Column(children: [SizedBox(height: 200), CustomContainer()]),
          ),
          Positioned(
            top: 120,
            left: (MediaQuery.of(context).size.width / 2) - 70,
            child: UserImageProfile(),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
// import 'package:flutter_application_2/core2/constants/colors.dart';

// class ProfilePatientScreen extends StatefulWidget {
// const ProfilePatientScreen({Key? key}) : super(key: key);

// @override
// State<ProfilePatientScreen> createState() => _PatientDashboardUIState();
// }

// class _PatientDashboardUIState extends State<ProfilePatientScreen> {
// List<Map<String, dynamic>> medications = [
// {"id": 1, "name": "Aspirin", "dosage": "100mg", "frequency": "Once daily", "time": "08:00 AM", "reminder": true},
// {"id": 2, "name": "Metformin", "dosage": "500mg", "frequency": "Twice daily", "time": "08:00 AM, 08:00 PM", "reminder": true},
// {"id": 3, "name": "Lisinopril", "dosage": "10mg", "frequency": "Once daily", "time": "09:00 AM", "reminder": false},
// {"id": 4, "name": "Atorvastatin", "dosage": "20mg", "frequency": "Once daily", "time": "10:00 PM", "reminder": true},
// ];

// List<Map<String, String>> upcomingReminders = [
// {"time": "08:00 AM", "medication": "Aspirin 100mg"},
// {"time": "08:00 AM", "medication": "Metformin 500mg"},
// {"time": "09:00 AM", "medication": "Lisinopril 10mg"},
// ];

// void toggleReminder(int id) {
// setState(() {
// final index = medications.indexWhere((med) => med["id"] == id);
// medications[index]["reminder"] = !medications[index]["reminder"];
// });
// }

// @override
// Widget build(BuildContext context) {
// final isMobile = MediaQuery.of(context).size.width < 600;

// return Scaffold(
//   // appBar: AppBar(
//   //   title: const Text("Patient Dashboard"),
//   // ),
//   body: SingleChildScrollView(

//     padding: const EdgeInsets.all(12),
//     child: Column(
//       children: [
//         SizedBox(height: 50,),
//   Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // 👋 الترحيب بالمستخدم (UI)
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Mt",
//                 style:  TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color:AppColors.blueColor,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               // const Text(
//               //   "Welcome back 👋",
//               //   style: TextStyle(
//               //     fontSize: 16,
//               //     color: Colors.grey,
//               //   ),
//               // ),
//             ],
//           ),

//           // 🔔 زر الإشعارات
      
//         ],
//       ),
//             // Medications List
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Medications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 ...medications.map((med) => medicationCard(med)).toList(),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         // Upcoming Reminders
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Upcoming Reminders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 ...upcomingReminders.map((reminder) => reminderCard(reminder)).toList(),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         // Quick Stats
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Quick Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 statRow("Active Medications", medications.length.toString(), Colors.blue),
//                 statRow("Daily Reminders", medications.where((m) => m["reminder"]).length.toString(), Colors.green),
//                 statRow("Weekly Adherence", "95%", Colors.amber),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   ),
//   // bottomNavigationBar: isMobile
//   //     ? BottomNavigationBar(
//   //         items: const [
//   //           BottomNavigationBarItem(icon: Icon(Icons.description), label: "Reports"),
//   //           BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
//   //           BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
//   //           BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Appointments"),
//   //         ],
//   //         onTap: (_) {},
//   //       )
//   //     : null,
// );

// }

// Widget medicationCard(Map<String, dynamic> med) {
// return Card(
// margin: const EdgeInsets.symmetric(vertical: 4),
// child: Padding(
// padding: const EdgeInsets.all(8),
// child: Row(
// children: [
// Expanded(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(med["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
// Text("Dosage: ${med["dosage"]}"),
// Text("Frequency: ${med["frequency"]}"),
// Text("Time: ${med["time"]}"),
// ],
// ),
// ),
// Column(
// children: [
// Switch(
// value: med["reminder"],
// onChanged: (_) => toggleReminder(med["id"]),
// ),
// const Icon(Icons.notifications, size: 20, color: Colors.grey),
// ],
// )
// ],
// ),
// ),
// );
// }

// Widget reminderCard(Map<String, String> reminder) {
// return Card(
// margin: const EdgeInsets.symmetric(vertical: 4),
// color: Colors.blue[50],
// child: ListTile(
// leading: const CircleAvatar(
// backgroundColor: Colors.blue,
// child: Icon(Icons.notifications, color: Colors.white),
// ),
// title: Text(reminder["medication"]!),
// subtitle: Text(reminder["time"]!),
// ),
// );
// }

// Widget statRow(String title, String value, Color color) {
// return Padding(
// padding: const EdgeInsets.symmetric(vertical: 4),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Text(title),
// Container(
// padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// decoration: BoxDecoration(
// color: color,
// borderRadius: BorderRadius.circular(12),
// ),
// child: Text(value, style: const TextStyle(color: Colors.white)),
// )
// ],
// ),
// );
// }
// }
