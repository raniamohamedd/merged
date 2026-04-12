import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/auth/screens/otp_screen.dart';
import 'package:flutter_application_2/Features/auth/widgets/shared/custom_button.dart';
import 'package:flutter_application_2/Features/auth/widgets/shared/custom_textfeild.dart';
import 'package:flutter_application_2/Features/auth/widgets/signup_widgets/signup_header.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController yearsOfExperienceController =
      TextEditingController();
  final TextEditingController licenseNumberController =
      TextEditingController();

  String gender = "Male";
  String selectedRole = "Patient";
  DateTime? selectedDOB;
  bool loading = false;

  String? selectedSpecialization;
  String? selectedProofFileName;
  String? clinicLocation;

  final List<String> specializations = [
    "Cardiology",
    "Dermatology",
    "Neurology",
    "Pediatrics",
    "Orthopedics",
    "Dentistry",
    "Psychiatry",
    "General Surgery",
    "Internal Medicine",
    "Ophthalmology",
    "ENT",
    "Gynecology",
    "Urology",
    "Radiology",
    "General Practice",
  ];

  final List<String> demoLocations = [
    "Cairo, Egypt",
    "Giza, Egypt",
    "Alexandria, Egypt",
    "Mansoura, Egypt",
    "Tanta, Egypt",
    "Assiut, Egypt",
  ];

  Future<void> pickDOB() async {
    final DateTime initialDate = DateTime(2000, 1, 1);
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime.now();

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

  void fakePickFile() {
    setState(() {
      selectedProofFileName = "medical_license.pdf";
    });
  }

  Future<void> chooseClinicLocation() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.blueColor),
                  const SizedBox(width: 8),
                  const Text(
                    "Choose Clinic Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...demoLocations.map(
                (location) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.blueColor.withOpacity(.12),
                    child: Icon(
                      Icons.place_outlined,
                      color: AppColors.blueColor,
                    ),
                  ),
                  title: Text(location),
                  onTap: () {
                    setState(() {
                      clinicLocation = location;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> handleSignUp() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );
      return;
    }

    if (selectedRole == "Doctor") {
      if (selectedSpecialization == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select specialization"),
          ),
        );
        return;
      }

      if (clinicLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please choose clinic location"),
          ),
        );
        return;
      }

      if (selectedProofFileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please upload proof document"),
          ),
        );
        return;
      }
    }

    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (selectedRole == "Patient") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: emailController.text.trim(),
          ),
        ),
      );
    } else {
      showDoctorRequestDialog();
    }
  }

  void showDoctorRequestDialog() {
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
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueColor.withOpacity(.12),
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 38,
                    color: AppColors.blueColor,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Request Submitted",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your request has been sent successfully.\nOur team will review your information and documents.\nOnce approved, you will receive an email response.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withOpacity(.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.blueColor.withOpacity(.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.blueColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Please keep checking your email for the approval result.",
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
    final bool isPatient = selectedRole == "Patient";

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedRole = "Patient";
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isPatient ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isPatient
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
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
                        fontWeight: FontWeight.w700,
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
                  selectedRole = "Doctor";
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isPatient ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: !isPatient
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
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
                        color:
                            !isPatient ? AppColors.blueColor : Colors.black54,
                        fontWeight: FontWeight.w700,
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

  Widget buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => gender = "Male"),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: gender == "Male"
                    ? AppColors.blueColor
                    : Colors.transparent,
                border: Border.all(color: AppColors.blueColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.male,
                    color:
                        gender == "Male" ? Colors.white : AppColors.blueColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Male",
                    style: TextStyle(
                      color:
                          gender == "Male" ? Colors.white : AppColors.blueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => gender = "Female"),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: gender == "Female"
                    ? AppColors.blueColor
                    : Colors.transparent,
                border: Border.all(color: AppColors.blueColor),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.female,
                    color:
                        gender == "Female" ? Colors.white : AppColors.blueColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Female",
                    style: TextStyle(
                      color: gender == "Female"
                          ? Colors.white
                          : AppColors.blueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSpecializationDropdown() {
    if (selectedRole != "Doctor") return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blueColor.withOpacity(.35)),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        value: selectedSpecialization,
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.local_hospital_outlined),
        ),
        hint: const Text("Select Specialization"),
        isExpanded: true,
        items: specializations.map((spec) {
          return DropdownMenuItem<String>(
            value: spec,
            child: Text(spec),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSpecialization = value;
          });
        },
        validator: (value) {
          if (selectedRole == "Doctor" && value == null) {
            return "Please select specialization";
          }
          return null;
        },
      ),
    );
  }

  Widget buildClinicLocationPicker() {
    if (selectedRole != "Doctor") return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blueColor.withOpacity(.35)),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map_outlined),
              SizedBox(width: 8),
              Text(
                "Clinic Location",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            clinicLocation ?? "No location selected yet",
            style: TextStyle(
              color: clinicLocation == null
                  ? Colors.grey
                  : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blueColor,
                side: BorderSide(color: AppColors.blueColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: chooseClinicLocation,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text("Choose from Map"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProofUploadBox() {
    if (selectedRole != "Doctor") return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blueColor.withOpacity(.35)),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.upload_file_outlined),
              SizedBox(width: 8),
              Text(
                "Proof Document",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            selectedProofFileName ?? "No file selected",
            style: TextStyle(
              color: selectedProofFileName == null
                  ? Colors.grey
                  : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: fakePickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Upload Proof"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDoctorFields() {
    if (selectedRole != "Doctor") return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 16),
        buildSpecializationField(),
        const SizedBox(height: 16),
     CustomTextField(
  label: "License Number",
  icon: Icons.badge_outlined,
  controller: licenseNumberController,
  keyboardType: TextInputType.number,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  validator: (v) {
    if (selectedRole == "Doctor" && (v == null || v.isEmpty)) {
      return "Enter license number";
    }
    return null;
  },
),   const SizedBox(height: 16),
     CustomTextField(
  label: "Years of Experience",
  icon: Icons.work_outline,
  controller: yearsOfExperienceController,
  keyboardType: TextInputType.number,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  validator: (v) {
    if (selectedRole == "Doctor" && (v == null || v.isEmpty)) {
      return "Enter years of experience";
    }
    return null;
  },
),   const SizedBox(height: 16),
        buildClinicLocationPicker(),
        const SizedBox(height: 16),
        buildProofUploadBox(),
      ],
    );
  }

  @override
  void dispose() {
    userNameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    phoneController.dispose();
    yearsOfExperienceController.dispose();
    licenseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPatient = selectedRole == "Patient";

    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      size: 20,
                      color: AppColors.greyColor,
                    ),
                  ),
                  SignupHeader(
                    Create: "Create Account",
                    Join: "Join our healthcare community",
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          buildRoleSelector(),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: "Full Name",
                            icon: Icons.person,
                            controller: fullNameController,
                            validator: (v) =>
                                v == null || v.isEmpty ? "Enter full name" : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: "User Name",
                            icon: Icons.person_outline,
                            controller: userNameController,
                            validator: (v) =>
                                v == null || v.isEmpty ? "Enter user name" : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: "Email",
                            icon: Icons.email_outlined,
                            controller: emailController,
                            validator: (v) =>
                                v == null || v.isEmpty ? "Enter email" : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: "Password",
                            icon: Icons.lock_outline,
                            controller: passwordController,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Enter password";
                              }
                              if (v.length < 8) {
                                return "Password must be at least 8 chars";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: "Confirm Password",
                            icon: Icons.lock_reset_outlined,
                            controller: confirmPasswordController,
                            isPassword: true,
                            validator: (v) => v == null || v.isEmpty
                                ? "Confirm your password"
                                : null,
                          ),
                          const SizedBox(height: 16),
                       CustomTextField(
  label: "Phone Number",
  icon: Icons.phone_outlined,
  controller: phoneController,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly, // أرقام بس
    LengthLimitingTextInputFormatter(11),   // أقصى 11 رقم
  ],
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Enter your phone number";
    }

    if (value.length != 11) {
      return "Phone number must be 11 digits";
    }

    if (!value.startsWith("01")) {
      return "Phone must start with 01";
    }

    return null;
  },
),   const SizedBox(height: 16),
                          buildGenderSelector(),
                          const SizedBox(height: 16),
                  buildDobField(),
if (selectedDOB == null)
  // Padding(
  //   padding: const EdgeInsets.only(top: 8, left: 4),
  //   child: Align(
  //     alignment: Alignment.centerLeft,
  //     child: Text(
  //       "Select date of birth",
  //       style: TextStyle(
  //         color: AppColors.redColor,
  //         fontSize: 12,
  //       ),
  //     ),
  //   ),
  // ),   
       buildDoctorFields(),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: isPatient
                                ? "Sign Up as Patient"
                                : "Apply as Doctor",
                            onPressed: handleSignUp,
                          ),
                          const SizedBox(height: 16),
                          if (!isPatient)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.blueColor.withOpacity(.06),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.blueColor.withOpacity(.14),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.blueColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Doctor accounts are reviewed manually before approval.",
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: AppColors.blueColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget buildSpecializationField() {
  if (selectedRole != "Doctor") return const SizedBox.shrink();

  return GestureDetector(
    onTap: showSpecializationSheet,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blueColor.withOpacity(.35)),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(Icons.local_hospital_outlined,
              color: AppColors.blueColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedSpecialization ?? "Select Specialization",
              style: TextStyle(
                color: selectedSpecialization == null
                    ? Colors.grey
                    : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    ),
  );
}
  void showSpecializationSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.local_hospital,
                    color: AppColors.blueColor),
                const SizedBox(width: 8),
                const Text(
                  "Choose Specialization",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // القائمة
            Expanded(
              child: ListView.builder(
                itemCount: specializations.length,
                itemBuilder: (context, index) {
                  final spec = specializations[index];
                  final isSelected = spec == selectedSpecialization;

                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected
                        ? AppColors.blueColor.withOpacity(.1)
                        : null,
                    title: Text(spec),
                    trailing: isSelected
                        ? Icon(Icons.check,
                            color: AppColors.blueColor)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedSpecialization = spec;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
Future<void> showDobPickerSheet() async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(Icons.cake_outlined, color: AppColors.blueColor),
                const SizedBox(width: 8),
                const Text(
                  "Choose Date of Birth",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              selectedDOB == null
                  ? "No date selected yet"
                  : "Selected: ${DateFormat("yyyy-MM-dd").format(selectedDOB!)}",
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDOB ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDOB = picked;
                      dobController.text =
                          DateFormat("yyyy-MM-dd").format(picked);
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("Pick Date"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
Widget buildDobField() {
  return GestureDetector(
    onTap: showDobPickerSheet,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blueColor.withOpacity(.35)),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: AppColors.blueColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedDOB == null
                  ? "Select Date of Birth"
                  : DateFormat("yyyy-MM-dd").format(selectedDOB!),
              style: TextStyle(
                color: selectedDOB == null ? Colors.grey : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    ),
  );
}
}
