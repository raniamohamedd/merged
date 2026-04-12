import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class DoctorContact {
  final int id;
  final String name;
  final String specialty;

  DoctorContact({
    required this.id,
    required this.name,
    required this.specialty,
  });
}

class PatientAlertItem {
  final int id;
  final String doctorName;
  final String type;
  final String severity;
  final String details;
  final String time;
  final String status;

  PatientAlertItem({
    required this.id,
    required this.doctorName,
    required this.type,
    required this.severity,
    required this.details,
    required this.time,
    required this.status,
  });
}

class PatientAlertsPage extends StatefulWidget {
  const PatientAlertsPage({super.key});

  @override
  State<PatientAlertsPage> createState() => _PatientAlertsPageState();
}

class _PatientAlertsPageState extends State<PatientAlertsPage> {
  final TextEditingController detailsController = TextEditingController();

  final List<DoctorContact> doctors = [
    DoctorContact(
      id: 1,
      name: "Dr. Sarah Mitchell",
      specialty: "Cardiologist",
    ),
    DoctorContact(
      id: 2,
      name: "Dr. Ahmed Ali",
      specialty: "Dermatologist",
    ),
    DoctorContact(
      id: 3,
      name: "Dr. Mona Hassan",
      specialty: "Neurologist",
    ),
  ];

  final List<String> alertTypes = [
    "Emergency Alert",
    "Missed Medication",
    "Side Effect",
    "New Symptom",
    "Medication Question",
    "Follow-up Update",
  ];

  DoctorContact? selectedDoctor;
  String selectedType = "Emergency Alert";
  String selectedSeverity = "medium";

  List<PatientAlertItem> sentAlerts = [
    PatientAlertItem(
      id: 1,
      doctorName: "Dr. Sarah Mitchell",
      type: "New Symptom",
      severity: "medium",
      details: "I have been feeling dizzy since this morning.",
      time: "10:20 AM",
      status: "sent",
    ),
    PatientAlertItem(
      id: 2,
      doctorName: "Dr. Ahmed Ali",
      type: "Side Effect",
      severity: "high",
      details: "Skin rash appeared after taking the medication.",
      time: "Yesterday",
      status: "viewed",
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedDoctor = doctors.first;
  }

  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }

  Color severityColor(String severity) {
    switch (severity) {
      case "high":
        return Colors.redAccent;
      case "medium":
        return Colors.orangeAccent;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

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

  void sendAlert() {
    if (selectedDoctor == null || detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please complete all required fields"),
          backgroundColor: AppColors.blueColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    final newAlert = PatientAlertItem(
      id: DateTime.now().millisecondsSinceEpoch,
      doctorName: selectedDoctor!.name,
      type: selectedType,
      severity: selectedSeverity,
      details: detailsController.text.trim(),
      time: "Just now",
      status: "sent",
    );

    setState(() {
      sentAlerts.insert(0, newAlert);
      detailsController.clear();
      selectedSeverity = "medium";
      selectedType = "Emergency Alert";
    });

    showSuccessDialog();
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
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your update has been sent to ${selectedDoctor?.name ?? 'the doctor'}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
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
                        borderRadius: BorderRadius.circular(18),
                      ),
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
                child: Icon(
                  icon,
                  color: AppColors.blueColor,
                  size: 20,
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.blueColor.withOpacity(.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blueColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.medical_services_outlined,
                      color: AppColors.blueColor),
                  const SizedBox(width: 8),
                  const Text(
                    "Choose Doctor",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...doctors.map((doctor) {
                final isSelected = selectedDoctor?.id == doctor.id;

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
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.blueColor)
                      : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    setState(() {
                      selectedDoctor = doctor;
                    });
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
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.report_gmailerrorred_outlined,
                      color: AppColors.blueColor),
                  const SizedBox(width: 8),
                  const Text(
                    "Choose Update Type",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...alertTypes.map((type) {
                final isSelected = selectedType == type;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    type,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.blueColor)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedType = type;
                    });
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
            onTap: () {
              setState(() {
                selectedSeverity = level;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: level != "high" ? 8 : 0,
              ),
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

  Widget buildSentItem(PatientAlertItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.blueColor.withOpacity(.08)),
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
                  Icons.person_outline,
                  color: AppColors.blueColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                item.time,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag(
                item.type,
                AppColors.blueColor.withOpacity(.12),
                AppColors.blueColor,
              ),
              const SizedBox(width: 8),
              _buildTag(
                item.severity.toUpperCase(),
                severityColor(item.severity).withOpacity(.12),
                severityColor(item.severity),
              ),
              const SizedBox(width: 8),
              _buildTag(
                item.status.toUpperCase(),
                statusColor(item.status).withOpacity(.12),
                statusColor(item.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.details,
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
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
                    value: selectedType,
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
                          color: AppColors.blueColor.withOpacity(.18),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: AppColors.blueColor,
                          width: 1.8,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: sendAlert,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text(
                        "Send to Doctor",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            buildSectionCard(
              title: "Previously Sent Updates",
              icon: Icons.history_outlined,
              child: sentAlerts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "No updates sent yet",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : Column(
                      children: sentAlerts
                          .map((item) => buildSentItem(item))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}