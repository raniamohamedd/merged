import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/completeSignUp.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/medication_info_screen.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/core/services/notification_services.dart';
import 'package:timezone/timezone.dart' as tz;

// ── قائمة أسماء الأدوية الشائعة ─────────────────────────────────────────────
const List<Map<String, String>> _commonMedications = [
  {"name": "Panadol", "dosage": "500mg"},
  {"name": "Paracetamol", "dosage": "500mg"},
  {"name": "Ibuprofen", "dosage": "400mg"},
  {"name": "Aspirin", "dosage": "100mg"},
  {"name": "Amoxicillin", "dosage": "500mg"},
  {"name": "Metformin", "dosage": "500mg"},
  {"name": "Amlodipine", "dosage": "5mg"},
  {"name": "Lisinopril", "dosage": "10mg"},
  {"name": "Atorvastatin", "dosage": "20mg"},
  {"name": "Omeprazole", "dosage": "20mg"},
  {"name": "Azithromycin", "dosage": "500mg"},
  {"name": "Ciprofloxacin", "dosage": "500mg"},
  {"name": "Metronidazole", "dosage": "500mg"},
  {"name": "Cetirizine", "dosage": "10mg"},
  {"name": "Loratadine", "dosage": "10mg"},
  {"name": "Vitamin D", "dosage": "1000 IU"},
  {"name": "Vitamin C", "dosage": "500mg"},
  {"name": "Zinc", "dosage": "50mg"},
  {"name": "Calcium", "dosage": "500mg"},
  {"name": "Iron", "dosage": "325mg"},
  {"name": "Insulin", "dosage": "as prescribed"},
  {"name": "Metoprolol", "dosage": "50mg"},
  {"name": "Warfarin", "dosage": "5mg"},
  {"name": "Prednisolone", "dosage": "5mg"},
  {"name": "Salbutamol", "dosage": "100mcg"},
  {"name": "Other", "dosage": ""},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _PatientDashboardUIState();
}

class _PatientDashboardUIState extends State<HomeScreen> {
  // ─── Complete Profile Banner ────────────────────────────────────────────────
  bool _showCompleteBanner = false;

  Future<void> _checkProfileComplete() async {
    try {
      final data = await ApiService.getPatientProfile();
      if (data.isEmpty) {
        if (mounted) setState(() => _showCompleteBanner = true);
        return;
      }
      final profile = data["data"] ?? data;
      final bloodType = profile["bloodType"]?.toString() ?? "";
      final height = profile["height"];
      final weight = profile["weight"];
      final isIncomplete =
          bloodType.isEmpty || height == null || weight == null;
      if (mounted) setState(() => _showCompleteBanner = isIncomplete);
    } catch (_) {
      if (mounted) setState(() => _showCompleteBanner = true);
    }
  }

  // ─── Repeat / Time helpers ──────────────────────────────────────────────────
  final List<String> repeatOptions = [
    "Daily",
    "Twice daily",
    "Three times daily",
    "Weekly",
    "Custom times",
  ];

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  final Map<String, Map<String, String>> medicationDefaults = {};
  List<Map<String, dynamic>> medications = [];
  List<Map<String, String>> upcomingReminders = [];
void _showMedicationWarningDialog(
  BuildContext context,
  Map<String, dynamic> result,
  String medicationName,
  String dosage,
  String repeat,
  String reminderTime,
  List<String> sideEffects,
  String warningLevel,
  String startDate,
) {
  final interaction = result["interactionCheck"] ?? {};
  final compatibility = result["compatibilityCheck"] ?? {};
  final details = (compatibility["details"] as List?) ?? [];

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 8),
          Text("Medication Warning", style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Interaction Check
            if (interaction["summary"] != null) ...[
              const Text("Drug Interactions",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 4),
              Text(interaction["summary"], style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
            ],

            // ── Compatibility Check
            if (details.isNotEmpty) ...[
              const Text("Disease Compatibility",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 4),
              ...details.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🦠 ${d["disease"] ?? ""}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(d["reason"] ?? "", style: const TextStyle(fontSize: 12)),
                          if (d["recommendation"] != null) ...[
                            const SizedBox(height: 4),
                            Text("💡 ${d["recommendation"]}",
                                style: TextStyle(fontSize: 12, color: Colors.blue[700])),
                          ],
                        ],
                      ),
                    ),
                  )),
            ],

            const SizedBox(height: 8),
            const Text("Do you still want to add this medication?",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () async {
            Navigator.pop(ctx);
            // ✅ Force add رغم التحذير — بعت force: true
            await _forceAddMedication(
              medicationName: medicationName,
              dosage: dosage,
              repeat: repeat,
              reminderTime: reminderTime,
              sideEffects: sideEffects,
              warningLevel: warningLevel,
              startDate: startDate,
            );
          },
          child: const Text("Add Anyway", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Future<void> _forceAddMedication({
  required String medicationName,
  required String dosage,
  required String repeat,
  required String reminderTime,
  required List<String> sideEffects,
  required String warningLevel,
  required String startDate,
}) async {
  try {
    await ApiService.forceAddMedication(
      medicationName: medicationName,
      dosage: dosage,
      repeat: repeat,
      reminderTime: reminderTime,
      sideEffects: sideEffects,
      warningLevel: warningLevel,
      startDate: startDate,
    );
    await _loadMedications();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ $medicationName added"), backgroundColor: Colors.green),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
    );
  }
}
  Future<void> _loadMedications() async {
    try {
      final data = await ApiService.getMyMedications();
      final loaded = data.map<Map<String, dynamic>>((item) {
        return {



          
"iddelete": item["medicineId"]?["_id"] ?? item["_id"],
          "id": item["id"],
          "name": item["medicationName"] ?? "",
          "dosage": item["dosage"] ?? "",
          "frequency": item["repeat"] ?? "",
          "repeatType": item["repeat"] ?? "",
          "time": item["reminderTime"] ?? "",
          "reminder": true,
          // ✅ Feature 2: كل دوا عنده حالة تنبيه (true = شغال، false = متوقف)
          "reminderEnabled": true,
          "sideEffects": item["sideEffects"]?.join(", ") ?? "",
          "warningLevel": item["warningLevel"] ?? "low",
        };
      }).toList();

      setState(() => medications = loaded);

      for (final med in medications) {
        if (med["reminderEnabled"] == true) {
          await _scheduleMedicationReminders(med);
        }
      }
      _refreshUpcomingReminders();
    } catch (e) {
      print("Error loading meds: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _checkProfileComplete();
  }

  int _generateMedicationId() {
    if (medications.isEmpty) return 5000;
    final ids = medications
        .map((e) => (e["id"] as int?) ?? 0)
        .where((id) => id >= 0)
        .toList();
    ids.sort();
    return ids.last + 10;
  }

  List<String> _extractTimes(String timeString) {
    return timeString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool _isValidSingleTime(String value) {
    final regex = RegExp(r'^(0?[1-9]|1[0-2]):([0-5][0-9])\s?(AM|PM)$',
        caseSensitive: false);
    return regex.hasMatch(value.trim());
  }

  bool _isValidTimeInput(String value) {
    final times = _extractTimes(value);
    if (times.isEmpty) return false;
    return times.every(_isValidSingleTime);
  }

  DateTime _parseTimeToDate(String timeText) {
    final now = DateTime.now();
    final cleaned = timeText.trim().toUpperCase();
    final ampmRegex = RegExp(r'(\d{1,2}):(\d{2})\s?(AM|PM)');
    final ampmMatch = ampmRegex.firstMatch(cleaned);
    int hour, minute;
    if (ampmMatch != null) {
      hour = int.parse(ampmMatch.group(1)!);
      minute = int.parse(ampmMatch.group(2)!);
      final period = ampmMatch.group(3)!;
      if (period == "PM" && hour != 12) hour += 12;
      if (period == "AM" && hour == 12) hour = 0;
    } else {
      final parts = cleaned.split(":");
      if (parts.length < 2) throw Exception("Invalid time format");
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
    }
    DateTime scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _scheduleMedicationReminders(Map<String, dynamic> med) async {
    final timeStr = med["time"]?.toString() ?? "";
    if (timeStr.isEmpty) return;
    final times = _extractTimes(timeStr);
    final repeatType = med["repeatType"];

    for (int i = 0; i < times.length; i++) {
      final timeText = times[i];
      final localDate = _parseTimeToDate(timeText);
      DateTime finalDate = localDate;

      if (repeatType == "Weekly" && med["weeklyDay"] != null) {
        final targetWeekday = _weekdayFromString(med["weeklyDay"]);
        while (finalDate.weekday != targetWeekday) {
          finalDate = finalDate.add(const Duration(days: 1));
        }
      }

      final scheduledTime = tz.TZDateTime.from(finalDate, tz.local);
      final followUpTime = tz.TZDateTime.from(
        finalDate.add(const Duration(minutes: 1)),
        tz.local,
      );

      await NotificationService.showScheduledNotification(
        id: med["id"].hashCode + i,
        title: 'Reminder: ${med["name"]}',
        body: 'Time to take ${med["dosage"]} at $timeText',
        scheduledTime: scheduledTime,
      );

      await NotificationService.showScheduledNotification(
        id: med["id"].hashCode + i + 1000,
        title: 'Did you take ${med["name"]}?',
        body: 'Please confirm your dose',
        scheduledTime: followUpTime,
payload: jsonEncode({
  "type": "dose_confirmation",
  "medicationId": med["iddelete"],  // ✅ correct _id
  "medicationName": med["name"],
  "dosage": med["dosage"],
  "scheduledTime": followUpTime.toString(),
}),
      );
    }
  }

  Future<void> _cancelMedicationReminders(Map<String, dynamic> med) async {
    final timeStr = med["time"]?.toString() ?? "";
    if (timeStr.isEmpty) return;
    final times = _extractTimes(timeStr);
    for (int i = 0; i < times.length; i++) {
      await NotificationService.cancelNotification(med["id"].hashCode + i);
      await NotificationService.cancelNotification(
          med["id"].hashCode + i + 1000);
    }
  }

void _refreshUpcomingReminders() {
  upcomingReminders.clear();
  for (final med in medications) {
    if (med["reminderEnabled"] == true) {
      final medFullName = "${med["name"]} ${med["dosage"]}";
      final timeStr = med["time"]?.toString() ?? "";
      if (timeStr.isEmpty) continue;
      final times = _extractTimes(timeStr);
      for (final t in times) {
    upcomingReminders.add({
  "time": t,
  "medication": medFullName,
  "medicationId": med["iddelete"] ?? med["id"].toString(),
  "medicationName": med["name"] ?? "",
  "dosage": med["dosage"] ?? "",
});
      }
    }
  }
}
  int _weekdayFromString(String day) {
    switch (day) {
      case "Monday": return DateTime.monday;
      case "Tuesday": return DateTime.tuesday;
      case "Wednesday": return DateTime.wednesday;
      case "Thursday": return DateTime.thursday;
      case "Friday": return DateTime.friday;
      case "Saturday": return DateTime.saturday;
      case "Sunday": return DateTime.sunday;
      default: return DateTime.monday;
    }
  }

  String _formatTime12(int hour, int minute, String period) {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
  }

  String formatTimeForApi(String time) {
    final parts = time.split(' ');
    final hm = parts[0];
    final ampm = parts[1];
    int hour = int.parse(hm.split(':')[0]);
    int minute = int.parse(hm.split(':')[1]);
    if (ampm == "PM" && hour != 12) hour += 12;
    if (ampm == "AM" && hour == 12) hour = 0;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  String mapRepeatToApi(String repeatType) {
    switch (repeatType) {
      case "Daily": return "daily";
      case "Weekly": return "weekly";
      case "Twice daily":
      case "Three times daily":
      case "Custom times": return "every_x_hours";
      default: return "daily";
    }
  }

  String mapWarningToApi(String level) {
    switch (level) {
      case "low": return "safe";
      case "medium": return "moderate";
      case "high": return "severe";
      default: return "safe";
    }
  }

  String getStartDate() {
    final now = DateTime.now().toUtc();
    return "${now.toIso8601String().split('.')[0]}Z";
  }

  // ─── Feature 2: Toggle Reminder Lock ────────────────────────────────────────
  void _toggleReminderEnabled(Map<String, dynamic> med) async {
    final isEnabled = med["reminderEnabled"] as bool? ?? true;
    setState(() => med["reminderEnabled"] = !isEnabled);

    if (!isEnabled) {
      // كان متوقف → شغله
      await _scheduleMedicationReminders(med);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🔔 Reminder enabled for ${med["name"]}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      // كان شغال → وقفه
      await _cancelMedicationReminders(med);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🔕 Reminder disabled for ${med["name"]}"),
          backgroundColor: Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    setState(() => _refreshUpcomingReminders());
  }

  // ─── Time Wheel Picker ────────────────────────────────────────────────────
  Future<String?> _showTimeWheelPicker({String? initialTime}) async {
    int selectedHour = 8;
    int selectedMinute = 0;
    String selectedPeriod = "AM";

    if (initialTime != null && initialTime.trim().isNotEmpty) {
      final parts = initialTime.trim().split(RegExp(r'[: ]'));
      if (parts.length >= 3) {
        selectedHour = int.tryParse(parts[0]) ?? 8;
        selectedMinute = int.tryParse(parts[1]) ?? 0;
        selectedPeriod = parts[2].toUpperCase();
      }
    }

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: 320,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text("Select Time",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedHour - 1),
                            onSelectedItemChanged: (i) =>
                                setSheetState(() => selectedHour = i + 1),
                            children: List.generate(12, (i) => Center(
                              child: Text((i + 1).toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 22)),
                            )),
                          ),
                        ),
                        const Text(":", style: TextStyle(fontSize: 24)),
                        SizedBox(
                          width: 70,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedMinute),
                            onSelectedItemChanged: (i) =>
                                setSheetState(() => selectedMinute = i),
                            children: List.generate(60, (i) => Center(
                              child: Text(i.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 22)),
                            )),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedPeriod == "AM" ? 0 : 1),
                            onSelectedItemChanged: (i) => setSheetState(
                                () => selectedPeriod = i == 0 ? "AM" : "PM"),
                            children: const [
                              Center(child: Text("AM", style: TextStyle(fontSize: 22))),
                              Center(child: Text("PM", style: TextStyle(fontSize: 22))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.blueColor),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel",
                                style: TextStyle(color: AppColors.blueColor)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context,
                                _formatTime12(selectedHour, selectedMinute, selectedPeriod)),
                            child: const Text("Done",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openEditTimeDialog(Map<String, dynamic> med) {
    final controller = TextEditingController(text: med["time"]);
    String editedTime = med["time"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Edit Reminder Time - ${med["name"]}"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Time",
              hintText: "Example: 08:00 AM, 08:00 PM",
            ),
            onChanged: (value) => editedTime = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueColor),
              onPressed: () async {
                if (!_isValidTimeInput(editedTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Enter time like 08:00 AM or 08:00 AM, 08:00 PM"),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }
                try {
                  await _cancelMedicationReminders(med);
                  setState(() {
                    med["time"] = editedTime.trim();
                    med["frequency"] = _extractTimes(editedTime).length > 1
                        ? "Multiple times daily" : "Once daily";
                    _refreshUpcomingReminders();
                  });
                  if (med["reminderEnabled"] == true) {
                    await _scheduleMedicationReminders(med);
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Reminder time updated for ${med["name"]}"),
                    backgroundColor: AppColors.blueColor,
                  ));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Update error: $e"),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void openAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add Medication"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.blueColor.withOpacity(.1),
                  child: Icon(Icons.camera_alt, color: AppColors.blueColor),
                ),
                title: const Text("Scan Medication"),
                subtitle: const Text("Use camera & AI to detect medication"),
                onTap: () {
                  Navigator.pop(context);
                  openScanMedicationDialog();
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.withOpacity(.2),
                  child: const Icon(Icons.edit, color: Colors.black),
                ),
                title: const Text("Add Manually"),
                subtitle: const Text("Enter medication details manually"),
                onTap: () {
                  Navigator.pop(context);
                  openManualAddDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Feature 1 + 3: Manual Add Dialog ────────────────────────────────────────
  void openManualAddDialog() {
    // ── Feature 3: medication suggestion state
    String? selectedMedName;    // الاسم المختار من القائمة
    bool isOtherSelected = false; // لو اختار "Other"
    String medName = "";
    String dosage = "";
    String sideEffects = "";
    String warningLevel = "low";
    String repeatType = "Daily";
    String weeklyDay = "Monday";
    List<String> selectedTimes = ["08:00 AM"];
    bool isLoading = false;

    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final sideEffectsController = TextEditingController();

    // فلترة الأدوية حسب البحث
    String searchQuery = "";
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {

            // قائمة الأدوية المفلترة
            final filteredMeds = searchQuery.isEmpty
                ? _commonMedications
                : _commonMedications.where((m) =>
                    m["name"]!.toLowerCase().contains(searchQuery.toLowerCase())).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              title: Row(
                children: [
                  Icon(Icons.medication, color: AppColors.blueColor),
                  const SizedBox(width: 10),
                  const Text("Add Medication",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Feature 3: اختيار اسم الدواء ─────────────────────
                      if (selectedMedName == null) ...[
                        const Text("Select Medication",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),
                        // search
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search medication...",
                            prefixIcon: Icon(Icons.search, color: AppColors.blueColor),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          onChanged: (v) =>
                              setDialogState(() => searchQuery = v),
                        ),
                        const SizedBox(height: 8),
                        // grid of suggestions
                        SizedBox(
                          height: 200,
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.0,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: filteredMeds.length,
                            itemBuilder: (_, i) {
                              final med = filteredMeds[i];
                              final isOther = med["name"] == "Other";
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedMedName = med["name"];
                                    isOtherSelected = isOther;
                                    if (!isOther) {
                                      medName = med["name"]!;
                                      dosage = med["dosage"]!;
                                      nameController.text = med["name"]!;
                                      dosageController.text = med["dosage"]!;
                                    } else {
                                      medName = "";
                                      dosage = "";
                                      nameController.clear();
                                      dosageController.clear();
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isOther
                                        ? Colors.grey.shade100
                                        : AppColors.surfaceColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isOther
                                          ? Colors.grey.shade300
                                          : AppColors.blueColor.withOpacity(.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      med["name"]!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isOther
                                            ? Colors.grey.shade700
                                            : AppColors.blueColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        // ── بعد الاختيار: ورّي الاسم مع زر تغيير ─────────────
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.blueColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.medication,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    isOtherSelected ? "Other" : selectedMedName!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setDialogState(() {
                                selectedMedName = null;
                                isOtherSelected = false;
                                searchQuery = "";
                                searchController.clear();
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text("Change",
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Name field (editable فقط لو Other)
                        TextField(
                          controller: nameController,
                          readOnly: !isOtherSelected,
                          decoration: customInput(
                            isOtherSelected
                                ? "Medication Name"
                                : selectedMedName ?? "",
                            Icons.medication,
                          ),
                          onChanged: (v) => medName = v,
                        ),
                        const SizedBox(height: 12),

                        // Dosage
                        TextField(
                          controller: dosageController,
                          decoration: customInput(
                              "Dosage (e.g. 500mg)", Icons.science_outlined),
                          onChanged: (v) => dosage = v,
                        ),
                        const SizedBox(height: 12),

                        // Repeat
                        DropdownButtonFormField<String>(
                          value: repeatType,
                          decoration: customInput("Repeat", Icons.repeat),
                          items: repeatOptions
                              .map((r) =>
                                  DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => repeatType = v ?? "Daily"),
                        ),
                        const SizedBox(height: 12),

                        if (repeatType == "Weekly") ...[
                          DropdownButtonFormField<String>(
                            value: weeklyDay,
                            decoration:
                                customInput("Day", Icons.calendar_today),
                            items: weekDays
                                .map((d) =>
                                    DropdownMenuItem(value: d, child: Text(d)))
                                .toList(),
                            onChanged: (v) => setDialogState(
                                () => weeklyDay = v ?? "Monday"),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Times
                        const Text("Reminder Times",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...selectedTimes.asMap().entries.map((entry) {
                              final index = entry.key;
                              final time = entry.value;
                              final canDelete = selectedTimes.length > 1;
                              return GestureDetector(
                                onTap: () async {
                                  final picked = await _showTimeWheelPicker(
                                      initialTime: time);
                                  if (picked != null) {
                                    setDialogState(
                                        () => selectedTimes[index] = picked);
                                  }
                                },
                                child: Chip(
                                  label: Text(time),
                                  backgroundColor:
                                      AppColors.blueColor.withOpacity(.1),
                                  labelStyle: TextStyle(
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w600),
                                  deleteIcon: canDelete
                                      ? const Icon(Icons.close,
                                          size: 16, color: Colors.red)
                                      : null,
                                  onDeleted: canDelete
                                      ? () => setDialogState(
                                          () => selectedTimes.removeAt(index))
                                      : null,
                                ),
                              );
                            }),
                            if (repeatType == "Custom times" ||
                                repeatType == "Twice daily" ||
                                repeatType == "Three times daily")
                              GestureDetector(
                                onTap: () async {
                                  final picked = await _showTimeWheelPicker();
                                  if (picked != null) {
                                    setDialogState(
                                        () => selectedTimes.add(picked));
                                  }
                                },
                                child: Chip(
                                  label: const Text("+ Add Time"),
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Side effects
                        TextField(
                          controller: sideEffectsController,
                          decoration: customInput("Side Effects (Optional)",
                              Icons.warning_amber_outlined),
                          onChanged: (v) => sideEffects = v,
                        ),
                        const SizedBox(height: 12),

                        // Warning level
                        DropdownButtonFormField<String>(
                          value: warningLevel,
                          decoration: customInput(
                              "Warning Level", Icons.info_outline),
                          items: const [
                            DropdownMenuItem(value: "low", child: Text("Low")),
                            DropdownMenuItem(
                                value: "medium", child: Text("Medium")),
                            DropdownMenuItem(
                                value: "high", child: Text("High")),
                          ],
                          onChanged: (v) =>
                              setDialogState(() => warningLevel = v ?? "low"),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        // ✅ Feature 1: Cancel يرجع للداشبورد فوراً
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: selectedMedName == null || isLoading
                            ? null
                            : () async {
                                // لو Other ومكتبش اسم
                                if (isOtherSelected &&
                                    nameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Please enter medication name"),
                                    backgroundColor: Colors.red,
                                  ));
                                  return;
                                }
                                if (dosageController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Please enter dosage"),
                                    backgroundColor: Colors.red,
                                  ));
                                  return;
                                }

                                setDialogState(() => isLoading = true);

                                final finalName = isOtherSelected
                                    ? nameController.text.trim()
                                    : selectedMedName!;
                                final finalDosage =
                                    dosageController.text.trim();

                                try {
                                  final sideEffectsList = sideEffects
                                      .split(',')
                                      .map((e) => e.trim())
                                      .where((e) => e.isNotEmpty)
                                      .toList();

                            final result = await ApiService.addMedication(
  medicationName: finalName,
  dosage: finalDosage,
  repeat: mapRepeatToApi(repeatType),
  reminderTime: selectedTimes
      .map(formatTimeForApi)
      .join(","),
  sideEffects: sideEffectsList,
  warningLevel: mapWarningToApi(warningLevel),
  startDate: getStartDate(),
);
Navigator.pop(dialogContext);

// ✅ لو السيرفر رجع warning → اعرض dialog
if (result["message"] == "warning" || result["added"] == false) {
  if (!mounted) return;   // ← أضف السطر ده
  _showMedicationWarningDialog(
    context,
    result,
    finalName,
    finalDosage,
    mapRepeatToApi(repeatType),
    selectedTimes.map(formatTimeForApi).join(","),
    sideEffectsList,
    mapWarningToApi(warningLevel),
    getStartDate(),
  );
  return;
}

// ✅ لو success عادي
await _loadMedications();
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text("✅ $finalName added successfully"),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

                                } catch (e) {
                                  setDialogState(() => isLoading = false);
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(SnackBar(
                                    content: Text("Failed: $e"),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("Add",
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void openScanMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text("Scanning Medication"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.medical_services, size: 60, color: AppColors.blueColor),
              const SizedBox(height: 15),
              const Text("Analyzing image using AI...",
                  style: TextStyle(fontSize: 14)),
              const SizedBox(height: 15),
              const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text("Medication Detected"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: Panadol"),
                Text("Dosage: 500 mg"),
                Text("Usage: Pain relief & fever"),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor),
                child: const Text("Add Reminder",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  openManualAddDialog();
                },
              ),
            ],
          );
        },
      );
    });
  }

  // ─── Dismissible Card ─────────────────────────────────────────────────────
  Widget dismissibleMedicationCard(Map<String, dynamic> med) {
    return Dismissible(
key: ValueKey("${med["iddelete"] ?? med["id"] ?? med["name"]}_${med["name"]}"),      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  title: const Text("Delete Reminder?"),
                  content: Text(
                      "Are you sure you want to delete ${med["name"]}?"),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.black)),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text("Delete",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      // ✅ Feature 1: بعد الحذف يظهر الداشبورد مع تحديث الـ list
onDismissed: (direction) {
  // ✅ Remove synchronously FIRST — this is required by Dismissible
  final medId = med["iddelete"].toString();
  final removedMed = med;
  setState(() => medications.remove(med));

  // Then do async work in the background
  ApiService.deleteMedication(medId).then((_) {
    _cancelMedicationReminders(removedMed);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${removedMed["name"]} deleted"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }).catchError((e) {
    // Put it back on failure
    if (mounted) {
      setState(() => medications.add(removedMed));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  });
},
      child: medicationCard(med),
    );
  }

  Color warningColor(String level) {
    switch (level) {
      case "high": return Colors.redAccent;
      case "medium": return Colors.orangeAccent;
      case "low": return Colors.green;
      default: return Colors.grey;
    }
  }

  Map<String, List<Map<String, dynamic>>> groupedSideEffects() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final med in medications.where((m) => m["reminderEnabled"] == true)) {
      final effect = (med["sideEffects"] == null ||
              med["sideEffects"].toString().trim().isEmpty)
          ? "No side effects recorded"
          : med["sideEffects"].toString();
      if (!grouped.containsKey(effect)) grouped[effect] = [];
      grouped[effect]!.add(med);
    }
    return grouped;
  }

  Map<String, List<Map<String, dynamic>>> groupedWarnings() {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      "high": [], "medium": [], "low": [],
    };
    for (final med in medications.where((m) => m["reminderEnabled"] == true)) {
      final level = med["warningLevel"] ?? "low";
      if (grouped.containsKey(level)) grouped[level]!.add(med);
    }
    return grouped;
  }

  Widget groupedSideEffectsCard() {
    final grouped = groupedSideEffects();
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Grouped Side Effects",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Medications grouped by similar side effects",
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            if (grouped.isEmpty)
              Text("No side effects available",
                  style: TextStyle(color: Colors.grey[600]))
            else
              ...grouped.entries.map((entry) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.blueColor.withOpacity(.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Side Effect: ${entry.key}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueColor)),
                        const SizedBox(height: 8),
                        ...entry.value.map((med) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text("• ${med["name"]} ${med["dosage"]}",
                                  style: const TextStyle(fontSize: 14)),
                            )),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget warningsCard() {
    final grouped = groupedWarnings();
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Warnings Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Warning levels for active medication reminders",
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            ...["high", "medium", "low"].map((level) {
              final meds = grouped[level]!;
              if (meds.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: warningColor(level).withOpacity(.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: warningColor(level).withOpacity(.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.warning_amber_rounded,
                          color: warningColor(level), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "${level[0].toUpperCase()}${level.substring(1)} Warning",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: warningColor(level)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    ...meds.map((med) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                              "• ${med["name"]} (${med["sideEffects"].toString().isEmpty ? "No side effects" : med["sideEffects"]})",
                              style: const TextStyle(fontSize: 14)),
                        )),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget recommendationsCard() {
    final activeMeds =
        medications.where((m) => m["reminderEnabled"] == true).toList();
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Medication Recommendations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
                "Suggested times and usage tips for your active medications",
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            if (activeMeds.isEmpty)
              Text("No medication recommendations available",
                  style: TextStyle(color: Colors.grey[600]))
            else
              ...activeMeds.map((med) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.blueColor.withOpacity(.14)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med["name"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text(
                            "Usage Tip: ${med["usageTip"] ?? "Follow your doctor's advice"}",
                            style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 6),
                        Text(
                            "Food Advice: ${med["foodAdvice"] ?? "Take as directed"}",
                            style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  // ─── Feature 2: Medication Card with Lock Toggle ──────────────────────────
  Widget medicationCard(Map<String, dynamic> med) {
    final isEnabled = med["reminderEnabled"] as bool? ?? true;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // ✅ Feature 2: أيقونة حالة التنبيه
            GestureDetector(
              onTap: () => _toggleReminderEnabled(med),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppColors.blueColor.withOpacity(.12)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEnabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  color: isEnabled ? AppColors.blueColor : Colors.grey,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          med["name"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isEnabled ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isEnabled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("Active",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("Paused",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("${med["dosage"]} • ${med["frequency"]}",
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  Text("🕐 ${med["time"]}",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            // Info button
            IconButton(
              icon: Icon(Icons.info_outline, color: AppColors.blueColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MedicationInfoScreen(medication: med)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration customInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.blueColor),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.blueColor, width: 1.5),
      ),
    );
  }

  // ─── Complete Profile Banner ──────────────────────────────────────────────
  Widget _buildCompleteProfileBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueColor, AppColors.blueColor.withOpacity(0.75)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.blueColor.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CompleteSignupScreen()));
            _checkProfileComplete();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.medical_information_outlined,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Complete Your Profile",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 3),
                      Text("Add your medical info to get better care",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 249, 249),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 50),
            HeaderWidget(),
            const SizedBox(height: 12),
            if (_showCompleteBanner) _buildCompleteProfileBanner(),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("Medications",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: openAddReminderDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                          label: const Text("Add",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${medications.length} medication${medications.length != 1 ? 's' : ''} • "
                      "${medications.where((m) => m["reminderEnabled"] == true).length} active",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    if (medications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.medication_outlined,
                                  size: 48,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text("No medications yet",
                                  style: TextStyle(
                                      color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              Text("Tap + Add to get started",
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...medications
                          .map((med) => dismissibleMedicationCard(med)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            groupedSideEffectsCard(),
            const SizedBox(height: 12),
            warningsCard(),
            const SizedBox(height: 12),
            recommendationsCard(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}