import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/login_view.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/services/api_service.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? profileImageUrl; // رابط صورة البروفايل
  File? _selectedImageFile; // الصورة المختارة محليًا قبل رفعها

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

  // تحميل بيانات البروفايل
  void loadProfile() async {
    try {
      var response = await ApiService.getProfile();
      var user = response["data"]["user"];

      setState(() {
        profileData["phone"] = user["phone"] ?? "";
        profileData["fullName"] =
            "${user["firstName"] ?? ""} ${user["lastName"] ?? ""}";
        profileData["email"] = user["email"] ?? "";
        profileData["gender"] = user["gender"] ?? "";
        profileData["dateOfBirth"] =
            user["DOB"] != null ? user["DOB"].toString().split("T")[0] : "";
        profileImageUrl =
            user["image"] != null ? user["image"]["secure_url"] : null;
      });
    } catch (e) {
      print("Profile error: $e");
    }
  }

  // اختيار ورفع صورة
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    // عرض الصورة فورًا
    setState(() {
      _selectedImageFile = File(pickedFile.path);
    });

    // تحويل الصورة لـ PNG
    final bytes = await pickedFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot read selected image")),
      );
      return;
    }
    final pngBytes = img.encodePng(originalImage);

    // حفظ الصورة مؤقتًا
    final tempDir = Directory.systemTemp;
    final pngFile = File('${tempDir.path}/profile_image.png');
    await pngFile.writeAsBytes(pngBytes);

    // رفع الصورة بالـ PATCH مع التوكن
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");

    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('https://medpal-production-2abe.up.railway.app/user/image'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      pngFile.path,
      contentType: MediaType('image', 'png'),
    ));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(respStr);
      final uploadedImageUrl = data["data"]["user"]["image"]["secure_url"];

      setState(() {
        profileImageUrl = uploadedImageUrl;
        _selectedImageFile = null; // نظف الصورة المؤقتة
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile image uploaded successfully")),
      );
    } else {
      print("Failed: $respStr");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

Future<void> handleSave() async {
  setState(() {
    isEditing = false;
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    // جهز الباي لود
    Map<String, dynamic> payload = {
      "email": profileData["email"], // لو السيرفر يحتاج
      "bloodType": profileData["bloodType"],
      "height": profileData["height"]!.isNotEmpty
          ? int.tryParse(profileData["height"]!)
          : null,
      "weight": profileData["weight"]!.isNotEmpty
          ? int.tryParse(profileData["weight"]!)
          : null,
      "allergies": profileData["allergies"],
      "note": profileData["notes"],
      "chronicDiseases": [], // لو عندك بيانات من قبل ضيفها هنا
    };

    // PATCH للبيانات
    final response = await http.patch(
      Uri.parse("https://medpal-production-2abe.up.railway.app/patient/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );
    } else {
      print("Failed to save: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: ${response.body}")),
      );
    }

    // لو فيه صورة جديدة، ارفعها بعد حفظ البيانات
    if (_selectedImageFile != null) {
      await pickAndUploadImage();
    }
  } catch (e) {
    print("Error saving profile: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving profile: $e")),
    );
  }
}
 void handleCancel() {
    setState(() {
      isEditing = false;
    });
  }

  String getInitials(String name) {
    return name
        .split(" ")
        .map((e) => e.isNotEmpty ? e[0] : "")
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

  void callEmergency() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '123');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cannot launch phone dialer")));
    }
  }

  Widget buildTextField(String label, String field,
      {TextInputType? keyboardType, int? maxLines}) {
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
          borderSide:
              BorderSide(color: AppColors.blueColor.withOpacity(0.7), width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5C7AEA), Color(0xFF00C6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              padding:
                  const EdgeInsets.only(top: 50, bottom: 30, left: 16, right: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_active,
                        color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  const Text(
                    "My Profile",
                    style: TextStyle(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit,
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
                  )
                ],
              ),
            ),
            SizedBox(height: 20,),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        key: ValueKey(profileImageUrl ?? _selectedImageFile?.path),
                        radius: 50,
                        backgroundColor: AppColors.blueColor,
                        backgroundImage: _selectedImageFile != null
                            ? FileImage(_selectedImageFile!)
                            : (profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : null),
                        child: (_selectedImageFile == null && profileImageUrl == null)
                            ? Text(getInitials(profileData["fullName"]!),
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white))
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
                              child:
                                  Icon(Icons.camera_alt, color: AppColors.blueColor),
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildBadge(
                          profileData["gender"]!.toLowerCase() == "male"
                              ? "Male"
                              : "Female",
                          Colors.blueAccent),
                      const SizedBox(width: 8),
                      buildBadge("${getAge(profileData["dateOfBirth"]!)} yrs",
                          Colors.blueAccent),
                      const SizedBox(width: 8),
                      buildBadge(profileData["bloodType"]!, Colors.blueAccent),
                    ],
                  ),
                ],
              ),
            ),
            buildSectionCard("Personal Information", [
              buildTextField("Full Name", "fullName"),
              const SizedBox(height: 12),
              buildTextField("Email", "email", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              buildTextField("Phone", "phone", keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              buildTextField("Date of Birth", "dateOfBirth"),
              const SizedBox(height: 12),
              buildTextField("Address", "address"),
            ]),
            buildSectionCard("Medical Information", [
              buildTextField("Blood Type", "bloodType"),
              const SizedBox(height: 12),
              buildTextField("Height (cm)", "height", keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              buildTextField("Weight (kg)", "weight", keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              buildTextField("Allergies", "allergies", maxLines: 2),
              const SizedBox(height: 12),
              buildTextField("Chronic Conditions", "chronicConditions", maxLines: 2),
              const SizedBox(height: 12),
              buildTextField("Notes", "notes", maxLines: 3),
            ]),
            buildSectionCard("Emergency Contact", [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: callEmergency,
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text(
                    "Call Emergency",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  minimumSize: const Size.fromHeight(50),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Log Out",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: () async {
                  UserSession.accessToken = "";
                  UserSession.refreshToken = "";
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildSectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      shadowColor: Colors.black26,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}