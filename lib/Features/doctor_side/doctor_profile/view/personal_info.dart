import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/view/doctor_profile.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/personal_info_widgets/custom_aboutMe_container.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/personal_info_widgets/custom_gender_radiobutton.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/personal_info_widgets/custom_userInfo_row.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/personal_info_widgets/photos_show_sheet.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/profile_widgets/custom_doctor_avatar.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/profile_widgets/custom_doctor_navbar.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/services/firestore_services.dart';
import 'package:flutter_application_2/shared/user_session.dart';

class DoctorPersonalInfo extends StatefulWidget {
  const DoctorPersonalInfo({super.key});

  @override
  State<DoctorPersonalInfo> createState() => _DoctorPersonalInfoState();
}

class _DoctorPersonalInfoState extends State<DoctorPersonalInfo> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _nameController = TextEditingController(
    text: UserSession.currentUser!.name,
  );
  // final TextEditingController _emailController = TextEditingController(
  //   text: UserSession.currentUser!.email ,
  // );
  final TextEditingController _phoneController = TextEditingController(
    text: UserSession.currentUser!.phoneNum.toString(),
  );
  final TextEditingController genderController = TextEditingController(
    text: UserSession.currentUser!.gender,
  );
  final TextEditingController aboutMeControler = TextEditingController(
    text: UserSession.currentDoctor!.aboutMe,
  );
  final TextEditingController hospitalController = TextEditingController(
    text: UserSession.currentDoctor!.hospital,
  );
  final TextEditingController specialityController = TextEditingController(
    text: UserSession.currentDoctor!.specialization,
  );
  final TextEditingController priceController = TextEditingController(
    text: UserSession.currentDoctor!.price.toString(),
  );
  final TextEditingController STRController = TextEditingController(
    text: UserSession.currentDoctor!.STR.toString(),
  );
  final TextEditingController workingConroller = TextEditingController(
    text: UserSession.currentDoctor!.workingTime.toString(),
  );
  void dispose() {
    _nameController.dispose();
    // _emailController.dispose();
    _phoneController.dispose();
    genderController.dispose();
    aboutMeControler.dispose();
    hospitalController.dispose();
    specialityController.dispose();
    priceController.dispose();
    STRController.dispose();
    super.dispose();
  }

  FirestoreService firestoreService = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDoctorNavbar(
        onPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorProfile()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10 , vertical: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          CustomDoctorAvatar(
                            docName: UserSession.currentDoctor!.name,
                            imageUrl: UserSession.currentDoctor!.imageUrl,
                          ),
                          Positioned(
                            right: 25,
                            top: 88,

                            child: CircleAvatar(
                              radius: 13,
                              backgroundColor: AppColors.blueColor.withOpacity(
                                0.8,
                              ),

                              child: IconButton(
                                icon: Icon(
                                  Icons.mode_edit_outline_outlined,
                                  color: AppColors.whiteColor,
                                  size: 13,
                                ),
                                onPressed: () async {
                                  final userId =
                                      FirebaseAuth.instance.currentUser!.uid;

                                  // ✳️ استني sheet ترجع الرابط الجديد
                                  final newImageUrl =
                                      await showImagePickerSheet(
                                        context,
                                        userId,
                                      );

                                  if (newImageUrl != null) {
                                    setState(() {
                                      UserSession.currentDoctor = UserSession
                                          .currentDoctor!
                                          .copyWith(imageUrl: newImageUrl);
                                      UserSession.currentUser = UserSession
                                          .currentUser!
                                          .copyWith(image: newImageUrl);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${UserSession.currentUser!.email}',
                        style: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),

              Container(
                padding: EdgeInsets.only(top: 13, right: 8, left: 0 , bottom: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.greyLightColor),
                ),
                child: Column(
                  children: [
                    CustomUserinfoRow(
                      controller: TextEditingController(
                        text: UserSession.currentUser!.name,
                      ),
                      label: 'Name',
                      onSave: (newValue) async {
                        firestoreService.updateDoctorField('name', newValue);
                        firestoreService.updateUserField('name', newValue);
                        setState(() {
                          UserSession.currentDoctor = UserSession.currentDoctor!
                              .copyWith(name: newValue);
                          UserSession.currentUser = UserSession.currentUser!
                              .copyWith(name: newValue);
                        });
                      },
                    ),

                    CustomUserinfoRow(
                      controller: _phoneController,
                      label: 'Phone number',
                      onSave: (newValue) async {
                        firestoreService.updateUserField(
                          'phoneNum',
                          int.parse(newValue),
                        );
                        setState(() {
                          UserSession.currentUser = UserSession.currentUser!
                              .copyWith(phoneNum: int.parse(newValue));
                        });
                      },
                    ),
                    const CustomGenderSelector(),
SizedBox(height: 5),
                    CustomUserinfoRow(
                controller: TextEditingController(
                  text: UserSession.currentUser!.age.toString(),
                ),
                label: 'Age',
                onSave: (newValue) async {
                  firestoreService.updateUserField('age', int.parse(newValue));
                  setState(() {
                    UserSession.currentUser = UserSession.currentUser!.copyWith(
                      age: int.parse(newValue),
                    );
                  });
                },
              ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              CustomAboutmeContainer(
                controller: aboutMeControler,
                label: 'About Me',
                onSave: (newValue) async {
                  firestoreService.updateDoctorField('aboutMe', newValue);
                  setState(() {
                    UserSession.currentDoctor = UserSession.currentDoctor!
                        .copyWith(aboutMe: newValue);
                  });
                },
              ),

              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.greyLightColor),
                ),
                child: Column(
                  children: [
                    CustomUserinfoRow(
                      controller: hospitalController,
                      label: 'Hospital Name',
                      onSave: (newValue) async {
                        firestoreService.updateDoctorField(
                          'hospital',
                          newValue,
                        );
                        setState(() {
                          UserSession.currentDoctor = UserSession.currentDoctor!
                              .copyWith(hospital: newValue);
                        });
                      },
                    ),

                    CustomUserinfoRow(
                      controller: specialityController,
                      label: 'Your Speciality',
                      onSave: (newValue) async {
                        firestoreService.updateDoctorField(
                          'specialization',
                          newValue,
                        );
                        setState(() {
                          UserSession.currentDoctor = UserSession.currentDoctor!
                              .copyWith(specialization: newValue);
                        });
                      },
                    ),

                    CustomUserinfoRow(
                      controller: priceController,
                      label: 'Session price',
                      onSave: (newValue) async {
                        firestoreService.updateDoctorField(
                          'price',
                          double.parse(newValue),
                        );
                        setState(() {
                          UserSession.currentDoctor = UserSession.currentDoctor!
                              .copyWith(price: double.parse(newValue));
                        });
                      },
                    ),
                    CustomUserinfoRow(
                      controller: workingConroller,
                      label: 'Working Time',
                      onSave: (newValue) async {
                        firestoreService.updateDoctorField(
                          'workingTime',
                          newValue,
                        );
                        setState(() {
                          UserSession.currentDoctor = UserSession.currentDoctor!
                              .copyWith(workingTime: newValue);
                        });
                      },
                    ),

                    CustomUserinfoRow(
                      controller: STRController,
                      label: 'STR',
                      onSave: (newValue) async {
                        firestoreService.updateDoctorField(
                          'STR',
                          int.parse(newValue),
                        );
                        setState(() {
                          UserSession.currentDoctor = UserSession.currentDoctor!
                              .copyWith(STR: int.parse(newValue));
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
