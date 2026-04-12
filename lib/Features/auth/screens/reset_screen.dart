import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/auth/widgets/forgot_password_widgets/forgot_password_header.dart';

import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

class ResetScreen extends StatefulWidget {
  final String email;

  const ResetScreen({super.key, required this.email});

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {

  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool loading = false;

  Future<void> handleReset() async {

    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {

      final response = await ApiService.resetPassword(
        email: widget.email,
        otp: otpController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      print(response);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
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

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// نفس الهيدر بالصورة
            const ForgotPasswordHeader(),

            Form(
              key: formKey,

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27),

                child: Column(
                  children: [
                    SizedBox(height: 30,),

                    /// OTP
                    TextFormField(
                      controller: otpController,

                      decoration: const InputDecoration(
                        labelText: "OTP Code",
                        border: OutlineInputBorder(),
                      ),

                      validator: (value){
                        if(value == null || value.isEmpty){
                          return "Enter OTP";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    /// Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,

                      decoration: const InputDecoration(
                        labelText: "New Password",
                        border: OutlineInputBorder(),
                      ),

                      validator: (value){
                        if(value == null || value.length < 6){
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    /// Confirm Password
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,

                      decoration: const InputDecoration(
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(),
                      ),

                      validator: (value){
                        if(value != passwordController.text){
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    /// زرار Reset
                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        onPressed: loading ? null : handleReset,

                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Reset Password",
                                style: TextStyle(fontSize: 18,color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}