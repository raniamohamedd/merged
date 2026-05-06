import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/forget_password_2.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_form.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_header.dart';
import 'package:flutter_application_2/Features/auth/widgets/login_widgets/login_tail.dart';
import 'package:flutter_application_2/Features/auth/widgets/shared/custom_button.dart';

import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/data/login_data.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:flutter_application_2/core/routing/navigators/navigator_patient.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreendoc extends StatefulWidget {
  const LoginScreendoc({super.key});

  @override
  State<LoginScreendoc> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreendoc> {
  bool isArabic = true;
  late List<Map<String, dynamic>> _pages;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _pages = loginArabic;
  }

  void _toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
      _pages = isArabic ? loginArabic : loginArabic;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ✅ Function to call login API
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("https://medpal-production-01b6.up.railway.app/auth/login");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to login: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                SizedBox(height: 100),
                LoginHeader(
                  Smart: isArabic ? "Smart Healthcare" : "الرعاية الصحية الذكية",
                  Connect: isArabic
                      ? "Connect with your healthcare provider"
                      : "تواصل مع مقدم الرعاية الصحي الخاص بك",
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      LoginForm(
                        formKey: formKey,
                        emailController: emailController,
                        passwordController: passwordController,
                        enemail: isArabic ? "Enter your email" : "ادخل بريدك الالكتروني",
                        enpass: isArabic ? "Enter your password" : "ادخل كلمه السر",
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotpasswordView2()),
                          );
                        },
                        child: Text(
                          isArabic ? "Forgot Password ?" : "نسيت كلمه السر ؟",
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
          CustomButton(
  text: isArabic ? "Login" : "تسجيل",
  onPressed: () async {

    if (formKey.currentState!.validate()) {

      setState(() {
        loading = true;
      });

      // تسجيل دخول وهمي مؤقت
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool("isLoggedIn", true);
      await prefs.setString("accessToken", "dummy_token");
      await prefs.setString("refreshToken", "dummy_refresh");

      // حفظ في session
      UserSession.accessToken = "dummy_token";
      UserSession.refreshToken = "dummy_refresh";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login successful"),
          backgroundColor: AppColors.blueColor,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavigationnScreen()),
      );

      setState(() {
        loading = false;
      });
    }
  },
),           LoginTail(
                        signUp: isArabic ? 'Sign up here' : 'سجل هنا',
                        create: isArabic ? "Don't have an account? " : "ليس لديك حساب؟",
                      ),

  LoginTaildoc(
                        signUp: isArabic ? 'Sign up here' : 'سجل هنا',
                        create: isArabic ? "Don't have an account? " : "ليس لديك حساب؟",
                      ),                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}