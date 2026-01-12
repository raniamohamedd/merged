// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/Features/patient_side/home_screen/home_screen.dart';
// import 'package:flutter_application_2/Features/patient_side/profile/widgets/shared/custom_appbar.dart';
// import 'package:flutter_application_2/Features/patient_side/profile/widgets/user_profile/custom_profile_container.dart';
// import 'package:flutter_application_2/Features/patient_side/profile/widgets/shared/user_image_profile.dart';
// import 'package:flutter_application_2/core/constants/colors.dart';
// import 'package:flutter_application_2/shared/widgets/navigator.dart';

// class ProfilePatientScreen extends StatefulWidget {
//   const ProfilePatientScreen({super.key});

//   @override
//   State<ProfilePatientScreen> createState() => _ProfilePatientScreenState();
// }

// class _ProfilePatientScreenState extends State<ProfilePatientScreen> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      
//       // backgroundColor: Colors.white,
//       appBar: 
//       AppBar(
//         toolbarHeight: 80,
//           automaticallyImplyLeading: false, 
//       backgroundColor: Colors.transparent, 
//       // elevation: 0,

//       centerTitle: true,
//       title: Text(
//         'My profile',
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       // leading: IconButton(onPressed: () {  }, icon: ,
//       //   // icon:  Icon(
//       //   //   Icons.arrow_back_ios_rounded,
//       //   //   color: textColor,
//       //   //   size: 22,
//       //   // ),
//       //   // onPressed: onBack ?? () => Navigator.pop(context),
//       // ),
//     ),
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               color:AppColors.blueColor,
//             ),
//             child: Column(children: [SizedBox(height: 200), CustomContainer()]),
//           ),
//           Positioned(
//             top: 120,
//             left: (MediaQuery.of(context).size.width / 2) - 70,
//             child: UserImageProfile(),
//           ),
//         ],
//       ),
//     );
//   }
// }



// // import 'package:flutter/material.dart';
// // import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
// // import 'package:flutter_application_2/core2/constants/colors.dart';

// // class ProfilePatientScreen extends StatefulWidget {
// // const ProfilePatientScreen({Key? key}) : super(key: key);

// // @override
// // State<ProfilePatientScreen> createState() => _PatientDashboardUIState();
// // }

// // class _PatientDashboardUIState extends State<ProfilePatientScreen> {
// // List<Map<String, dynamic>> medications = [
// // {"id": 1, "name": "Aspirin", "dosage": "100mg", "frequency": "Once daily", "time": "08:00 AM", "reminder": true},
// // {"id": 2, "name": "Metformin", "dosage": "500mg", "frequency": "Twice daily", "time": "08:00 AM, 08:00 PM", "reminder": true},
// // {"id": 3, "name": "Lisinopril", "dosage": "10mg", "frequency": "Once daily", "time": "09:00 AM", "reminder": false},
// // {"id": 4, "name": "Atorvastatin", "dosage": "20mg", "frequency": "Once daily", "time": "10:00 PM", "reminder": true},
// // ];

// // List<Map<String, String>> upcomingReminders = [
// // {"time": "08:00 AM", "medication": "Aspirin 100mg"},
// // {"time": "08:00 AM", "medication": "Metformin 500mg"},
// // {"time": "09:00 AM", "medication": "Lisinopril 10mg"},
// // ];

// // void toggleReminder(int id) {
// // setState(() {
// // final index = medications.indexWhere((med) => med["id"] == id);
// // medications[index]["reminder"] = !medications[index]["reminder"];
// // });
// // }

// // @override
// // Widget build(BuildContext context) {
// // final isMobile = MediaQuery.of(context).size.width < 600;

// // return Scaffold(
// //   // appBar: AppBar(
// //   //   title: const Text("Patient Dashboard"),
// //   // ),
// //   body: SingleChildScrollView(

// //     padding: const EdgeInsets.all(12),
// //     child: Column(
// //       children: [
// //         SizedBox(height: 50,),
// //   Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           // 👋 الترحيب بالمستخدم (UI)
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 "Mt",
// //                 style:  TextStyle(
// //                   fontSize: 22,
// //                   fontWeight: FontWeight.bold,
// //                   color:AppColors.blueColor,
// //                 ),
// //               ),
// //               const SizedBox(height: 5),
// //               // const Text(
// //               //   "Welcome back 👋",
// //               //   style: TextStyle(
// //               //     fontSize: 16,
// //               //     color: Colors.grey,
// //               //   ),
// //               // ),
// //             ],
// //           ),

// //           // 🔔 زر الإشعارات
      
// //         ],
// //       ),
// //             // Medications List
// //         Card(
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text("Medications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                 const SizedBox(height: 8),
// //                 ...medications.map((med) => medicationCard(med)).toList(),
// //               ],
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         // Upcoming Reminders
// //         Card(
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text("Upcoming Reminders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                 const SizedBox(height: 8),
// //                 ...upcomingReminders.map((reminder) => reminderCard(reminder)).toList(),
// //               ],
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         // Quick Stats
// //         Card(
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text("Quick Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                 const SizedBox(height: 8),
// //                 statRow("Active Medications", medications.length.toString(), Colors.blue),
// //                 statRow("Daily Reminders", medications.where((m) => m["reminder"]).length.toString(), Colors.green),
// //                 statRow("Weekly Adherence", "95%", Colors.amber),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   ),
// //   // bottomNavigationBar: isMobile
// //   //     ? BottomNavigationBar(
// //   //         items: const [
// //   //           BottomNavigationBarItem(icon: Icon(Icons.description), label: "Reports"),
// //   //           BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
// //   //           BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
// //   //           BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Appointments"),
// //   //         ],
// //   //         onTap: (_) {},
// //   //       )
// //   //     : null,
// // );

// // }

// // Widget medicationCard(Map<String, dynamic> med) {
// // return Card(
// // margin: const EdgeInsets.symmetric(vertical: 4),
// // child: Padding(
// // padding: const EdgeInsets.all(8),
// // child: Row(
// // children: [
// // Expanded(
// // child: Column(
// // crossAxisAlignment: CrossAxisAlignment.start,
// // children: [
// // Text(med["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
// // Text("Dosage: ${med["dosage"]}"),
// // Text("Frequency: ${med["frequency"]}"),
// // Text("Time: ${med["time"]}"),
// // ],
// // ),
// // ),
// // Column(
// // children: [
// // Switch(
// // value: med["reminder"],
// // onChanged: (_) => toggleReminder(med["id"]),
// // ),
// // const Icon(Icons.notifications, size: 20, color: Colors.grey),
// // ],
// // )
// // ],
// // ),
// // ),
// // );
// // }

// // Widget reminderCard(Map<String, String> reminder) {
// // return Card(
// // margin: const EdgeInsets.symmetric(vertical: 4),
// // color: Colors.blue[50],
// // child: ListTile(
// // leading: const CircleAvatar(
// // backgroundColor: Colors.blue,
// // child: Icon(Icons.notifications, color: Colors.white),
// // ),
// // title: Text(reminder["medication"]!),
// // subtitle: Text(reminder["time"]!),
// // ),
// // );
// // }

// // Widget statRow(String title, String value, Color color) {
// // return Padding(
// // padding: const EdgeInsets.symmetric(vertical: 4),
// // child: Row(
// // mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // children: [
// // Text(title),
// // Container(
// // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // decoration: BoxDecoration(
// // color: color,
// // borderRadius: BorderRadius.circular(12),
// // ),
// // child: Text(value, style: const TextStyle(color: Colors.white)),
// // )
// // ],
// // ),
// // );
// // }
// // }
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:intl/intl.dart';

class PatientProfilePage extends StatefulWidget {
  final String userEmail;
  final VoidCallback onBack;

  const PatientProfilePage({
    super.key,
    required this.userEmail,
    required this.onBack,
  });

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  bool isEditing = false;

  Map<String, String> profileData = {
    "fullName": "Rania Mohamed",
    "email": "raniamohamed@gmail.com",
    "phone": "+201159811894",
    "dateOfBirth": "2003-11-12",
    "gender": "female",
    "bloodType": "O+",
    "height": "175",
    "weight": "75",
    "address": "123 Main Street, City",
    "emergencyContact": "+201159811894",
    "emergencyName": "Rania Mohamed",
    "allergies": "Penicillin, Nuts",
    "chronicConditions": "Type 2 Diabetes",
    "notes": "Seasonal allergies in spring",
  };

  @override
  void initState() {
    super.initState();
    profileData["email"] = widget.userEmail;
  }

  void handleSave() {
    setState(() {
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved successfully")),
    );
  }

  void handleCancel() {
    setState(() {
      isEditing = false;
    });
  }

  String getInitials(String name) {
    return name
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0] : "")
        .take(2)
        .join()
        .toUpperCase();
  }

  int getAge(String dob) {
    final birthDate = DateTime.parse(dob);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget buildTextField(String label, String field,
      {TextInputType? keyboardType, int? maxLines}) {
    return TextField(
      keyboardType: keyboardType,
      controller: TextEditingController(text: profileData[field]),
      readOnly: !isEditing,
      maxLines: maxLines ?? 1,
      onChanged: (val) {
        profileData[field] = val;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: !isEditing,
        fillColor: !isEditing ? Colors.grey[100] : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildBadge(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color ?? Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color ?? Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
                    backgroundColor: const Color.fromARGB(255, 249, 249, 249),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          
          children: [
            
            
            
            SizedBox(height: 44,),
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Row(
  children: [
    const Spacer(), // pushes text to center
    Text(
      "My Profile",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.blueColor,
      ),
    ),
    const Spacer(), // keeps text centered
    IconButton(
      icon:  Icon(Icons.edit,color: AppColors.blueColor,),
      tooltip: "Edit",
      onPressed: () {
        setState(() {
          isEditing = true;
        });
      },
    ),
  ],
)
              ),
                          SizedBox(height: 20,),

            // Profile Header Card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(backgroundColor: AppColors.blueColor,
                              radius: 40,
                              child: Text('Rania',style:TextStyle(color: Colors.white)),
                            ),
                            if (isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rania Mohamed',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('raniamohamed@gmail.com', style: const TextStyle(color: Colors.grey)),
                                  
                                ],
                              ),
                            ],
                          ),
                        ),
                     
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                 
                                  
                      ],
                    ),
                       const SizedBox(height: 22),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      buildBadge(Icons.person,
                                          profileData["gender"] == "male" ?  "Female":"Male" ),
                                      buildBadge(Icons.calendar_today,
                                          "22 yrs"),
                                      buildBadge(Icons.bloodtype, profileData["bloodType"]!),
                                    ],
                                  ),
                                                         const SizedBox(height: 20),


                                               Row(
                          children: [
                            SizedBox(width: 70,),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(profileData["height"]!,
                                      style: const TextStyle(fontSize: 18, color: Colors.blue)),
                                  const Text("Height (cm)",
                                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                                                        SizedBox(width: 20,),

                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(profileData["weight"]!,
                                      style: const TextStyle(fontSize: 18, color: Colors.green)),
                                  const Text("Weight (kg)",
                                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Personal Info Card
            Card(
                            color: Colors.white,

              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Personal Information",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    buildTextField("Full Name", "fullName"),
                    const SizedBox(height: 8),
                    buildTextField("Email", "email", keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 8),
                    buildTextField("Phone", "phone", keyboardType: TextInputType.phone),
                    const SizedBox(height: 8),
                    buildTextField("Date of Birth", "dateOfBirth",
                        keyboardType: TextInputType.datetime),
                    const SizedBox(height: 8),
                    buildTextField("Address", "address"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Medical Info Card
            Card(
                            color: Colors.white,

              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Medical Information",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    buildTextField("Blood Type", "bloodType"),
                    const SizedBox(height: 8),
                    buildTextField("Height (cm)", "height", keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    buildTextField("Weight (kg)", "weight", keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    buildTextField("Allergies", "allergies", maxLines: 2),
                    const SizedBox(height: 8),
                    buildTextField("Chronic Conditions", "chronicConditions", maxLines: 2),
                    const SizedBox(height: 8),
                    buildTextField("Notes", "notes", maxLines: 3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Contact Card
            Card(
                            color: Colors.white,

              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Emergency Contact",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    buildTextField("Contact Name", "emergencyName"),
                    const SizedBox(height: 8),
                    buildTextField("Contact Phone", "emergencyContact",
                        keyboardType: TextInputType.phone),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: handleCancel, child: const Text("Cancel")),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: handleSave, child: const Text("Save")),
                ],
              ),
          ],
        ),
      ),
    );
  }
}





































