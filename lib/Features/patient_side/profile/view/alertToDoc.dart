import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

// ── Models ──────────────────────────────────────────────────

class DoctorContact {
  final String id;
  final String name;
  final String specialty;

  DoctorContact({
    required this.id,
    required this.name,
    required this.specialty,
  });
}

class SentSosItem {
  final String id;
  final String doctorName;
  final String doctorEmail;
  final String updateType;
  final String severity;
  final String details;
  final bool isResolved;
  final DateTime createdAt;

  SentSosItem({
    required this.id,
    required this.doctorName,
    required this.doctorEmail,
    required this.updateType,
    required this.severity,
    required this.details,
    required this.isResolved,
    required this.createdAt,
  });

  factory SentSosItem.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctorId'] as Map<String, dynamic>? ?? {};
    return SentSosItem(
      id: json['_id'] ?? '',
      doctorName: doctor['fullName'] ?? 'Unknown Doctor',
      doctorEmail: doctor['email'] ?? '',
      updateType: json['updateType'] ?? 'other',
      severity: json['severity'] ?? 'medium',
      details: json['details'] ?? '',
      isResolved: json['isResolved'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// ── Page ─────────────────────────────────────────────────────

class PatientAlertsPage extends StatefulWidget {
  const PatientAlertsPage({super.key});

  @override
  State<PatientAlertsPage> createState() => _PatientAlertsPageState();
}

class _PatientAlertsPageState extends State<PatientAlertsPage> {
  final TextEditingController detailsController = TextEditingController();

  List<DoctorContact> doctors = [];
  DoctorContact? selectedDoctor;

  // ✅ القيم دي هي اللي بتتبعت للـ API بالظبط
  String selectedType = "chest_pain";
  String selectedSeverity = "medium";

  final List<String> alertTypes = [
    "chest_pain",
    "breathing",
    "unconscious",
    "fall",
    "other",
  ];

  // ✅ Real SOS history from API
  List<SentSosItem> sentSosHistory = [];
  bool isLoadingHistory = false;
  bool isSending = false;

  // ── Helpers ─────────────────────────────────────────────

  String displayAlertType(String type) {
    switch (type) {
      case "chest_pain":
        return "Chest Pain";
      case "breathing":
        return "Breathing Issue";
      case "unconscious":
        return "Unconscious";
      case "fall":
        return "Fall";
      default:
        return "Other";
    }
  }

  Color _severityColorFor(String severity) {
    switch (severity) {
      case 'high':
      case 'critical':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.green;
      default:
        return Colors.orangeAccent;
    }
  }

  Color severityColor(String severity) => _severityColorFor(severity);

  Color statusColor(String status) {
    switch (status) {
      case "sent":
        return AppColors.blueColor;
      case "viewed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // ── Data loading ─────────────────────────────────────────

  Future<void> loadDoctors() async {
    try {
      final List data = await ApiService.getmydoctors();
      setState(() {
        doctors = data.map<DoctorContact>((doc) {
          return DoctorContact(
            id: doc['userId']?['_id'] ?? '',
            name: doc['userId']?['fullName'] ?? 'Unknown Doctor',
            specialty: doc['specialization'] ?? 'Doctor',
          );
        }).toList();
        if (doctors.isNotEmpty) {
          selectedDoctor = doctors.first;
        }
      });
    } catch (e) {
      debugPrint("Doctors error: $e");
    }
  }

  Future<void> _loadMySos() async {
    setState(() => isLoadingHistory = true);
    try {
      final data = await ApiService.getMySos();
      final items = data.map((e) => SentSosItem.fromJson(e)).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        sentSosHistory = items;
        isLoadingHistory = false;
      });
    } catch (e) {
      setState(() => isLoadingHistory = false);
      debugPrint("My SOS error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadDoctors();
    _loadMySos();
  }

  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }

  // ── Send alert ───────────────────────────────────────────

  Future<void> sendAlert() async {
    if (selectedDoctor == null || detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please complete all required fields"),
          backgroundColor: AppColors.blueColor,
        ),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      await ApiService.createSos(
        doctorId: selectedDoctor!.id,
        updateType: selectedType, // ✅ بيتبعت مباشرة
        severity: selectedSeverity,
        details: detailsController.text.trim(),
      );

      setState(() {
        detailsController.clear();
        selectedSeverity = "medium";
        selectedType = "chest_pain";
        isSending = false;
      });

      // ✅ reload التاريخ من الـ API
      await _loadMySos();

      if (!mounted) return;
      showSuccessDialog();
    } catch (e) {
      setState(() => isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send SOS: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showSuccessDialog() {
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
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueColor.withOpacity(.12),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 38,
                    color: AppColors.blueColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Update Sent Successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your update has been sent to ${selectedDoctor?.name ?? 'the doctor'}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── UI helpers ───────────────────────────────────────────

  Widget buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.blueColor.withOpacity(.1),
                child: Icon(icon, color: AppColors.blueColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueColor,
                  ),
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

  Widget buildPickerField({
    required String title,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: AppColors.blueColor.withOpacity(.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blueColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  void showDoctorsSheet() {
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
                    borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Icon(Icons.medical_services_outlined,
                    color: AppColors.blueColor),
                const SizedBox(width: 8),
                const Text("Choose Doctor",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 18),
              ...doctors.map((doctor) {
                final isSelected = selectedDoctor?.id == doctor.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.blueColor.withOpacity(.1),
                    child:
                        Icon(Icons.person, color: AppColors.blueColor),
                  ),
                  title: Text(doctor.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(doctor.specialty),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: AppColors.blueColor)
                      : const Icon(Icons.arrow_forward_ios_rounded,
                          size: 16),
                  onTap: () {
                    setState(() => selectedDoctor = doctor);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void showAlertTypesSheet() {
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
                    borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Icon(Icons.report_gmailerrorred_outlined,
                    color: AppColors.blueColor),
                const SizedBox(width: 8),
                const Text("Choose Update Type",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 18),
              ...alertTypes.map((type) {
                final isSelected = selectedType == type;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(displayAlertType(type),
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: AppColors.blueColor)
                      : null,
                  onTap: () {
                    setState(() => selectedType = type);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget buildSeveritySelector() {
    final levels = ["low", "medium", "high"];
    return Row(
      children: levels.map((level) {
        final selected = selectedSeverity == level;
        final color = severityColor(level);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedSeverity = level),
            child: Container(
              margin: EdgeInsets.only(right: level != "high" ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? color : color.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(.35)),
              ),
              child: Center(
                child: Text(
                  level[0].toUpperCase() + level.substring(1),
                  style: TextStyle(
                    color: selected ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(14)),
      child: Text(text,
          style: TextStyle(
              color: fg, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }

  // ✅ Real SOS history item
  Widget _buildSosHistoryItem(SentSosItem item) {
    final sevColor = _severityColorFor(item.severity);
    final statusColor =
        item.isResolved ? const Color(0xFF27AE60) : const Color(0xFFE74C3C);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: AppColors.blueColor.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Doctor + time
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.blueColor.withOpacity(.1),
                child: Icon(Icons.medical_services_outlined,
                    color: AppColors.blueColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.doctorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    if (item.doctorEmail.isNotEmpty)
                      Text(item.doctorEmail,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Text(_formatTimeAgo(item.createdAt),
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),

          // ── Tags
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildTag(
                displayAlertType(item.updateType),
                AppColors.blueColor.withOpacity(.12),
                AppColors.blueColor,
              ),
              _buildTag(
                item.severity.toUpperCase(),
                sevColor.withOpacity(.12),
                sevColor,
              ),
              _buildTag(
                item.isResolved ? 'RESOLVED' : 'ACTIVE',
                statusColor.withOpacity(.12),
                statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Details
          Text(item.details,
              style: TextStyle(
                  color: Colors.grey.shade800, height: 1.45)),
        ],
      ),
    );
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
        title: Text(
          "Send Update",
          style: TextStyle(
            color: AppColors.blueColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.blueColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.blueColor),
            onPressed: _loadMySos,
            tooltip: "Refresh history",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            // ── Send form
            buildSectionCard(
              title: "Send New Update to Doctor",
              icon: Icons.send_outlined,
              child: Column(
                children: [
                  buildPickerField(
                    title: "Doctor",
                    icon: Icons.medical_services_outlined,
                    value: selectedDoctor?.name ?? "Choose Doctor",
                    onTap: showDoctorsSheet,
                  ),
                  const SizedBox(height: 14),
                  buildPickerField(
                    title: "Type",
                    icon: Icons.report_gmailerrorred_outlined,
                    value: displayAlertType(selectedType),
                    onTap: showAlertTypesSheet,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Severity",
                      style: TextStyle(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildSeveritySelector(),
                  const SizedBox(height: 14),
                  TextField(
                    controller: detailsController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Write full details here...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                            color: AppColors.blueColor.withOpacity(.18)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            BorderSide(color: AppColors.blueColor, width: 1.8),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSending ? null : sendAlert,
                      icon: isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        isSending ? "Sending..." : "Send to Doctor",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── History from API
            buildSectionCard(
              title: "Previously Sent Updates",
              icon: Icons.history_outlined,
              child: isLoadingHistory
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : sentSosHistory.isEmpty
                      ? Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "No updates sent yet",
                            style:
                                TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : Column(
                          children: sentSosHistory
                              .map(_buildSosHistoryItem)
                              .toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}