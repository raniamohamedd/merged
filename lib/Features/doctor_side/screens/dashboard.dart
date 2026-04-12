// // doctor_dashboard.dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_application_2/Features/doctor_side/doctor_profile/view/doctor_profile.dart';
// import 'package:flutter_application_2/Features/patient_side/auth/view/loginORsignup.dart';
// import 'package:flutter_application_2/Features/patient_side/auth/view/login_view.dart';
// import 'package:flutter_application_2/Features/patient_side/chats/chatassist.dart';
// import 'package:flutter_application_2/Features/patient_side/profile/view/doctor_profile.dart';
// import 'package:flutter_application_2/core/constants/colors.dart';

// class DoctorDashboard extends StatelessWidget {
//   DoctorDashboard({Key? key}) : super(key: key);

//   final List<Map<String, dynamic>> kpiData = [
//     {"icon": Icons.people, "label": "Total Patients", "value": "247", "color": AppColors.blueColor},
//     {"icon": Icons.percent, "label": "Avg Adherence Rate", "value": "87%", "color": AppColors.blueColor},
//     {"icon": Icons.warning, "label": "Emergency Alerts", "value": "3", "color": AppColors.blueColor},
//     {"icon": Icons.description, "label": "Pending Reports", "value": "12", "color": AppColors.blueColor},
//   ];


//   final List<Map<String, dynamic>> adherenceData = const [
//     {"patient": "John D.", "adherence": 92},
//     {"patient": "Mary S.", "adherence": 78},
//     {"patient": "Robert K.", "adherence": 95},
//     {"patient": "Lisa M.", "adherence": 85},
//     {"patient": "James W.", "adherence": 70},
//     {"patient": "Emma R.", "adherence": 88},
//   ];

//   final List<Map<String, dynamic>> dosesData = const [
//     {"day": "Mon", "scheduled": 45, "taken": 42},
//     {"day": "Tue", "scheduled": 48, "taken": 46},
//     {"day": "Wed", "scheduled": 50, "taken": 44},
//     {"day": "Thu", "scheduled": 47, "taken": 45},
//     {"day": "Fri", "scheduled": 52, "taken": 48},
//     {"day": "Sat", "scheduled": 40, "taken": 38},
//     {"day": "Sun", "scheduled": 38, "taken": 36},
//   ];

//   final List<Map<String, dynamic>> medicationCategories = const [
//     {"name": "Cardio", "value": 35, "color": Colors.lightBlue},
//     {"name": "Diabetes", "value": 28, "color": Colors.blueAccent},
//     {"name": "Pain Relief", "value": 20, "color": Colors.lightGreen},
//     {"name": "Antibiotics", "value": 17, "color": Colors.orangeAccent},
//   ];

//   final List<Map<String, dynamic>> notifications = const [
//     {"icon": Icons.error, "text": "SOS alert by John Doe", "color": Colors.redAccent, "time": "5 min ago"},
//     {"icon": Icons.timeline, "text": "New symptom reported by Mary S.", "color": Colors.orangeAccent, "time": "15 min ago"},
//     {"icon": Icons.notifications, "text": "Missed dose - Robert K.", "color": Colors.yellowAccent, "time": "1h ago"},
//     {"icon": Icons.notifications, "text": "New message from Lisa M.", "color": Colors.lightBlue, "time": "2h ago"},
//   ];

//   @override
//   Widget build(BuildContext context) {
    
//     final width = MediaQuery.of(context).size.width;
//     final isMobile = width < 600;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F9F9),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 60),

//             // Welcome Section
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: AppColors.blueColor,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const [
//                         Text(
//                           "Welcome Dr. Sarah Mitchell",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 6),
//                         Text(
//                           "Here is your current patient overview.",
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Chat Icon
//                   IconButton(
//                   icon: const Icon(
//                     Icons.person,
//                     size: 28,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>  SettingsPage(),
//                       ),
//                     );
//                   },
//                 ),
//                    IconButton(
//                   icon: const Icon(
//                     Icons.logout,
//                     size: 28,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>  LoginScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                ],
//               ),
//             ),


//             // Pie Chart for Medication Categories
//             const SizedBox(height: 10),

//             // KPI Cards 2x2
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: kpiData.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 mainAxisExtent: 120,
//               ),
//               itemBuilder: (context, index) {
//                 final kpi = kpiData[index];
//                 return Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.blueColor.withOpacity(0.8),
//                         AppColors.blueColor.withOpacity(0.4),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               kpi["label"],
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                   color: Colors.white70, fontWeight: FontWeight.w500),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               kpi["value"],
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                   color: Colors.white),
//                             ),
//                           ],
//                         ),
//                         CircleAvatar(
//                           radius: 17,
//                           backgroundColor: Colors.white.withOpacity(0.3),
//                           child: Icon(kpi["icon"] as IconData, color: Colors.white, size: 20),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//                        const SizedBox(height: 20),

           
           
//             const SizedBox(height: 20),

//             // Charts Section (Adherence & Doses)
//             isMobile
//                 ? Column(
//                     children: [
//                       buildAdherenceChart(),
//                       const SizedBox(height: 12),
//                       buildDosesChart(),
//                       const SizedBox(height: 12),
//                            Card(
//                color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     const Text(
//                       "Medication Categories",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),
//                     SizedBox(
//                       height: 180,
//                       child: PieChart(
//                         PieChartData(
//                           sections: medicationCategories
//                               .map((e) => PieChartSectionData(
//                                     color: e["color"],
//                                     value: e["value"].toDouble(),
//                                     title: "${e["name"]} ${e["value"]}%",
//                                     radius: 50,
//                                     titleStyle: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white),
//                                   ))
//                               .toList(),
//                           sectionsSpace: 2,
//                           centerSpaceRadius: 30,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

       
//                       buildNotifications(),
//                     ],
//                   )
//                 : Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           children: [
//                             buildAdherenceChart(),
//                             const SizedBox(height: 12),
//                             buildDosesChart(),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           children: [
//                             buildNotifications(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
         
         
//           ],
//         ),
//       ),
//     );
//   }
  // ---- Doses Chart ----
//   Widget buildDosesChart() {
//     return Card(
//       color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text("Scheduled vs Taken Doses",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 180,
//               child: LineChart(
//                 LineChartData(
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: dosesData
//                           .asMap()
//                           .entries
//                           .map((e) => FlSpot(
//                               e.key.toDouble(), e.value["scheduled"].toDouble()))
//                           .toList(),
//                       isCurved: true,
//                       color: Colors.grey.withOpacity(0.5),
//                       barWidth: 3,
//                       dotData: FlDotData(show: false),
//                     ),
//                     LineChartBarData(
//                       spots: dosesData
//                           .asMap()
//                           .entries
//                           .map((e) => FlSpot(
//                               e.key.toDouble(), e.value["taken"].toDouble()))
//                           .toList(),
//                       isCurved: true,
//                       color: AppColors.blueColor,
//                       barWidth: 3,
//                       dotData: FlDotData(show: false),
//                     ),
//                   ],
//                   titlesData: FlTitlesData(
//                     bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         int idx = value.toInt();
//                         if (idx < dosesData.length) {
//                           return Text(dosesData[idx]["day"],
//                               style: const TextStyle(fontSize: 10));
//                         }
//                         return const Text('');
//                       },
//                     )),
//                     leftTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
//                   ),
//                   gridData: FlGridData(
//                       show: true,
//                       horizontalInterval: 10,
//                       getDrawingHorizontalLine: (_) =>
//                           FlLine(color: Colors.grey[300]!, strokeWidth: 1)),
//                   borderData: FlBorderData(show: false),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---- Notifications ----
//   Widget buildNotifications() {
//     return Card(
//       color: Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Recent Notifications",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 12),
//             Column(
//               children: notifications
//                   .map(
//                     (n) => Container(
//                       padding: const EdgeInsets.all(10),
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       decoration: BoxDecoration(
//                         color: n["color"].withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 15,
//                             backgroundColor: n["color"].withOpacity(0.2),
//                             child:
//                                 Icon(n["icon"] as IconData, size: 16, color: n["color"]),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                               child: Text(n["text"], style: const TextStyle(fontSize: 13))),
//                           Text(n["time"],
//                               style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// doctor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/setting_pagedoc.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class DoctorDashboard extends StatelessWidget {
  DoctorDashboard({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> kpiData = [
    {"icon": Icons.people, "label": "Total Patients", "value": "247", "color": AppColors.blueColor},
    {"icon": Icons.percent, "label": "Avg Adherence Rate", "value": "87%", "color": AppColors.blueColor},
    {"icon": Icons.warning, "label": "Emergency Alerts", "value": "3", "color": AppColors.blueColor},
    {"icon": Icons.description, "label": "Pending Reports", "value": "12", "color": AppColors.blueColor},
  ];


  final List<Map<String, dynamic>> adherenceData = const [
    {"patient": "John D.", "adherence": 92},
    {"patient": "Mary S.", "adherence": 78},
    {"patient": "Robert K.", "adherence": 95},
    {"patient": "Lisa M.", "adherence": 85},
    {"patient": "James W.", "adherence": 70},
    {"patient": "Emma R.", "adherence": 88},
  ];

  final List<Map<String, dynamic>> dosesData = const [
    {"day": "Mon", "scheduled": 45, "taken": 42},
    {"day": "Tue", "scheduled": 48, "taken": 46},
    {"day": "Wed", "scheduled": 50, "taken": 44},
    {"day": "Thu", "scheduled": 47, "taken": 45},
    {"day": "Fri", "scheduled": 52, "taken": 48},
    {"day": "Sat", "scheduled": 40, "taken": 38},
    {"day": "Sun", "scheduled": 38, "taken": 36},
  ];

  final List<Map<String, dynamic>> medicationCategories = const [
    {"name": "Diabetes", "value": 35, "color": Colors.lightBlue},
    {"name": "Cardiovascular", "value": 28, "color": Colors.blueAccent},
    {"name": "Pain Relief", "value": 20, "color": Colors.lightGreen},
    {"name": "Antibiotics", "value": 17, "color": Colors.orangeAccent},
  ];

  final List<Map<String, dynamic>> notifications = const [
    {"icon": Icons.error, "text": "SOS alert by John Doe", "color":  Colors.lightBlue, "time": "5 min ago"},
    {"icon": Icons.timeline, "text": "New symptom reported by Mary S.", "color":  Colors.lightBlue, "time": "15 min ago"},
    {"icon": Icons.notifications, "text": "Missed dose - Robert K.", "color":  Colors.lightBlue, "time": "1h ago"},
    {"icon": Icons.notifications, "text": "New message from Lisa M.", "color": Colors.lightBlue, "time": "2h ago"},
  ];

  @override
  Widget build(BuildContext context) {
    
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome Dr. Sarah Mitchell",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Here is your current patient overview.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chat Icon
                  IconButton(
                  icon: const Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  SettingsPage(),
                      ),
                    );
                  },
                ),
                   IconButton(
                  icon: const Icon(
                    Icons.logout,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  LoginScreen(),
                      ),
                    );
                  },
                ),
               ],
              ),
            ),


            // Pie Chart for Medication Categories
            const SizedBox(height: 10),

            // KPI Cards 2x2
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kpiData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 120,
              ),
              itemBuilder: (context, index) {
                final kpi = kpiData[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.blueColor.withOpacity(0.8),
                        AppColors.blueColor.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kpi["label"],
                              style: const TextStyle(
                                fontSize: 11,
                                  color: Colors.white70, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              kpi["value"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Icon(kpi["icon"] as IconData, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
                       const SizedBox(height: 20),

           
           
            const SizedBox(height: 20),

            // Charts Section (Adherence & Doses)
            isMobile
                ? Column(
                    children: [
                      buildAdherenceChart(),
                                            const SizedBox(height: 12)

,                      buildPieChartCard(),
                      const SizedBox(height: 12),
                      buildDosesChart(),
                      const SizedBox(height: 12),
         
                      buildNotifications(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            buildPieChartCard(),
                            const SizedBox(height: 12),
                            buildDosesChart(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            buildNotifications(),
                          ],
                        ),
                      ),
                    ],
                  ),
         
         
          ],
        ),
      ),
    );
  }

  // ---- Adherence Chart ----

  // ---- Adherence Chart ----
  Widget buildAdherenceChart() {
    return 
    Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Daily Medication Adherence",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  gridData: FlGridData(
                      show: true,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: Colors.grey[300]!, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx < adherenceData.length) {
                          return Text(adherenceData[idx]["patient"],
                              style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    )),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  ),
                  barGroups: List.generate(
                    adherenceData.length,
                    (index) => BarChartGroupData(x: index, barRods: [
                      BarChartRodData(
                        toY: adherenceData[index]["adherence"].toDouble(),
                        color: AppColors.blueColor.withOpacity(0.7),
                        width: 16,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildPieChartCard() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Medication Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Distribution of medication types",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 42,
                      sectionsSpace: 4,
                      sections: medicationCategories.map((item) {
                        return PieChartSectionData(
                          color: item["color"],
                          value: (item["value"] as int).toDouble(),
                          title: "${item["value"]}%",
                          radius: 58,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  children: medicationCategories.map((item) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item["color"],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item["name"],
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 
  // ---- Doses Chart ----
  Widget buildDosesChart() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Scheduled vs Taken Doses",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: dosesData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value["scheduled"].toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.grey.withOpacity(0.5),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: dosesData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value["taken"].toDouble()))
                          .toList(),
                      isCurved: true,
                      color: AppColors.blueColor,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx < dosesData.length) {
                          return Text(dosesData[idx]["day"],
                              style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    )),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  ),
                  gridData: FlGridData(
                      show: true,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: Colors.grey[300]!, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _softCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

  // ---- Notifications ----
  Widget buildNotifications() {
      final List<Map<String, dynamic>> notifications = const [
    {"icon": Icons.error, "text": "SOS alert by John Doe", "color": Colors.redAccent, "time": "5 min ago"},
    {"icon": Icons.timeline, "text": "New symptom reported by Mary S.", "color": Colors.orangeAccent, "time": "15 min ago"},
    {"icon": Icons.notifications, "text": "Missed dose - Robert K.", "color": Colors.yellowAccent, "time": "1h ago"},
    {"icon": Icons.notifications, "text": "New message from Lisa M.", "color": Colors.lightBlue, "time": "2h ago"},
  ];

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Notifications",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: notifications
                  .map(
                    (n) => Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: n["color"].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: n["color"].withOpacity(0.2),
                            child:
                                Icon(n["icon"] as IconData, size: 16, color: n["color"]),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(n["text"], style: const TextStyle(fontSize: 13))),
                          Text(n["time"],
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

