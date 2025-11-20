import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/calender/calender_screen.dart';
import 'package:flutter_application_2/Features/patient_side/chats/view/chats_list_screen.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/home_screen.dart';
// import 'package:health_care_app/Features/patient_side/profile/profile_screen.dart';
import 'package:flutter_application_2/Features/patient_side/profile/view/profile_view.dart';
import 'package:flutter_application_2/Features/patient_side/search/search_screen.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class NavigationnScreen extends StatefulWidget {
  NavigationnScreen({super.key});

  static String id = '/navBottom';

  @override
  State<NavigationnScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationnScreen> {
  int pageIndex = 0;

  List<Widget> pages = [
    HomeScreen(), // 0
    CalenderScreen(), // 1
    Scaffold(), //2
    // ChatScreen(), // 3
    SearchScreen(),
    ProfilePatientScreen( ), 


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
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.backgroundColorBlue,
      ),
      // عشان تيجي عندي ف النص
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        borderWidth: 1,
        borderColor: Colors.black,
        
        icons: [
           Icons.home,
           Icons.description_outlined,
          CupertinoIcons.search,
          CupertinoIcons.profile_circled,
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
