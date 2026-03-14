import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/login_view.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/otp_screen.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/shared/custom_button.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/shared/custom_textfeild.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/signup_widgets/signup_header.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/signup_widgets/signup_tail.dart';
import 'package:flutter_application_2/services/api_service.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl/intl.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phone = TextEditingController();

  String gender = "Male"; // Dropdown value
  DateTime? selectedDOB;
  bool loading = false;
  bool isArabic = true;

  void _toggleLanguage() {
    setState(() => isArabic = !isArabic);
  }

  void pickDOB() async {
    DateTime initialDate = DateTime(2000, 1, 1);
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDOB ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        selectedDOB = picked;
        dobController.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

 Future<void> handleSignUp() async {
  if (!formKey.currentState!.validate()) return;

  if (passwordController.text != confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  setState(() => loading = true);

  try {
    final response = await ApiService.signup(
      phone:phone.text.trim() ,
      fullName: fullNameController.text.trim(),
      userName: userNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
      gender: gender.toLowerCase(),
      role: "Patient",
      dob: dobController.text,
    );

    // 👇 ده هيطبع الريسبونس من السيرفر
    print("Signup Response:");
    print(response);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          email: emailController.text.trim(),
        ),
      ),
    );

  } catch (e) {

    // 👇 ده هيطبع الايرور
    print("Signup Error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  setState(() => loading = false);
} 








@override
  void dispose() {
    userNameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
    ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30,),
        IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
        }, icon: Icon(Icons.arrow_back_ios_new_outlined,size: 20,color: AppColors.greyColor,))
,              // Language toggle
              
              SignupHeader(
                Create: isArabic ? "Create Account" : "إنشاء حساب",
                Join: isArabic ? "Join our healthcare community" : "انضم إلى مجتمعنا الصحي",
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: isArabic ? "Full Name" : "ادخل اسمك",
                        icon: Icons.person,
                        controller: fullNameController,
                        validator: (v) => v!.isEmpty ? "Enter full name" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: isArabic ? "User Name" : "ادخل اسم المستخدم",
                        icon: Icons.person_outline,
                        controller: userNameController,
                        validator: (v) => v!.isEmpty ? "Enter user name" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: isArabic ? "Email" : "ادخل بريدك الالكتروني",
                        icon: Icons.email,
                        controller: emailController,
                        validator: (v) => v!.isEmpty ? "Enter email" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: isArabic ? "Password" : "كلمه السر",
                        icon: Icons.lock,
                        controller: passwordController,
                        isPassword: true,
                        validator: (v) => v!.length < 8 ? "Password must be at least 8 chars" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: isArabic ? "Confirm Password" : "تأكيد كلمة السر",
                        icon: Icons.lock_outline,
                        controller: confirmPasswordController,
                        isPassword: true,
                        validator: (v) => v!.isEmpty ? "Confirm your password" : null,
                      ),
                      const SizedBox(height: 16),



                           CustomTextField(
                        label: isArabic ? "Phone number" : "  ",
                        icon: Icons.phone,
                        controller: phone,
                        validator: (v) => v!.isEmpty ? "Enter your phone number" : null,
                      ),
                      const SizedBox(height: 16),
             

                      // Gender dropdown
 Row(
  children: [
    // Male button
    Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = "Male"),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: gender == "Male" ? AppColors.blueColor : Colors.transparent,
            border: Border.all(color: AppColors.blueColor),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.male,
                color: gender == "Male" ? Colors.white : AppColors.blueColor,
              ),
              const SizedBox(width: 8),
              Text(
                "Male",
                style: TextStyle(
                  color: gender == "Male" ? Colors.white : AppColors.blueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),

    // Female button
    Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = "Female"),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: gender == "Female" ? AppColors.blueColor : Colors.transparent,
            border: Border.all(color: AppColors.blueColor),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.female,
                color: gender == "Female" ? Colors.white : AppColors.blueColor,
              ),
              const SizedBox(width: 8),
              Text(
                "Female",
                style: TextStyle(
                  color: gender == "Female" ? Colors.white : AppColors.blueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
),SizedBox(height: 15,),            // DOB picker
                      InkWell(
                        onTap: pickDOB,
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: selectedDOB == null
                                ? (isArabic ? "Select DOB" : "اختر تاريخ الميلاد")
                                : dobController.text,
                            icon: Icons.event,
                            controller: dobController,
                            enabled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: isArabic ? "Sign Up" : "تسجيل",
                        onPressed: handleSignUp,
                      ),
                      const SizedBox(height: 12),
                      // SignupTail(
                      //   back: isArabic ? "Back to Login" : "الرجوع لتسجيل الدخول",
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}