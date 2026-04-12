import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/reset_screen.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

class ForgotpasswordView extends StatefulWidget {
  const ForgotpasswordView({super.key});

  @override
  State<ForgotpasswordView> createState() => _ForgotpasswordViewState();
}

class _ForgotpasswordViewState extends State<ForgotpasswordView> {

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

      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: AppColors.blueColor,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: formKey,

          child: Column(
            children: [

              const SizedBox(height: 40),

              TextFormField(
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

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),

                  onPressed: loading ? null : handleForget,

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Send OTP",
                          style: TextStyle(fontSize: 18),
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





















