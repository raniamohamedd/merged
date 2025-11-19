import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/shared/custom_textfeild.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/signup_widgets/custom_dropDown_gende.dart';
// import 'package:health_care_app/shared/user_session.dart';

class SignupForm extends StatelessWidget {
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController genderController;
  final TextEditingController agecontroller;
 final String name;
  final String age;

 final String email;

 final String phone;

 final String pass;



  final GlobalKey<FormState> formkey;

  const SignupForm({
    super.key,
    // super.key,
    required this.userNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.genderController,
    required this.formkey, required this.agecontroller, required this.name, required this.age, required this.email, required this.phone, required this.pass,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // CustomTextField(
          //   label: "Enter your name",
          //   icon: Icons.person,
          //   controller: userNameController,
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return "Please enter your name";
          //     }
          //     return null;
          //   },
          // ),
          CustomTextField(
            label: name,
            icon: Icons.person,
            controller: userNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your name";
              }

              final parts = value.trim().split(' ');

              if (parts.length < 2) {
                return "Please enter your full name (first and last)";
              }

              for (var part in parts) {
                if (part.length < 3) {
                  return "Each part of your name must be at least 3 letters";
                }
              }

              return null;
            },
          ),
                    SizedBox(height: 20),


  CustomTextField(
            label: age,
            icon: Icons.event,
            controller: agecontroller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your age";
              }

              // final parts = value.trim().split(' ');

              // if (parts.length < 2) {
              //   return "Please enter your full name (first and last)";
              // }

              // for (var part in parts) {
              //   if (part.length < 3) {
              //     return "Each part of your name must be at least 3 letters";
              //   }
              // }

              return null;
            },
          ),

          SizedBox(height: 20),

          CustomTextField(
            label: email,
            icon: Icons.email_outlined,
            controller: emailController,

            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          // CustomTextField(
          //   label: "Enter your phone",
          //   icon: Icons.phone_callback,
          //   controller: phoneNumberController,

          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return "Please enter your phone number";
          //     }
          //     return null;
          //   },
          // ),
          
          CustomTextField(
            label: phone,
            icon: Icons.phone_callback,
            controller: phoneNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your phone number";
              }

              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return "Phone number must contain only numbers";
              }

              if (value.length != 11) {
                return "Phone number must be 11 digits";
              }

              if (!value.startsWith("011")) {
                return "Phone number must start with 011";
              }

              return null;
            },
          ),

          const SizedBox(height: 16),
          //           CustomGenderDropdown(controller: genderController),

          // const SizedBox(height: 16),

          CustomTextField(
            label:pass,
            icon: Icons.lock_outline_rounded,
            controller: passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.length < 8) {
                return "Password must be at least 8 characters";
              }
              return null;
            },
          ),

          const SizedBox(height: 6),
//           CustomTextField(
//   label: "Confirm your password",
//   icon: Icons.lock_outline_rounded,
//   controller: confirmPasswordController,
//   isPassword: true,
//   validator: (value) {
//     if (value == null || value.isEmpty) {
//       return "Please confirm your password";
//     }
//     if (value != passwordController.text) {
//       return "Passwords do not match";
//     }
//     return null;
//   },
// ),
          // const SizedBox(height: 16),


        ],
      ),
    );
  }
}
