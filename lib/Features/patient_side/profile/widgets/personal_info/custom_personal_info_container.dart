import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/personal_info/custom_profile_info_row.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/firestore_services.dart';
import 'package:flutter_application_2/shared/user_session.dart';

class CustomPersonalInfoContainer extends StatefulWidget {
  const CustomPersonalInfoContainer({super.key});

  @override
  State<CustomPersonalInfoContainer> createState() =>
      _CustomPersonalInfoContainerState();
}

class _CustomPersonalInfoContainerState
    extends State<CustomPersonalInfoContainer> {
  @override
  Widget build(BuildContext context) {
    FirestoreService firestoreService = FirestoreService();

    return Expanded(
      child: Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 65),
                Text(
                  UserSession.currentUser!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SizedBox(height: 5),
                Text(
                  UserSession.currentUser!.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyColor,
                  ),
                ),
          
                const SizedBox(height: 20),
          
                CustomProfileInfoRow(
                  label: "Name",
                  text: UserSession.currentUser!.name,
                  onSave: (newValue) {
                    UserSession.currentUser = UserSession.currentUser?.copyWith(
                      name: newValue,
                    );
                    setState(() {});
                    firestoreService.updateUserField("name", newValue);
                  },
                ),
          
               
          
                CustomProfileInfoRow(
                  label: "Email",
                  text: UserSession.currentUser!.email,
                  onSave: (newValue) {
                    UserSession.currentUser = UserSession.currentUser?.copyWith(
                      email: newValue,
                    );
                    setState(() {});
                    firestoreService.updateUserField("email", newValue);
          
                  },
                ),
          
                // const Divider(),
                CustomProfileInfoRow
                (
                  label: "Phone Number",
                  text: UserSession.currentUser!.phoneNum.toString(),
                  onSave: (newValue) {
                    int intNewValue = int.parse( newValue);
                    UserSession.currentUser = UserSession.currentUser?.copyWith(
                      phoneNum: intNewValue,
                    );
                    setState(() {});
                    firestoreService.updateUserField("phoneNum", intNewValue);
                  },
                ),
          
                // const Divider(),
          
                // CustomProfileInfoRow(
                //   label: "Gender",
                //   text: UserSession.currentUser!.gender ?? 'Gender not set',
                //   onSave: (newValue) {
                //     UserSession.currentUser = UserSession.currentUser?.copyWith(
                //       gender: newValue,
                //     );
                //     setState(() {});
                //   },
                // ),
              // const Divider(),
              
                CustomProfileInfoRow(
          
                  label: "Age",
                  text: UserSession.currentUser!.age.toString() ,
                  onSave: (newValue) {
                    UserSession.currentUser = UserSession.currentUser?.copyWith(
                      age:int.parse( newValue),
                    );
                    setState(() {});
                    firestoreService.updateUserField("age", int.parse(newValue));
                  },
                ),
          
                // const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
