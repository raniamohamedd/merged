import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/shared/widgets/error_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool emailNotifications = true;
  bool emergencyAlerts = true;
  bool medicationReminders = true;
  bool patientMessages = true;
  bool isLoading = true;

  File? _selectedImageFile;
  bool _isUploadingImage = false;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final specialtyController = TextEditingController();
  final phoneController = TextEditingController();
  final licenseController = TextEditingController();

  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    try {
      final profileData = await ApiService.getDoctorProfile();
      final data = profileData['data'];

      setState(() {
        fullNameController.text = data['fullName'] ?? '';
        emailController.text = data['email'] ?? '';
        specialtyController.text = data['specialization'] ?? '';
        phoneController.text = data['phone'] ?? '';
        licenseController.text = data['licenseNumber']?.toString() ?? '';
        profileImageUrl = data['profileImage'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showErrorDialog(context, message: e.toString());
    }
  }

  // ── Pick & Upload Image (same as patient) ──────────────────────────────────
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _selectedImageFile = File(pickedFile.path);
      _isUploadingImage = true;
    });

    try {
      final bytes = await pickedFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cannot read selected image"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final pngBytes = img.encodePng(originalImage);
      final tempDir = Directory.systemTemp;
      final pngFile = File('${tempDir.path}/doctor_profile_image.png');
      await pngFile.writeAsBytes(pngBytes);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('https://medpal-production-01b6.up.railway.app/user/image'),
      );

      request.headers['Authorization'] = 'System $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          pngFile.path,
          contentType: MediaType('image', 'png'),
        ),
      );
      

final response = await request.send();
final respStr = await response.stream.bytesToString();

print("IMAGE UPLOAD STATUS: ${response.statusCode}");
print("IMAGE UPLOAD BODY: $respStr");

      if (response.statusCode == 200) {
  final data = jsonDecode(respStr);
final uploadedUrl = data["secure_url"];

        setState(() {
          profileImageUrl = uploadedUrl;
          _selectedImageFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Profile image updated successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to upload image: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void handleSaveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully'),
        backgroundColor: AppColors.blueColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    specialtyController.dispose();
    phoneController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FAFC),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.blueColor),
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.blueColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 22),
                  _buildCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Full Name',
                          controller: fullNameController,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          label: 'Email',
                          controller: emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          label: 'Phone',
                          controller: phoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildCard(
                    title: 'Professional Information',
                    icon: Icons.medical_services_outlined,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Specialization',
                          controller: specialtyController,
                          icon: Icons.local_hospital_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          label: 'License Number',
                          controller: licenseController,
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _buildCard(
                    title: 'Notifications',
                    icon: Icons.notifications_outlined,
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Email Notifications',
                          subtitle: 'Receive updates via email',
                          value: emailNotifications,
                          onChanged: (val) =>
                              setState(() => emailNotifications = val),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          title: 'Emergency Alerts',
                          subtitle: 'Get notified for patient emergencies',
                          value: emergencyAlerts,
                          onChanged: (val) =>
                              setState(() => emergencyAlerts = val),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          title: 'Medication Reminders',
                          subtitle: 'Reminders for patient medications',
                          value: medicationReminders,
                          onChanged: (val) =>
                              setState(() => medicationReminders = val),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          title: 'Patient Messages',
                          subtitle: 'Notifications for new patient messages',
                          value: patientMessages,
                          onChanged: (val) =>
                              setState(() => patientMessages = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
    );
  }

  // ── Profile Header ──────────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blueColor,
        borderRadius: BorderRadius.circular(24),
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
          GestureDetector(
            onTap: pickAndUploadImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(.18),
                  backgroundImage: _selectedImageFile != null
                      ? FileImage(_selectedImageFile!)
                      : (profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null) as ImageProvider?,
                  child: (_selectedImageFile == null && profileImageUrl.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 34)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingImage
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_outlined,
                            size: 14,
                            color: AppColors.blueColor,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullNameController.text.isNotEmpty
                      ? 'Dr. ${fullNameController.text}'
                      : 'Doctor Profile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialtyController.text.isNotEmpty
                      ? specialtyController.text
                      : 'Manage your information',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.camera_alt_outlined,
                        size: 12, color: Colors.white60),
                    const SizedBox(width: 4),
                    const Text(
                      'Tap photo to change',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.blueColor.withOpacity(.1),
                child: Icon(icon, color: AppColors.blueColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.greyColor.withOpacity(0.04),
        labelText: label,
        labelStyle: TextStyle(color: AppColors.greyColor, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.blueColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.blueColor.withOpacity(.08),
          child: Icon(
            Icons.notifications_active_outlined,
            size: 18,
            color: AppColors.blueColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.blueColor,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}

// ── Full Screen Image Viewer ──────────────────────────────────────────────────
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}