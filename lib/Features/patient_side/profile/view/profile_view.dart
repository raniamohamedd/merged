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
