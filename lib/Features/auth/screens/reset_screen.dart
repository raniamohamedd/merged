import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/auth/widgets/forgot_password_widgets/forgot_password_header.dart';

import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/shared/widgets/error_dialog.dart';

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
bool isConfirmPasswordHidden = true; // حطيها في الـ State

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool loading = false;
bool isPasswordHidden = true;
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

  // ✅ Dialog نجاح
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(.10),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 42,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Success!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              response['message'] ?? "Password reset successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF247CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Go to Login",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

} catch (e) {
  showErrorDialog(context, message: e.toString());
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
  obscureText: isPasswordHidden,

  decoration: InputDecoration(
    labelText: "New Password",
    border: const OutlineInputBorder(),

    suffixIcon: IconButton(
      icon: Icon(
        isPasswordHidden
            ? Icons.visibility_off
            : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          isPasswordHidden = !isPasswordHidden;
        });
      },
    ),
  ),

  validator: (value) {
    if (value == null || value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  },
),

                    const SizedBox(height: 20),

                    /// Confirm Password
                  
TextFormField(
  controller: confirmPasswordController,
  obscureText: isConfirmPasswordHidden,

  decoration: InputDecoration(
    labelText: "Confirm Password",
    border: const OutlineInputBorder(),

    suffixIcon: IconButton(
      icon: Icon(
        isConfirmPasswordHidden
            ? Icons.visibility_off
            : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          isConfirmPasswordHidden = !isConfirmPasswordHidden;
        });
      },
    ),
  ),

  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != passwordController.text) {
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