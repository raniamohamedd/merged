import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/reset_screen.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/forgot_password_widgets/forgot_password_header.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/forgot_password_widgets/forgotpassword_button.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/forgot_password_widgets/forgotpassword_field.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/services/api_service.dart';

class ForgotpasswordView2 extends StatefulWidget {
  
  

  const ForgotpasswordView2({super.key});

  @override
  State<ForgotpasswordView2> createState() => _ForgotpasswordViewState();
}

class _ForgotpasswordViewState extends State<ForgotpasswordView2> {

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool loading = false;

  Future<void> handleForget() async {

    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {

      final response = await ApiService.forgetpassword(
        email: emailController.text.trim(),
      );

      print("Forget Response: $response");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetScreen(
            email: emailController.text.trim(),
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ForgotPasswordHeader(),
            // SizedBox(height: 20,),
            
 Padding(
   padding: const EdgeInsets.all(27.0),
   child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
   
                  decoration: const InputDecoration(
                    labelText: "Enter your email",
                    border: OutlineInputBorder(),
                  ),
   
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
   
                    if (!value.contains("@")) {
                      return "Enter a valid email";
                    }
   
                    return null;
                  },
                ),
 ),            // ForgotpasswordButton(text:'Reset Password',onPressedtext:handleforget, email:emailController.text.trim(),),
      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Form(
    key: formKey,
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: loading ? null : handleForget,
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Reset Password",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    ),
  ),
),    ],
        ),
      )
    );
  }
}