import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/personal_info_widgets/photos_show_sheet.dart';
import 'package:flutter_application_2/Features/patient_side/profile/view/profile_view.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/shared/custom_appbar.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/personal_info/custom_personal_info_container.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/shared/user_image_profile.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/shared/user_session.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        toolbarHeight: 80,
          automaticallyImplyLeading: false, 
      backgroundColor: Colors.transparent, 
      // elevation: 0,

      centerTitle: true,
      title: Text(
        'Personal information',
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
            child: Column(
              children: [SizedBox(height: 200), CustomPersonalInfoContainer()],
            ),
          ),
          Positioned(
            // right: 150,
            top: 120,
            left: (MediaQuery.of(context).size.width / 2) - 70,
            child: UserImageProfile(),
          ),
          Positioned(
            // right: 130,
            right: 175,
            // top: 220,
            top: 225,
            child: CircleAvatar(
              radius: 13,
              backgroundColor: AppColors.blackColor.withOpacity(0.8),
              child: IconButton(
                icon: Icon(
                  Icons.mode_edit,
                  color: AppColors.whiteColor,
                  size: 13,
                ),
                onPressed: () async {
                  final userId = FirebaseAuth.instance.currentUser!.uid;
                  final newImageUrl = await showImagePickerSheet(
                    context,
                    userId,
                  );
                  if (newImageUrl != null) {
                    setState(() {
                      UserSession.currentUser = UserSession.currentUser!
                          .copyWith(image: newImageUrl);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
