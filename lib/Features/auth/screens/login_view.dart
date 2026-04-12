import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/forget_password_2.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_form.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_header.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_tail.dart';
import 'package:flutter_application_2/Features/auth/widgets/shared/custom_button.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/routing/navigators/navigation_screen_doc.dart';
import 'package:flutter_application_2/core/routing/navigators/navigator_patient.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool isPatient = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(
      "https://medpal-production-2abe.up.railway.app/auth/login",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to login");
    }
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool("isLoggedIn", true);
      await prefs.setString("accessToken", "dummy_token");
      await prefs.setString("refreshToken", "dummy_refresh");
      await prefs.setString("role", isPatient ? "patient" : "doctor");

      UserSession.accessToken = "dummy_token";
      UserSession.refreshToken = "dummy_refresh";

      setState(() {
        loading = false;
      });

      showSuccessDialog();
    } catch (e) {
      setState(() {
        loading = false;
      });

      showErrorDialog();
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
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
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueColor.withOpacity(.1),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 40,
                    color: AppColors.blueColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Login Successful",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPatient
                      ? "Welcome back! You are logged in as a patient."
                      : "Welcome doctor! You are logged in successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      if (isPatient) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NavigationnScreen(),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NavigationnScreendoc(),
                          ),
                        );
                      }
                    },
                    child: const Text("Continue"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
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
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(.1),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Login Failed",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Something went wrong. Please try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isPatient = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isPatient ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isPatient
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: isPatient
                          ? AppColors.blueColor
                          : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Patient",
                      style: TextStyle(
                        color: isPatient
                            ? AppColors.blueColor
                            : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isPatient = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isPatient ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !isPatient
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      color: !isPatient
                          ? AppColors.blueColor
                          : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Doctor",
                      style: TextStyle(
                        color: !isPatient
                            ? AppColors.blueColor
                            : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                LoginHeader(
                  Smart: "Smart Healthcare",
                  Connect: "Connect with your healthcare provider",
                ),
                const SizedBox(height: 20),
                buildRoleSelector(),
                const SizedBox(height: 24),
                LoginForm(
                  formKey: formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  enemail: "Enter your email",
                  enpass: "Enter your password",
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotpasswordView2(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password ?",
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                loading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: isPatient
                            ? "Login as Patient"
                            : "Login as Doctor",
                        onPressed: handleLogin,
                      ),
                const SizedBox(height: 20),
                LoginTail(
                  signUp: 'Sign up here',
                  create: "Don't have an account? ",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void showSuccessToastAndNavigate() {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 110,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppColors.blueColor.withOpacity(.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.blueColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPatient
                      ? "Logged in successfully as patient"
                      : "Logged in successfully as doctor",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();

    if (!mounted) return;

    if (isPatient) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavigationnScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavigationnScreendoc()),
      );
    }
  });
}
}