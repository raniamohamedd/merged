import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

class UpdatePatientProfileScreen extends StatefulWidget {
  const UpdatePatientProfileScreen({super.key});

  @override
  State<UpdatePatientProfileScreen> createState() =>
      _UpdatePatientProfileScreenState();
}

class _UpdatePatientProfileScreenState
    extends State<UpdatePatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _loadingData = true;

  // Controllers
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _noteController = TextEditingController();
  final _diseaseNameController = TextEditingController();

  String? _selectedBloodType;
  List<Map<String, dynamic>> _chronicDiseases = [];

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _noteController.dispose();
    _diseaseNameController.dispose();
    super.dispose();
  }

  // ── جيب البيانات الحالية من الـ API ──────────────────────────────────────
  Future<void> _loadCurrentProfile() async {
    try {
      final data = await ApiService.getPatientProfile();
      if (data.isEmpty) {
        setState(() => _loadingData = false);
        return;
      }

      final profile = data["data"] ?? data;

      setState(() {
        _selectedBloodType = profile["bloodType"]?.toString();
        _heightController.text = profile["height"]?.toString() ?? "";
        _weightController.text = profile["weight"]?.toString() ?? "";
        _allergiesController.text = profile["allergies"]?.toString() ?? "";
        _noteController.text = profile["note"]?.toString() ?? "";

        // Chronic diseases
        if (profile["chronicDiseases"] != null) {
          _chronicDiseases = (profile["chronicDiseases"] as List)
              .map<Map<String, dynamic>>((e) => {
                    "name": e["name"] ?? "",
                    "diagnosisDate": e["diagnosisDate"] ??
                        DateTime.now().toIso8601String().split("T")[0],
                    "medications": e["medications"] ?? [],
                    "status": e["status"] ?? "stable",
                    "notes": e["notes"] ?? "",
                  })
              .toList();
        }

        _loadingData = false;
      });
    } catch (e) {
      setState(() => _loadingData = false);
    }
  }

  void _addDisease() {
    final name = _diseaseNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _chronicDiseases.add({
        "name": name,
        "diagnosisDate": DateTime.now().toIso8601String().split("T")[0],
        "medications": [],
        "status": "stable",
        "notes": "",
      });
      _diseaseNameController.clear();
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your blood type"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ApiService.completeSignup(
        chronicDiseases: _chronicDiseases,
        allergies: _allergiesController.text.trim(),
        bloodType: _selectedBloodType!,
        height: int.tryParse(_heightController.text.trim()) ?? 0,
        weight: int.tryParse(_weightController.text.trim()) ?? 0,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      // ✅ ورّي رسالة نجاح وارجع للصفحة اللي قبلها
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Profile updated successfully ✅"),
            ],
          ),
          backgroundColor: AppColors.blueColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context, true); // ✅ true = اتحدث
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Update Medical Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Edit your health information",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Save button في الهيدر
                  GestureDetector(
                    onTap: _loading ? null : _handleSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _loading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.blueColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Save",
                              style: TextStyle(
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────
            Expanded(
              child: _loadingData
                  ? Center(
                      child: CircularProgressIndicator(
                          color: AppColors.blueColor),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Blood Type ────────────────────────
                            _sectionTitle(
                                "Blood Type *", Icons.bloodtype_outlined),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _bloodTypes.map((type) {
                                final selected = _selectedBloodType == type;
                                return GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedBloodType = type),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.blueColor
                                          : AppColors.surfaceColor,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.blueColor
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.blueColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),

                            // ── Height & Weight ───────────────────
                            _sectionTitle("Physical Info *",
                                Icons.straighten_outlined),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _heightController,
                                    label: "Height (cm)",
                                    icon: Icons.height,
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        v == null || v.isEmpty
                                            ? "Required"
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _weightController,
                                    label: "Weight (kg)",
                                    icon: Icons.monitor_weight_outlined,
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        v == null || v.isEmpty
                                            ? "Required"
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ── Allergies ─────────────────────────
                            _sectionTitle(
                                "Allergies", Icons.warning_amber_outlined),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: _allergiesController,
                              label:
                                  "e.g. Penicillin, Pollen... (or None)",
                              icon: Icons.warning_amber_outlined,
                            ),
                            const SizedBox(height: 24),

                            // ── Chronic Diseases ──────────────────
                            _sectionTitle("Chronic Diseases",
                                Icons.monitor_heart_outlined),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _diseaseNameController,
                                    decoration: InputDecoration(
                                      hintText:
                                          "e.g. Diabetes, Hypertension...",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13),
                                      filled: true,
                                      fillColor: AppColors.surfaceColor,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _addDisease,
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueColor,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.white, size: 22),
                                  ),
                                ),
                              ],
                            ),
                            if (_chronicDiseases.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _chronicDiseases
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => Chip(
                                        label: Text(entry.value["name"]),
                                        backgroundColor: AppColors.blueColor
                                            .withOpacity(0.1),
                                        labelStyle: TextStyle(
                                            color: AppColors.blueColor,
                                            fontWeight: FontWeight.w600),
                                        deleteIconColor:
                                            AppColors.blueColor,
                                        onDeleted: () => setState(() =>
                                            _chronicDiseases
                                                .removeAt(entry.key)),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 24),

                            // ── Notes ─────────────────────────────
                            _sectionTitle(
                                "Notes (Optional)", Icons.note_outlined),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    "Any additional medical notes...",
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13),
                                filled: true,
                                fillColor: AppColors.surfaceColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // ── Save Button ───────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed:
                                    _loading ? null : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blueColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blueColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.blueColor, size: 20),
        filled: true,
        fillColor: AppColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppColors.blueColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}