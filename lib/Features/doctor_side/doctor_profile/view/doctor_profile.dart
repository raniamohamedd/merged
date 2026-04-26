import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/profile_widgets/custom_doctor_avatar.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/profile_widgets/custom_doctor_navbar.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/profile_widgets/custom_doctor_row.dart';
import 'package:flutter_application_2/core/routing/navigators/navigation_screen_doc.dart';
import 'package:flutter_application_2/Features/patient_side/profile/view/settings_page.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/user_profile/logout_dialog.dart';
import 'package:flutter_application_2/core/services/auth_services.dart';
import 'package:flutter_application_2/shared/user_session.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomDoctorNavbar(
        onPress: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>  NavigationnScreendoc()));
        },
      ),


      body: Padding(
        padding: const EdgeInsets.only(top: 80.0, right: 20, left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CustomDoctorAvatar(
                    docName: UserSession.currentUser!.name,
                    imageUrl: UserSession.currentUser!.image ?? '',
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            CustomDoctorRow(
              onpress: (){
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Scaffold(),
                  ),
                );
                // setState(() {});
              },
              icon: Icons.person_2_outlined,
              text: 'personal info',
            ),

            SizedBox(height: 30),
            CustomDoctorRow(
              onpress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              icon: Icons.settings,
              text: 'settings',
            ),
            SizedBox(height: 30),
            //  Divider(),
            CustomDoctorRow(
              onpress: () {},
              icon: Icons.help_outline_rounded,
              text: 'help',
            ),
            SizedBox(height: 30),
            //  Divider(),
            CustomDoctorRow(
              onpress: () {
                LogoutDialog.show(
                  context,
                  onLogout: () {
                    UserSession.clear();
                    authService.logout();
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                );
              },
              icon: Icons.login_outlined,
              text: 'logout',
            ),
            SizedBox(height: 30),
            //  Divider(),
            //  CustomDoctorRow(onpress: () { }, icon: Icons.settings, text: 'personal info',),
          ],
        ),
      ),
    );
  }
}
