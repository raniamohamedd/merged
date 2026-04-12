import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chats_list_screen.dart' hide AppColors;
import 'package:flutter_application_2/Features/doctor_side/screens/dashboard.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/emergency_doc.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/medication_report_page.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_page.dart';
// import 'package:health_care_app/Features/patient_side/profile/profile_screen.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class NavigationnScreendoc extends StatefulWidget {
  NavigationnScreendoc({super.key});

  static String id = '/navBottom';

  @override
  State<NavigationnScreendoc> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationnScreendoc> {
  int pageIndex = 0;

  List<Widget> pages = [
    DoctorDashboard(), // 0
    PatientsPage(), // 1
    ChatsListScreenDoctor(), //2
    // ChatScreen(), // 3
        MedicationReportsPage(), 

    EmergencyCasesPage(),


  ];
  @override
  Widget build(BuildContext context) {
    final int gapIndex = pages.length ~/ 2;
    int navActiveIndex;
    if (pageIndex == gapIndex) {
      navActiveIndex = -1;
    } else if (pageIndex > gapIndex) {
      navActiveIndex = pageIndex - 1; // نخصم 1 عشان نتخطى الـ gap
    } else {
      navActiveIndex = pageIndex;
    }
    return 
    
    Scaffold(
      body: 
      IndexedStack(index: pageIndex, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            pageIndex = gapIndex;
          });
        },
        child: Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
        backgroundColor: AppColors.backgroundColorBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        borderWidth: 1,
        borderColor: Colors.black,
        
        icons: [
           Icons.home,
           Icons.people,
                      Icons.description_outlined,

          Icons.warning,
        ],
        inactiveColor: Colors.black.withOpacity(0.5),
        activeColor: AppColors.backgroundColorBlue,
        gapLocation: GapLocation.center,
        leftCornerRadius: 20,
        rightCornerRadius: 20,
        iconSize: 25,
        notchSmoothness: NotchSmoothness.softEdge,
        activeIndex: navActiveIndex,
        onTap: (index) {
          final int actualIndex = index >= ((pages.length ~/ 2))
              ? index + 1
              : index;
          setState(() {
            pageIndex = actualIndex;
          });
        },
      ),
    );
  }
}
