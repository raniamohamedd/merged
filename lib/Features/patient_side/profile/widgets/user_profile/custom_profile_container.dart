import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/login_view.dart';
import 'package:flutter_application_2/Features/patient_side/profile/view/personal_info.dart';
import 'package:flutter_application_2/Features/patient_side/profile/view/settings_page.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/user_profile/customRow.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/user_profile/logout_dialog.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'package:flutter_application_2/shared/user_session.dart';
// import 'package:health_care_app/Features/patient_side/profile/widgets/custom_personal_info_container.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 65),

              Text(
                UserSession.currentUser?.name ?? 'User Name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              // SizedBox(height: 20),
              // Text(
              //   UserSession.currentUser?.email ?? ' ',
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey[500],
              //     wordSpacing: 3,
              //   ),
              // ),

              SizedBox(height: 25),
              CustomRow(
                icon: Icons.person,
                text: 'My Account',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PersonalInfo()),
                  );
                },
              ),

              Divider(),
              CustomRow(
                icon: Icons.settings,
                text: 'Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),

              Divider(),
              CustomRow(icon: Icons.help, text: 'Help Center', onTap: () {}),
              Divider(),
              CustomRow(
                icon: Icons.logout,
                text: 'Log Out',
                onTap: () {
                  LogoutDialog.show(
                    context,
                    onLogout: () {
                      print('User logged out');
                      AuthService authService = AuthService();
                      authService.logout();
                      UserSession.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  );
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
