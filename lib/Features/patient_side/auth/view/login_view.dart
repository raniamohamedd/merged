import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/navigation_screen.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/forgot_password_view.dart';
import 'package:flutter_application_2/Features/patient_side/translate.dart/trans.dart';
import 'package:flutter_application_2/core/constants/methods.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/shared/custom_button.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/login_widgets/login_form.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/login_widgets/login_header.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/login_widgets/login_tail.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/data/login_data.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/services/firestore_services.dart';
import 'package:flutter_application_2/shared/widgets/navigator.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    bool isArabic = true;
  late List<Map<String, dynamic>> _pages;

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
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Padding(
                   padding: const EdgeInsets.only(right: 20.0,top: 20,left: 20),
                   child: Row(
                     children: [
                      Spacer(),
      TextButton.icon(
                        onPressed: _toggleLanguage,
                        icon: Icon(FontAwesomeIcons.language, size: 12),
                        label: Text(
                          isArabic ? "العربية" : "English",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>((states) {
                                if (states.contains(WidgetState.hovered)) {
                                  return const Color.fromARGB(
                                    255,
                                    175,
                                    215,
                                    248,
                                  ); // 🔵 الخلفية لما الماوس ييجي فوق
                                }
                                return Colors.transparent; // الخلفية العادية
                              }),
                          foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                            states,
                          ) {
                            if (states.contains(WidgetState.hovered)) {
                              return AppColors
                                  .blueColor; // 🔵 لون النص والأيقونة لما الماوس فوق
                            }
                            return AppColors.blackColor; // اللون العادي
                          }),
                          side: WidgetStateProperty.all(
                            const BorderSide(color: Colors.black, width: 0.1),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
      
                                     ],
                   ),
                 ),
                 SizedBox(height: 40),
      
                LoginHeader(Smart: isArabic? "Smart Healthcare":"الرعاية الصحية الذكية",Connect: isArabic?"Connect with your healthcare provider":"تواصل مع مقدم الرعاية الصحي الخاص بك",),
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
                         enemail: isArabic?"Enter your email":"ادخل بريدك الالكتروني",
                          enpass: isArabic?"Enter your password":"ادخل كلمه السر",
                      ),
      
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=> ForgotpasswordView())
                          );
                        },
                        child: Text(
                         isArabic? "Forgot Password ?":"نسيت كلمه السر ؟",
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      CustomButton(
                        text:                        isArabic ? "Login" : "تسجيل " 
      ,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            loading = true;
                            setState(() {});
                            try {
                              var auth = FirebaseAuth.instance;
                              UserCredential userCredential = await auth
                                  .signInWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
      
                              FirestoreService firestoreService =
                                  FirestoreService();
      
                              UserModel user = await firestoreService.getUser(
                                userCredential.user!.uid,
                              );
                              UserSession.currentUser = user;                       
                               
                              
                        
                              if (user.role == 'Doctor') {
      
                               UserSession.currentDoctor = await firestoreService.getDoctor( 
                                  userCredential.user!.uid,
                                );
      
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NavigationScreen(),
                                  ),
                                );
                              } 
                              
                              
                              else {
      
                                UserSession.currentPatient = await firestoreService.getPatient( 
                                  userCredential.user!.uid,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NavigationnScreen(),
                                  ),
                                );
                              }
                              snackBarMessage(
                                context,
                                "Sign in successfully",
                                color: Colors.green,
                              );
      
                              
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                snackBarMessage(
                                  context,
                                  'No user found for that email.',
                                  color: Colors.red,
                                );
                              } else if (e.code == 'wrong-password') {
                                snackBarMessage(
                                  context,
                                  'Wrong password provided for that user.',
                                  color: Colors.red,
                                );
                              } else {
                                snackBarMessage(
                                  context,
                                  'Something went wrong. Please try again later.',
                                  color: Colors.red,
                                );
                              }
                            }
                            loading = false;
                            setState(() {});
                          }
                        },
                      ),
                      SizedBox(height: 10),
      
                      LoginTail(
                        signUp: isArabic?'Sign up here':'سجل هنا', 
                      create: isArabic?"Don't have an account? ":"ليس لديك حساب؟"),
                    ],
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
