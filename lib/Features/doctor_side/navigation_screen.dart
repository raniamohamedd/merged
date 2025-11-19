import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_application_2/Features/doctor_side/calender_screen/calender_screen.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chats_list_screen.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/view/doctor_profile.dart';
import 'package:flutter_application_2/Features/doctor_side/home_screen/home_screen.dart';
// import 'package:health_care_app/Features/doctor_side/profile_screen/profile_screen.dart';
import 'package:flutter_application_2/Features/doctor_side/search_screen/search_screen.dart';

class NavigationScreen extends StatefulWidget {
  NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int pageIndex = 0;

  List<Widget> pages = [
    HomeScreenD(), //0
    SearchScreenD(), // 1
    ChatsListScreenDoctor(),
    // CalenderScreenD(), // 2
    DoctorProfile(),
    // ProfileScreenD(), // 3
  ];

  final List<IconData> icons = [
    CupertinoIcons.home,
    CupertinoIcons.search,
    CupertinoIcons.chat_bubble_2,
    CupertinoIcons.profile_circled,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: pageIndex, children: pages),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: icons,
        inactiveColor: Colors.black.withOpacity(0.5),
        activeColor: const Color.fromARGB(255, 148, 33, 25),
        gapLocation: GapLocation.none,
        leftCornerRadius: 20,
        rightCornerRadius: 20,
        iconSize: 25,
        notchSmoothness: NotchSmoothness.softEdge,
        activeIndex: pageIndex,
        onTap: (index) {
          setState(() {
            pageIndex = index;
          });
        },
      ),
    );
  }
}
