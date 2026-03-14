import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/shared/custom_textfeild.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/signup_widgets/custom_dropDown_gende.dart';

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
    required this.userNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.genderController,
    required this.agecontroller,
    required this.formkey,
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.pass,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Full Name
          CustomTextField(
            label: name,
            icon: Icons.person,
            controller: userNameController,
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter your name";
              final parts = value.trim().split(' ');
              if (parts.length < 2) return "Please enter full name (first & last)";
              for (var part in parts) {
                if (part.length < 3) return "Each part of name must be >= 3 letters";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // DOB
          CustomTextField(
            label: age,
            icon: Icons.event,
            controller: agecontroller,
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter your DOB";
              if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                return "DOB must be in YYYY-MM-DD format";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Email
          CustomTextField(
            label: email,
            icon: Icons.email_outlined,
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter your email";
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Phone
          CustomTextField(
            label: phone,
            icon: Icons.phone_callback,
            controller: phoneNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter your phone number";
              if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Phone must contain only numbers";
              if (value.length != 11) return "Phone must be 11 digits";
              if (!value.startsWith("011")) return "Phone must start with 011";
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Gender Dropdown
          CustomGenderDropdown(controller: genderController),
          const SizedBox(height: 20),

          // Password
          CustomTextField(
            label: pass,
            icon: Icons.lock_outline_rounded,
            controller: passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.length < 8) return "Password must be at least 8 characters";
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Confirm Password
          CustomTextField(
            label: "Confirm Password",
            icon: Icons.lock_outline_rounded,
            controller: confirmPasswordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) return "Please confirm your password";
              if (value != passwordController.text) return "Passwords do not match";
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}