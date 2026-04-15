import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/patient_side/profile/view/alertToDoc.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorContact {
  final String name;
  final String specialty;
  final String phone;

  DoctorContact({
    required this.name,
    required this.specialty,
    required this.phone,
  });
}

class PatientProfilePage extends StatefulWidget {
  final String userEmail;
  final VoidCallback onBack;

  const PatientProfilePage({
    super.key,
    required this.userEmail,
    required this.onBack,
  });

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  bool isEditing = false;
  String? profileImageUrl;
  File? _selectedImageFile;

  final List<DoctorContact> doctors = [
    DoctorContact(
      name: "Dr. Sarah Mitchell",
      specialty: "Cardiologist",
      phone: "01012345678",
    ),
    DoctorContact(
      name: "Dr. Ahmed Ali",
      specialty: "Dermatologist",
      phone: "01123456789",
    ),
    DoctorContact(
      name: "Dr. Mona Hassan",
      specialty: "Neurologist",
      phone: "01234567890",
    ),
  ];

  Map<String, String> profileData = {
    "fullName": "",
    "email": "",
    "phone": "",
    "dateOfBirth": "",
    "gender": "",
    "bloodType": "",
    "height": "",
    "weight": "",
    "address": "",
    "emergencyContact": "",
    "emergencyName": "",
    "allergies": "",
    "chronicConditions": "",
    "notes": "",
  };

  @override
  void initState() {
    super.initState();
    profileData["email"] = widget.userEmail;
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final response = await ApiService.getProfile();
      final user = response["data"]["user"];

      setState(() {
        profileData["phone"] = user["phone"] ?? "";
        profileData["fullName"] =
            "${user["firstName"] ?? ""} ${user["lastName"] ?? ""}".trim();
        profileData["email"] = user["email"] ?? "";
        profileData["gender"] = user["gender"] ?? "";
        profileData["dateOfBirth"] =
            user["DOB"] != null ? user["DOB"].toString().split("T")[0] : "";
        profileImageUrl =
            user["image"] != null ? user["image"]["secure_url"] : null;
      });
    } catch (e) {
      debugPrint("Profile error: $e");
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _selectedImageFile = File(pickedFile.path);
    });

    final bytes = await pickedFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      _showTopMessage("Cannot read selected image");
      return;
    }

    final pngBytes = img.encodePng(originalImage);
    final tempDir = Directory.systemTemp;
    final pngFile = File('${tempDir.path}/profile_image.png');
    await pngFile.writeAsBytes(pngBytes);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('https://medpal-production-e325.up.railway.app/user/image'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        pngFile.path,
        contentType: MediaType('image', 'png'),
      ),
    );

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(respStr);
      final uploadedImageUrl = data["data"]["user"]["image"]["secure_url"];

      setState(() {
        profileImageUrl = uploadedImageUrl;
        _selectedImageFile = null;
      });

      _showTopMessage("Profile image uploaded successfully");
    } else {
      _showTopMessage("Failed to upload image");
    }
  }

  Future<void> handleSave() async {
    setState(() {
      isEditing = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      if (token == null || token.isEmpty) {
        _showTopMessage("User not logged in");
        return;
      }

      final payload = {
        "email": profileData["email"],
        "bloodType": profileData["bloodType"],
        "height": profileData["height"]!.isNotEmpty
            ? int.tryParse(profileData["height"]!)
            : null,
        "weight": profileData["weight"]!.isNotEmpty
            ? int.tryParse(profileData["weight"]!)
            : null,
        "allergies": profileData["allergies"],
        "note": profileData["notes"],
        "chronicDiseases": [],
      };

      final response = await http.patch(
        Uri.parse(
          "https://medpal-production-e325.up.railway.app/patient/profile",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        _showTopMessage("Profile saved successfully");
      } else {
        _showTopMessage("Failed to save profile");
      }

      if (_selectedImageFile != null) {
        await pickAndUploadImage();
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      _showTopMessage("Error saving profile");
    }
  }

  String getInitials(String name) {
    return name
        .split(" ")
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  int getAge(String dob) {
    if (dob.isEmpty) return 0;
    final birthDate = DateTime.parse(dob);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> callEmergency() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '123');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showTopMessage("Cannot launch phone dialer");
    }
  }

  void handleInAppCall() {
    showDoctorsSheet("in_app");
  }

  void handleRegularCall() {
    showDoctorsSheet("regular");
  }

  void showDoctorsSheet(String actionType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
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
                  Icon(Icons.medical_services_outlined, color: AppColors.blueColor),
                  const SizedBox(width: 8),
                  Text(
                    actionType == "regular"
                        ? "Choose Doctor for Regular Call"
                        : "Choose Doctor for In-App Call",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...doctors.map((doctor) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.blueColor.withOpacity(.1),
                    child: Icon(Icons.person, color: AppColors.blueColor),
                  ),
                  title: Text(
                    doctor.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(doctor.specialty),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    if (actionType == "regular") {
                      final Uri phoneUri =
                          Uri(scheme: 'tel', path: doctor.phone);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      } else {
                        _showTopMessage("Cannot launch phone dialer");
                      }
                    } else {
                      _showTopMessage(
                        "Starting in-app call with ${doctor.name}...",
                      );
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showTopMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.blueColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String field, {
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextField(
      keyboardType: keyboardType,
      controller: TextEditingController(text: profileData[field]),
      readOnly: !isEditing,
      maxLines: maxLines ?? 1,
      onChanged: (val) {
        profileData[field] = val;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.blueColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.blueColor.withOpacity(0.18),
            width: 1.3,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.blueColor.withOpacity(.1),
                child: Icon(
                  icon,
                  color: AppColors.blueColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.blueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = profileData["fullName"]!.isEmpty
        ? "Patient Name"
        : profileData["fullName"]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 52,
                bottom: 34,
                left: 18,
                right: 18,
              ),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueColor.withOpacity(.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isEditing ? Icons.check_rounded : Icons.edit_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () {
                      if (isEditing) {
                        handleSave();
                      } else {
                        setState(() {
                          isEditing = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        key: ValueKey(profileImageUrl ?? _selectedImageFile?.path),
                        radius: 52,
                        backgroundColor: AppColors.blueColor,
                        backgroundImage: _selectedImageFile != null
                            ? FileImage(_selectedImageFile!)
                            : (profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : null) as ImageProvider?,
                        child: (_selectedImageFile == null &&
                                profileImageUrl == null)
                            ? Text(
                                getInitials(fullName),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickAndUploadImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.blueColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profileData["email"] ?? "",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      buildBadge(
                        profileData["gender"]!.isEmpty
                            ? "Unknown"
                            : (profileData["gender"]!.toLowerCase() == "male"
                                ? "Male"
                                : "Female"),
                        Colors.blueAccent,
                      ),
                      buildBadge(
                        "${getAge(profileData["dateOfBirth"]!)} yrs",
                        Colors.blueAccent,
                      ),
                      if (profileData["bloodType"]!.isNotEmpty)
                        buildBadge(profileData["bloodType"]!, Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
            buildSectionCard(
              "Personal Information",
              Icons.person_outline,
              [
                buildTextField("Full Name", "fullName"),
                const SizedBox(height: 12),
                buildTextField(
                  "Email",
                  "email",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                buildTextField(
                  "Phone",
                  "phone",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                buildTextField("Date of Birth", "dateOfBirth"),
                const SizedBox(height: 12),
                buildTextField("Address", "address"),
              ],
            ),
            buildSectionCard(
              "Medical Information",
              Icons.favorite_border,
              [
                buildTextField("Blood Type", "bloodType"),
                const SizedBox(height: 12),
                buildTextField(
                  "Height (cm)",
                  "height",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                buildTextField(
                  "Weight (kg)",
                  "weight",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                buildTextField("Allergies", "allergies", maxLines: 2),
                const SizedBox(height: 12),
                buildTextField(
                  "Chronic Conditions",
                  "chronicConditions",
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                buildTextField("Notes", "notes", maxLines: 3),
              ],
            ),
            buildSectionCard(
              "Communication & Support",
              Icons.support_agent_outlined,
              [
                buildActionCard(
                  title: "In-App Call",
                  subtitle: "Start an in-app call with your doctor",
                  icon: Icons.call_outlined,
                  color: AppColors.blueColor,
                  onTap: handleInAppCall,
                ),
                const SizedBox(height: 12),
                buildActionCard(
                  title: "Regular Call",
                  subtitle: "Call a doctor using your mobile network",
                  icon: Icons.phone_forwarded_outlined,
                  color: Colors.green,
                  onTap: handleRegularCall,
                ),
                const SizedBox(height: 12),
                buildActionCard(
                  title: "Emergency Call",
                  subtitle: "Contact emergency support immediately",
                  icon: Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  onTap: callEmergency,
                ),
                           const SizedBox(height: 12),

             buildActionCard(
  title: "Send Update",
  subtitle: "Report symptoms or updates to your doctor",
  icon: Icons.send_outlined,
  color: Colors.purple,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientAlertsPage(),
      ),
    );
  },
),
             
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 17),
                ),
                onPressed: () async {
                  UserSession.accessToken = "";
                  UserSession.refreshToken = "";
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}