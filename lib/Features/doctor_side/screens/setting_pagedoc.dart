import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

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

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final specialtyController = TextEditingController();
  final phoneController = TextEditingController();
  final licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  // استرجاع بيانات بروفايل الطبيب
  Future<void> _loadDoctorProfile() async {
    try {
      final profileData = await ApiService.getDoctorProfile();
      setState(() {
        fullNameController.text = profileData['data']['fullName'];
        emailController.text = profileData['data']['email'];
        specialtyController.text = profileData['data']['specialization'];
        phoneController.text = profileData['data']['phoneNumber'];
        licenseController.text = profileData['data']['medicalLicense'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحميل بروفايل الطبيب: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  void handleSaveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully'),
        backgroundColor: AppColors.blueColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),

            _buildCard(
              title: 'Profile Settings',
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
                    label: 'Specialty',
                    controller: specialtyController,
                    icon: Icons.local_hospital_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Phone Number',
                    controller: phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Medical License',
                    controller: licenseController,
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildCard(
              title: 'Notification Preferences',
              icon: Icons.notifications_none_outlined,
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Email Notifications',
                    subtitle: 'Receive email updates about patients',
                    value: emailNotifications,
                    onChanged: (val) {
                      setState(() => emailNotifications = val);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Emergency Alerts',
                    subtitle: 'Get notified of critical patient alerts',
                    value: emergencyAlerts,
                    onChanged: (val) {
                      setState(() => emergencyAlerts = val);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Medication Reminders',
                    subtitle: 'Alerts for missed patient medications',
                    value: medicationReminders,
                    onChanged: (val) {
                      setState(() => medicationReminders = val);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Patient Messages',
                    subtitle: 'Notifications for new patient messages',
                    value: patientMessages,
                    onChanged: (val) {
                      setState(() => patientMessages = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: handleSaveSettings,
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Save All Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(.18),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Profile',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your information and preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
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
                child: Icon(
                  icon,
                  color: AppColors.blueColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
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
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.greyColor.withOpacity(0.04),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.greyColor,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.blueColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.greyColor.withOpacity(.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.blueColor,
            width: 1.7,
          ),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
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
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }
}