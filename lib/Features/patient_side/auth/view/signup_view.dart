import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/login_view.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/shared/custom_button.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/shared/custom_textfeild.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/signup_widgets/custom_radio_button.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/signup_widgets/signup_form.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/signup_widgets/signup_header.dart';
import 'package:flutter_application_2/Features/patient_side/auth/widgets/signup_widgets/signup_tail.dart';
import 'package:flutter_application_2/Features/patient_side/translate.dart/trans.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/sizes.dart';
import 'package:flutter_application_2/data/login_data.dart';
import 'package:flutter_application_2/models/doctor_model.dart';
import 'package:flutter_application_2/models/patient_model.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference patients = FirebaseFirestore.instance.collection(
    'patients',
  );
  CollectionReference doctors = FirebaseFirestore.instance.collection(
    'doctors',
  );
        bool isArabic = true;
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

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
    final TextEditingController agecontroller = TextEditingController();


  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController genderController = TextEditingController();
  late List<Map<String, dynamic>> _pages;


  bool loading = false;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String hospitalName = '';

  String _selectedType = 'User';
  String? _selectedSpecialization;

  void handleSelection(String type, String? specialization) {
    setState(() {
      _selectedType = type;
      _selectedSpecialization = specialization;
    });
  }
  
  @override
  Widget build(BuildContext context) {
  //     bool isArabic = true;
  //       @override
  // void initState() {
  //   super.initState();
  //   _pages = loginArabic;
  // }

  // void _toggleLanguage() {
  //   setState(() {
  //     isArabic = !isArabic;
  //     _pages = isArabic ? loginArabic : loginArabic;
  //   });
  // }

    return Directionality(
                  textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,

      child: ModalProgressHUD(
        inAsyncCall: loading,
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                               Padding(
                   padding: const EdgeInsets.only(right: 20.0,top: 50,left: 20),
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
                 SizedBox(height: 12,),
                 
                 SignupHeader(Create:isArabic?"Create Account":"إنشاء حساب", Join: isArabic?"Join our healthcare community":"انضم إلى مجتمعنا الصحي",),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      SignupForm(
                        formkey: formkey,
                        userNameController: userNameController,
                        emailController: emailController,
                        phoneNumberController: phoneNumberController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        genderController: genderController, agecontroller:agecontroller,
                         name: isArabic?"Enter your full name":"ادخل اسمك", 
                         age: isArabic?"Enter your age":"ادخل سنك", 
                         email: isArabic?"Enter your email":"ادخل بريدك الالكتروني",
                          phone: isArabic?"Enter your phone":"ادخل رقم هاتفك",
                           pass: isArabic?"Enter your password":"ادخل كلمه السر" 
                      ),
                      const SizedBox(height: 20),
                      // UserDoctorSelector(onSelectionChanged: handleSelection),
                      if (_selectedType == "Doctor") ...[
                        const SizedBox(height: 20),
      
                        
                        CustomTextField(
                          label: "Enter your hospital name",
                          icon: Icons.local_hospital_outlined,
                          controller: hospitalController,
                          // validator: (value) {
                          //   if (value == null || value.trim().isEmpty) {
                          //     return "Please enter your hospital name";
                          //   }
                          //   final trimmedValue = value.trim();
                          //   if (trimmedValue.length < 3) {
                          //     return "Hospital name must be at least 3 letters";
                          //   }
                          //   if (!RegExp(
                          //     r'^[a-zA-Z\s]+$',
                          //   ).hasMatch(trimmedValue)) {
                          //     return "Hospital name should contain letters only";
                          //   }
                          //   return null;
                          // },
                        ),
                      ],
                      const SizedBox(height: 12),
      
                      CustomButton(
                        text: isArabic?"Sign up":'انشاء حساب',
                        onPressed: () async {
                          if (formkey.currentState!.validate()) {
                            // تحقق من اختيار التخصص لو المستخدم دكتور
                            if (_selectedType == "Doctor" &&
                                _selectedSpecialization == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please choose your specialization",
                                  ),
                                ),
                              );
                              if (_selectedType == "Doctor") {
                                final hospitalName = hospitalController.text
                                    .trim();
      
                                if (hospitalName.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please enter your hospital name",
                                      ),
                                    ),
                                  );
                                  return;
                                }
      
                                if (hospitalName.length < 3) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Hospital name must be at least 3 letters",
                                      ),
                                    ),
                                  );
                                  return;
                                }
      
                                if (!RegExp(
                                  r'^[a-zA-Z\s]+$',
                                ).hasMatch(hospitalName)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Hospital name should contain letters only",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }
      
                              return;
                            }
      
                            loading = true;
                            setState(() {});
                            try {
                              var auth = FirebaseAuth.instance;
                              UserCredential userCredential = await auth
                                  .createUserWithEmailAndPassword(
                                    email: emailController.text
                                        .toLowerCase()
                                        .trim(),
                                    password: passwordController.text.trim(),
                                  );
      
                              UserModel newUser = UserModel(
                                user_id: userCredential.user!.uid,
                                name: userNameController.text.trim(),
                                email: emailController.text.trim().toLowerCase(),
                                password: passwordController.text.trim(),
                                phoneNum: int.parse(
                                  phoneNumberController.text.trim(),
                                ),
                                image:"lib/images/profile.png",
                                gender: genderController.text.trim(),
                                role: _selectedType,
                              );
      
                              await users
                                  .doc(userCredential.user!.uid)
                                  .set(newUser.toMap());
      
                              if (_selectedType == "Doctor") {
                                DoctorModel newDoctor = DoctorModel(
                                  doctorId: userCredential.user!.uid,
                                  name: userNameController.text.trim(),
                                  specialization: _selectedSpecialization!,
                                  hospital: hospitalController.text,
                                      // imageUrl: "lib/images/profile.png",
                                );
      
                                await doctors
                                    .doc(userCredential.user!.uid)
                                    .set(newDoctor.toMap());
                              } else {
                                PatientModel newPatient = PatientModel(
                                  patientId: userCredential.user!.uid,
                                );
      
                                await patients
                                    .doc(userCredential.user!.uid)
                                    .set(newPatient.toMap());
                              }
      
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'The password provided is too weak.',
                                    ),
                                  ),
                                );
                              } else if (e.code == 'email-already-in-use') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'The account already exists for that email.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Something went wrong.'),
                                ),
                              );
                            }
      
                            loading = false;
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      SignupTail(back: isArabic?"Back to Login":"الرجوع لتسجيل الدخول",),
                      const SizedBox(height: 2),
      
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
