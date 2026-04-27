import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/forget_password_2.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_form.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_header.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_tail.dart';
import 'package:flutter_application_2/Features/auth/widgets/shared/custom_button.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/routing/navigators/navigation_screen_doc.dart';
import 'package:flutter_application_2/core/routing/navigators/navigator_patient.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
Future<void> handleLogin() async {
  if (!formKey.currentState!.validate()) return;

  setState(() {
    loading = true;
  });

  try {
    final response = isPatient
        ? await ApiService.login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          )
        : await ApiService.logindoc(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

    final prefs = await SharedPreferences.getInstance();

final data = response;

final tokenData = data["token"];

final accessToken = tokenData["accessToken"];
final refreshToken = tokenData["refreshToken"];

    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
    await prefs.setString("role", isPatient ? "patient" : "doctor");

    UserSession.accessToken = accessToken;
    UserSession.refreshToken = refreshToken;

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    showSuccessToastAndNavigate(
      isPatient ? "patient" : "doctor",
    );
  } catch (e) {
  setState(() => loading = false);
  showErrorDialog(e.toString());
}
}
void showErrorDialog(String message) {
  String friendlyMessage = "Something went wrong. Please try again.";
  
  if (message.contains("password")) {
    friendlyMessage = "Incorrect password. Please try again.";
  } else if (message.contains("email") || message.contains("user")) {
    friendlyMessage = "Email not found. Please check your email.";
  } else if (message.contains("network") || message.contains("socket")) {
    friendlyMessage = "No internet connection. Please check your network.";
  } else if (message.contains("timeout")) {
    friendlyMessage = "Request timed out. Please try again.";
  }
  
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                friendlyMessage,
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Try Again"),
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
                      color: isPatient ? AppColors.blueColor : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Patient",
                      style: TextStyle(
                        color: isPatient ? AppColors.blueColor : Colors.black54,
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
                      color: !isPatient ? AppColors.blueColor : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Doctor",
                      style: TextStyle(
                        color: !isPatient ? AppColors.blueColor : Colors.black54,
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

  void showSuccessToastAndNavigate(String role) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 110,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
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
                    role == "patient"
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

      if (role == "patient") {
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
}