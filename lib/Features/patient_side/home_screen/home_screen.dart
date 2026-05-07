import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/completeSignUp.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/medication_info_screen.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/core/services/notification_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/timezone.dart' as tz;

// ── قائمة الجرعات ─────────────────────────────────────────────────────────────
const List<String> _dosageOptions = [
  '5 mg',    '10 mg',   '20 mg',   '25 mg',   '40 mg',   '50 mg',
  '100 mg',  '125 mg',  '200 mg',  '250 mg',  '375 mg',  '400 mg',
  '500 mg',  '600 mg',  '625 mg',  '750 mg',  '875 mg',  '1000 mg', '1 g',
  '5 mcg',   '10 mcg',  '25 mcg',  '50 mcg',  '100 mcg', '500 mcg',
  '500 IU',  '1000 IU', '2000 IU', '5000 IU',
  '1 ml',    '2 ml',    '5 ml',    '10 ml',
  '1 tablet','2 tablets','1 capsule','2 capsules',
  '1 puff',  '2 puffs',
  'as prescribed',
];

// ── قائمة أسماء الأدوية الشائعة ──────────────────────────────────────────────
const List<Map<String, String>> _commonMedications = [
  {"name": "Panadol",       "dosage": "500 mg"},
  {"name": "Paracetamol",   "dosage": "500 mg"},
  {"name": "Ibuprofen",     "dosage": "400 mg"},
  {"name": "Aspirin",       "dosage": "100 mg"},
  {"name": "Amoxicillin",   "dosage": "500 mg"},
  {"name": "Metformin",     "dosage": "500 mg"},
  {"name": "Amlodipine",    "dosage": "5 mg"},
  {"name": "Lisinopril",    "dosage": "10 mg"},
  {"name": "Atorvastatin",  "dosage": "20 mg"},
  {"name": "Omeprazole",    "dosage": "20 mg"},
  {"name": "Azithromycin",  "dosage": "500 mg"},
  {"name": "Ciprofloxacin", "dosage": "500 mg"},
  {"name": "Metronidazole", "dosage": "500 mg"},
  {"name": "Cetirizine",    "dosage": "10 mg"},
  {"name": "Loratadine",    "dosage": "10 mg"},
  {"name": "Vitamin D",     "dosage": "1000 IU"},
  {"name": "Vitamin C",     "dosage": "500 mg"},
  {"name": "Zinc",          "dosage": "50 mg"},
  {"name": "Calcium",       "dosage": "500 mg"},
  {"name": "Iron",          "dosage": "50 mg"},
  {"name": "Insulin",       "dosage": "as prescribed"},
  {"name": "Metoprolol",    "dosage": "50 mg"},
  {"name": "Warfarin",      "dosage": "5 mg"},
  {"name": "Prednisolone",  "dosage": "5 mg"},
  {"name": "Salbutamol",    "dosage": "100 mcg"},
  {"name": "Losartan",      "dosage": "50 mg"},
  {"name": "Furosemide",    "dosage": "40 mg"},
  {"name": "Levothyroxine", "dosage": "50 mcg"},
  {"name": "Montelukast",   "dosage": "10 mg"},
  {"name": "Pantoprazole",  "dosage": "40 mg"},
  {"name": "Folic Acid",    "dosage": "5 mg"},
  {"name": "Vitamin B12",   "dosage": "500 mcg"},
  {"name": "Other",         "dosage": ""},
];

// ── Helper: استخراج بيانات الدواء من medicine object ─────────────────────────
Map<String, dynamic> _extractMedicineFields(Map<String, dynamic> medicine) {
  return {
    "activeIngredient":  medicine["activeIngredient"]  ?? "",
    "category":          medicine["category"]           ?? "",
    "instructions":      medicine["instructions"]       ?? "",
    "contraindications": (medicine["contraindications"] as List?)?.cast<String>().join("\n• ") ?? "",
    "interactions":      (medicine["interactions"]      as List?)?.cast<String>().join("\n• ") ?? "",
    "sideEffectsList":   (medicine["sideEffects"]       as List?)?.cast<String>() ?? [],
  };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _PatientDashboardUIState();
}

class _PatientDashboardUIState extends State<HomeScreen> {
  // ─── Complete Profile Banner ──────────────────────────────────────────────
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
      final height    = profile["height"];
      final weight    = profile["weight"];
      final isIncomplete = bloodType.isEmpty || height == null || weight == null;
      if (mounted) setState(() => _showCompleteBanner = isIncomplete);
    } catch (_) {
      if (mounted) setState(() => _showCompleteBanner = true);
    }
  }

  // ─── Repeat / Time helpers ────────────────────────────────────────────────
  final List<String> repeatOptions = [
    "Daily",
    "Twice daily",
    "Three times daily",
    "Weekly",
    "Custom times",
  ];

  final List<String> weekDays = [
    "Monday", "Tuesday", "Wednesday", "Thursday",
    "Friday", "Saturday", "Sunday",
  ];

  List<Map<String, dynamic>> medications        = [];
  List<Map<String, String>>  upcomingReminders  = [];

  // ─── Warning Dialog ───────────────────────────────────────────────────────
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
    final interaction   = result["interactionCheck"]  as Map<String, dynamic>? ?? {};
    final compatibility = result["compatibilityCheck"] as Map<String, dynamic>? ?? {};
    final details       = (compatibility["details"] as List?) ?? [];
    final hasInteraction = interaction["hasInteraction"] as bool? ?? false;
    final interactionList = (interaction["interactions"] as List?)
        ?.map((e) => e as Map<String, dynamic>)
        .where((e) => e["severity"] != null && e["severity"] != "none")
        .toList() ?? [];

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

              // ── Interaction result (حتى لو مفيش تفاعلات) ──
              if (!hasInteraction) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "No drug interactions detected with your current medications.",
                          style: TextStyle(fontSize: 13, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ── لو في تفاعلات ──
              if (hasInteraction && interactionList.isNotEmpty) ...[
                const Text("Drug Interactions",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 6),
                ...interactionList.map((inter) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "${inter["drug1"] ?? ""} ↔ ${inter["drug2"] ?? ""}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ]),
                      if (inter["severity"] != null) ...[
                        const SizedBox(height: 4),
                        Text("Severity: ${inter["severity"]}",
                            style: TextStyle(
                              fontSize: 12,
                              color: inter["severity"] == "high" ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                      if (inter["description"] != null) ...[
                        const SizedBox(height: 4),
                        Text(inter["description"], style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                )),
                const SizedBox(height: 4),
              ],

              // ── summary لو موجود ──
              if (interaction["summary"] != null &&
                  interaction["summary"].toString().isNotEmpty) ...[
                const Text("Summary",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 4),
                Text(interaction["summary"], style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 12),
              ],

              // ── Disease Compatibility ──
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
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(d["reason"] ?? "",
                            style: const TextStyle(fontSize: 12)),
                        if (d["recommendation"] != null) ...[
                          const SizedBox(height: 4),
                          Text("💡 ${d["recommendation"]}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blue[700])),
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
      final result = await ApiService.forceAddMedication(
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
        SnackBar(
            content: Text("✅ $medicationName added"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ─── Load Medications ─────────────────────────────────────────────────────
  Future<void> _loadMedications() async {
    try {
      final data = await ApiService.getMyMedications();
      final loaded = data.map<Map<String, dynamic>>((item) {
        // medicineId قد يكون object أو null
        final med = item["medicineId"] as Map<String, dynamic>? ?? {};

        // جيب الـ sideEffects من item أو من med
        final rawSideEffects = (item["sideEffects"] as List?)?.cast<String>()
            ?? (med["sideEffects"] as List?)?.cast<String>()
            ?? [];

        return {
          "iddelete":          item["medicineId"]?["_id"] ?? item["_id"],
          "id":                item["id"] ?? item["_id"] ?? "",
          "name":              item["medicationName"]  ?? "",
          "dosage":            item["dosage"]           ?? "",
          "frequency":         item["repeat"]           ?? "",
          "repeatType":        item["repeat"]           ?? "",
          "time":              item["reminderTime"]     ?? "",
          "reminder":          true,
          "reminderEnabled":   item["active"] ?? true,
          "sideEffects":       rawSideEffects.join(", "),
          "sideEffectsList":   rawSideEffects,
          "warningLevel":      _mapWarningFromApi(item["warningLevel"] ?? med["warningLevel"] ?? "safe"),
          "startDate":         item["startDate"] ?? "",
          // ── بيانات جديدة من medicine object ──
          "activeIngredient":  med["activeIngredient"]  ?? "",
          "category":          med["category"]           ?? "",
          "instructions":      med["instructions"]       ?? "",
          "contraindications": (med["contraindications"] as List?)?.cast<String>().join("\n• ") ?? "",
          "interactions":      (med["interactions"]      as List?)?.cast<String>().join("\n• ") ?? "",
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
    final now     = DateTime.now();
    final cleaned = timeText.trim().toUpperCase();
    final ampmRegex = RegExp(r'(\d{1,2}):(\d{2})\s?(AM|PM)');
    final ampmMatch = ampmRegex.firstMatch(cleaned);
    int hour, minute;
    if (ampmMatch != null) {
      hour   = int.parse(ampmMatch.group(1)!);
      minute = int.parse(ampmMatch.group(2)!);
      final period = ampmMatch.group(3)!;
      if (period == "PM" && hour != 12) hour += 12;
      if (period == "AM" && hour == 12) hour = 0;
    } else {
      final parts = cleaned.split(":");
      if (parts.length < 2) throw Exception("Invalid time format");
      hour   = int.parse(parts[0]);
      minute = int.parse(parts[1]);
    }
    DateTime scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _scheduleMedicationReminders(Map<String, dynamic> med) async {
    final timeStr  = med["time"]?.toString() ?? "";
    if (timeStr.isEmpty) return;
    final times      = _extractTimes(timeStr);
    final repeatType = med["repeatType"];

    for (int i = 0; i < times.length; i++) {
      final timeText  = times[i];
      final localDate = _parseTimeToDate(timeText);
      DateTime finalDate = localDate;

      if (repeatType == "Weekly" && med["weeklyDay"] != null) {
        final targetWeekday = _weekdayFromString(med["weeklyDay"]);
        while (finalDate.weekday != targetWeekday) {
          finalDate = finalDate.add(const Duration(days: 1));
        }
      }

      final scheduledTime = tz.TZDateTime.from(finalDate, tz.local);
      final followUpTime  = tz.TZDateTime.from(
        finalDate.add(const Duration(minutes: 1)),
        tz.local,
      );

      await NotificationService.showScheduledNotification(
        id:            med["id"].hashCode + i,
        title:         'Reminder: ${med["name"]}',
        body:          'Time to take ${med["dosage"]} at $timeText',
        scheduledTime: scheduledTime,
      );

      await NotificationService.showScheduledNotification(
        id:            med["id"].hashCode + i + 1000,
        title:         'Did you take ${med["name"]}?',
        body:          'Please confirm your dose',
        scheduledTime: followUpTime,
        payload: jsonEncode({
          "type":           "dose_confirmation",
          "medicationId":   med["iddelete"],
          "medicationName": med["name"],
          "dosage":         med["dosage"],
          "scheduledTime":  followUpTime.toString(),
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
      await NotificationService.cancelNotification(med["id"].hashCode + i + 1000);
    }
  }

  void _refreshUpcomingReminders() {
    upcomingReminders.clear();
    for (final med in medications) {
      if (med["reminderEnabled"] == true) {
        final medFullName = "${med["name"]} ${med["dosage"]}";
        final timeStr     = med["time"]?.toString() ?? "";
        if (timeStr.isEmpty) continue;
        final times = _extractTimes(timeStr);
        for (final t in times) {
          upcomingReminders.add({
            "time":           t,
            "medication":     medFullName,
            "medicationId":   med["iddelete"] ?? med["id"].toString(),
            "medicationName": med["name"] ?? "",
            "dosage":         med["dosage"] ?? "",
          });
        }
      }
    }
  }

  int _weekdayFromString(String day) {
    switch (day) {
      case "Monday":    return DateTime.monday;
      case "Tuesday":   return DateTime.tuesday;
      case "Wednesday": return DateTime.wednesday;
      case "Thursday":  return DateTime.thursday;
      case "Friday":    return DateTime.friday;
      case "Saturday":  return DateTime.saturday;
      case "Sunday":    return DateTime.sunday;
      default:          return DateTime.monday;
    }
  }

  String _formatTime12(int hour, int minute, String period) {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
  }

  String formatTimeForApi(String time) {
    final parts  = time.split(' ');
    final hm     = parts[0];
    final ampm   = parts[1];
    int hour     = int.parse(hm.split(':')[0]);
    int minute   = int.parse(hm.split(':')[1]);
    if (ampm == "PM" && hour != 12) hour += 12;
    if (ampm == "AM" && hour == 12) hour = 0;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  String _convertApiTimeTo12h(String apiTime) {
    try {
      final parts  = apiTime.trim().split(':');
      int hour     = int.parse(parts[0]);
      int minute   = int.parse(parts[1]);
      final period = hour >= 12 ? "PM" : "AM";
      if (hour == 0)  hour = 12;
      if (hour > 12)  hour -= 12;
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
    } catch (_) {
      return "08:00 AM";
    }
  }

  String mapRepeatToApi(String repeatType) {
    switch (repeatType) {
      case "Daily":              return "daily";
      case "Weekly":             return "weekly";
      case "Twice daily":
      case "Three times daily":
      case "Custom times":       return "every_x_hours";
      default:                   return "daily";
    }
  }

  String mapWarningToApi(String level) {
    switch (level) {
      case "low":    return "safe";
      case "medium": return "moderate";
      case "high":   return "severe";
      default:       return "safe";
    }
  }

  String _mapWarningFromApi(String apiLevel) {
    switch (apiLevel.toLowerCase()) {
      case "safe":    return "low";
      case "moderate":
      case "caution": return "medium";
      case "severe":  return "high";
      default:        return "low";
    }
  }

  String getStartDate() {
    final now = DateTime.now().toUtc();
    return "${now.toIso8601String().split('.')[0]}Z";
  }

  // ─── Toggle Reminder ──────────────────────────────────────────────────────
  void _toggleReminderEnabled(Map<String, dynamic> med) async {
    final isEnabled = med["reminderEnabled"] as bool? ?? true;
    setState(() => med["reminderEnabled"] = !isEnabled);

    if (!isEnabled) {
      await _scheduleMedicationReminders(med);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("🔔 Reminder enabled for ${med["name"]}"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } else {
      await _cancelMedicationReminders(med);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("🔕 Reminder disabled for ${med["name"]}"),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
    setState(() => _refreshUpcomingReminders());
  }

  // ─── Time Wheel Picker ────────────────────────────────────────────────────
  Future<String?> _showTimeWheelPicker({String? initialTime}) async {
    int    selectedHour   = 8;
    int    selectedMinute = 0;
    String selectedPeriod = "AM";

    if (initialTime != null && initialTime.trim().isNotEmpty) {
      final parts = initialTime.trim().split(RegExp(r'[: ]'));
      if (parts.length >= 3) {
        selectedHour   = int.tryParse(parts[0]) ?? 8;
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
                            children: List.generate(
                                12,
                                (i) => Center(
                                      child: Text(
                                          (i + 1).toString().padLeft(2, '0'),
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
                            children: List.generate(
                                60,
                                (i) => Center(
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
                            onPressed: () => Navigator.pop(
                                context,
                                _formatTime12(
                                    selectedHour, selectedMinute, selectedPeriod)),
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

  // ─── Edit Time Dialog ─────────────────────────────────────────────────────
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
                    med["frequency"] =
                        _extractTimes(editedTime).length > 1
                            ? "Multiple times daily"
                            : "Once daily";
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

  // ─── Add Reminder Dialog (scan / manual) ─────────────────────────────────
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

  // ─── Manual Add Dialog ────────────────────────────────────────────────────
  void openManualAddDialog({
    String? prefillName,
    String? prefillDosage,
    String? prefillSideEffects,
    String? prefillWarningLevel,
  }) {
    final preMatchedMed = prefillName != null
        ? _commonMedications.firstWhere(
            (m) =>
                m["name"]!.toLowerCase() == prefillName.toLowerCase() ||
                prefillName.toLowerCase().contains(m["name"]!.toLowerCase()),
            orElse: () => {"name": "Other", "dosage": ""},
          )
        : null;

    final bool preIsOther = preMatchedMed == null ||
        preMatchedMed["name"] == "Other" ||
        (prefillName != null &&
            !_commonMedications
                .any((m) => m["name"]!.toLowerCase() == prefillName.toLowerCase()));

    String? selectedMedName = prefillName != null
        ? (preIsOther ? "Other" : preMatchedMed!["name"])
        : null;
    bool    isOtherSelected = prefillName != null ? preIsOther : false;
    String  medName         = prefillName ?? "";
    String  dosage          = prefillDosage ?? preMatchedMed?["dosage"] ?? "";
    String? selectedDosage  = _dosageOptions.contains(dosage) ? dosage : null;
    String  sideEffects     = prefillSideEffects ?? "";
    String  warningLevel    = prefillWarningLevel ?? "low";
    String  repeatType      = "Daily";
    String  weeklyDay       = "Monday";
    List<String> selectedTimes = ["08:00 AM"];
    bool    isLoading       = false;
    String  searchQuery     = "";

    final nameController        = TextEditingController(text: prefillName ?? "");
    final sideEffectsController = TextEditingController(text: prefillSideEffects ?? "");
    final searchController      = TextEditingController();

    final existingNames = medications
        .map((m) => (m['name'] ?? '').toString().trim().toLowerCase())
        .toSet();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final filteredMeds = searchQuery.isEmpty
                ? _commonMedications
                : _commonMedications
                    .where((m) => m["name"]!
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

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

                      // ════════════════════════════════════════════
                      // STEP 1 — اختيار الدواء
                      // ════════════════════════════════════════════
                      if (selectedMedName == null) ...[
                        const Text("Select Medication",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),

                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search medication...",
                            prefixIcon:
                                Icon(Icons.search, color: AppColors.blueColor),
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

                        SizedBox(
                          height: 220,
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
                              final med      = filteredMeds[i];
                              final isOther  = med["name"] == "Other";
                              final alreadyAdded = !isOther &&
                                  existingNames.contains(
                                      med["name"]!.toLowerCase());

                              return GestureDetector(
                                onTap: () {
                                  if (alreadyAdded) {
                                    ScaffoldMessenger.of(dialogContext)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          '${med["name"]} is already added ✓'),
                                      backgroundColor: Colors.orange,
                                    ));
                                    return;
                                  }
                                  setDialogState(() {
                                    selectedMedName = med["name"];
                                    isOtherSelected = isOther;
                                    if (!isOther) {
                                      medName = med["name"]!;
                                      dosage  = med["dosage"]!;
                                      nameController.text = med["name"]!;
                                      selectedDosage =
                                          _dosageOptions.contains(med["dosage"])
                                              ? med["dosage"]
                                              : null;
                                    } else {
                                      medName        = "";
                                      dosage         = "";
                                      selectedDosage = null;
                                      nameController.clear();
                                    }
                                  });
                                },
                                child: Opacity(
                                  opacity: alreadyAdded ? 0.4 : 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isOther
                                          ? Colors.grey.shade100
                                          : AppColors.blueColor
                                              .withOpacity(.07),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: alreadyAdded
                                            ? Colors.grey.shade300
                                            : isOther
                                                ? Colors.grey.shade300
                                                : AppColors.blueColor
                                                    .withOpacity(.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        alreadyAdded
                                            ? '${med["name"]} ✓'
                                            : med["name"]!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: alreadyAdded
                                              ? Colors.grey
                                              : isOther
                                                  ? Colors.grey.shade700
                                                  : AppColors.blueColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      ] else ...[
                        // ════════════════════════════════════════════
                        // STEP 2 — تفاصيل الدواء
                        // ════════════════════════════════════════════

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
                                selectedDosage  = null;
                                searchQuery     = "";
                                searchController.clear();
                                nameController.clear();
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

                        DropdownButtonFormField<String>(
                          value: selectedDosage,
                          isExpanded: true,
                          decoration: customInput(
                              "Select Dosage", Icons.science_outlined),
                          items: _dosageOptions
                              .map((d) =>
                                  DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (v) => setDialogState(() {
                            selectedDosage = v;
                            dosage = v ?? '';
                          }),
                        ),
                        const SizedBox(height: 12),

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

                        const Text("Reminder Times",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...selectedTimes.asMap().entries.map((entry) {
                              final index    = entry.key;
                              final time     = entry.value;
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
                                  final picked =
                                      await _showTimeWheelPicker();
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

                        DropdownButtonFormField<String>(
                          value: warningLevel,
                          decoration: customInput(
                              "Warning Level", Icons.info_outline),
                          items: const [
                            DropdownMenuItem(
                                value: "low", child: Text("Low")),
                            DropdownMenuItem(
                                value: "medium", child: Text("Medium")),
                            DropdownMenuItem(
                                value: "high", child: Text("High")),
                          ],
                          onChanged: (v) => setDialogState(
                              () => warningLevel = v ?? "low"),
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
                                if (isOtherSelected &&
                                    nameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text("Please enter medication name"),
                                    backgroundColor: Colors.red,
                                  ));
                                  return;
                                }
                                if (selectedDosage == null) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Please select a dosage"),
                                    backgroundColor: Colors.red,
                                  ));
                                  return;
                                }

                                final finalName = isOtherSelected
                                    ? nameController.text.trim()
                                    : selectedMedName!;

                                if (existingNames.contains(
                                    finalName.toLowerCase())) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(SnackBar(
                                    content:
                                        Text("$finalName is already added"),
                                    backgroundColor: Colors.orange,
                                  ));
                                  return;
                                }

                                setDialogState(() => isLoading = true);

                                try {
                                  final sideEffectsList = sideEffects
                                      .split(',')
                                      .map((e) => e.trim())
                                      .where((e) => e.isNotEmpty)
                                      .toList();

                                  final result = await ApiService.addMedication(
                                    medicationName: finalName,
                                    dosage: selectedDosage!,
                                    repeat: mapRepeatToApi(repeatType),
                                    reminderTime: selectedTimes
                                        .map(formatTimeForApi)
                                        .join(","),
                                    sideEffects: sideEffectsList,
                                    warningLevel: mapWarningToApi(warningLevel),
                                    startDate: getStartDate(),
                                  );

                                  Navigator.pop(dialogContext);

                                  if (result["message"] == "warning" ||
                                      result["added"] == false) {
                                    if (!mounted) return;
                                    _showMedicationWarningDialog(
                                      context,
                                      result,
                                      finalName,
                                      selectedDosage!,
                                      mapRepeatToApi(repeatType),
                                      selectedTimes
                                          .map(formatTimeForApi)
                                          .join(","),
                                      sideEffectsList,
                                      mapWarningToApi(warningLevel),
                                      getStartDate(),
                                    );
                                    return;
                                  }

                                  // ── استخراج بيانات الـ medicine من response ──
                                  final medicine =
                                      result["medicine"] as Map<String, dynamic>? ?? {};

                                  await _loadMedications();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "✅ $finalName added successfully"),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ));
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

  // ─── Scan Medication Dialog ───────────────────────────────────────────────
  void openScanMedicationDialog() async {
    final picker = ImagePicker();
    final picked = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Select Image Source",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.blueColor.withOpacity(.1),
                child: Icon(Icons.camera_alt, color: AppColors.blueColor),
              ),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.blueColor.withOpacity(.1),
                child: Icon(Icons.photo_library, color: AppColors.blueColor),
              ),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (picked == null) return;

    final XFile? xfile =
        await picker.pickImage(source: picked, imageQuality: 85);
    if (xfile == null) return;

    final imageFile = File(xfile.path);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.document_scanner, color: AppColors.blueColor),
            const SizedBox(width: 8),
            const Text("Scanning..."),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(imageFile, height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text("Analyzing medication image using AI...",
                style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );

    try {
      final result = await ApiService.scanMedication(imageFile);
      if (!mounted) return;
      Navigator.pop(context);

      final medicine = result["medicine"] as Map<String, dynamic>? ?? {};

      // ── استخراج كل البيانات من الـ response ──
      final detectedName      = result["detectedName"] ?? medicine["medicationName"] ?? "Unknown";
      final rawDosage         = medicine["dosage"]         ?? "";
      final sideEffectsList   = (medicine["sideEffects"] as List?)?.cast<String>() ?? [];
      final sideEffectsStr    = sideEffectsList.join(", ");
      final category          = medicine["category"]        ?? "";
      final instructions      = medicine["instructions"]    ?? "";
      final warningLevel      = medicine["warningLevel"]    ?? "safe";
      final activeIngredient  = medicine["activeIngredient"] ?? "";
      final contraindications = (medicine["contraindications"] as List?)?.cast<String>() ?? [];
      final interactions      = (medicine["interactions"]   as List?)?.cast<String>() ?? [];

      // ── تنظيف الاسم ──
      String cleanName = detectedName.toString();
      final quoteMatch = RegExp(r'"([^"]+)"').firstMatch(cleanName);
      if (quoteMatch != null) cleanName = quoteMatch.group(1)!;
      cleanName = cleanName[0].toUpperCase() + cleanName.substring(1).toLowerCase();

      // ── مطابقة الجرعة مع القائمة ──
      String? matchedDosage;
      for (final opt in _dosageOptions) {
        if (rawDosage.toLowerCase().contains(
            opt.toLowerCase().replaceAll(' ', ''))) {
          matchedDosage = opt;
          break;
        }
      }
      if (matchedDosage == null) {
        final numMatch = RegExp(r'(\d+)\s*(mg|mcg|g|iu|ml)',
            caseSensitive: false).firstMatch(rawDosage);
        if (numMatch != null) {
          final candidate =
              "${numMatch.group(1)} ${numMatch.group(2)!.toLowerCase()}";
          matchedDosage = _dosageOptions.firstWhere(
            (o) => o.toLowerCase() == candidate,
            orElse: () => "",
          );
          if (matchedDosage!.isEmpty) matchedDosage = null;
        }
      }

      // ── Result dialog ──
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.medication,
                    color: AppColors.blueColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cleanName.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                if (rawDosage.isNotEmpty)
                  _scanInfoRow(Icons.science_outlined, "Dosage", rawDosage),
                if (activeIngredient.isNotEmpty)
                  _scanInfoRow(Icons.biotech_outlined, "Active Ingredient",
                      activeIngredient, color: Colors.purple),
                if (category.isNotEmpty)
                  _scanInfoRow(Icons.category_outlined, "Category", category),
                if (instructions.isNotEmpty)
                  _scanInfoRow(
                      Icons.info_outline, "How to Use", instructions,
                      color: Colors.teal),
                if (sideEffectsStr.isNotEmpty)
                  _scanInfoRow(Icons.warning_amber_outlined, "Side Effects",
                      sideEffectsStr, color: Colors.orange),
                if (contraindications.isNotEmpty)
                  _scanInfoRow(Icons.block, "Contraindications",
                      "• ${contraindications.join("\n• ")}",
                      color: Colors.red),
                if (interactions.isNotEmpty)
                  _scanInfoRow(Icons.compare_arrows, "Drug Interactions",
                      "• ${interactions.join("\n• ")}",
                      color: Colors.deepOrange),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      openManualAddDialog(
                        prefillName:         cleanName,
                        prefillDosage:       matchedDosage,
                        prefillSideEffects:  sideEffectsStr,
                        prefillWarningLevel: _mapWarningFromApi(warningLevel),
                      );
                    },
                    child: const Text("Add Reminder",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Scan failed: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── Helper widget للـ scan result ─────────────────────────────────────────
  Widget _scanInfoRow(IconData icon, String label, String value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.blueColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dismissible Card ─────────────────────────────────────────────────────
  Widget dismissibleMedicationCard(Map<String, dynamic> med) {
    return Dismissible(
      key: ValueKey(
          "${med["iddelete"] ?? med["id"] ?? med["name"]}_${med["name"]}"),
      direction: DismissDirection.endToStart,
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
      onDismissed: (direction) {
        final medId      = med["iddelete"].toString();
        final removedMed = med;
        setState(() => medications.remove(med));

        ApiService.deleteMedication(medId).then((_) {
          _cancelMedicationReminders(removedMed);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("${removedMed["name"]} deleted"),
              backgroundColor: Colors.red,
            ));
          }
        }).catchError((e) {
          if (mounted) {
            setState(() => medications.add(removedMed));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Failed to delete: $e"),
              backgroundColor: Colors.red,
            ));
          }
        });
      },
      child: medicationCard(med),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Color warningColor(String level) {
    switch (level) {
      case "high":   return Colors.redAccent;
      case "medium": return Colors.orangeAccent;
      case "low":    return Colors.green;
      default:       return Colors.grey;
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

  // ─── Cards ────────────────────────────────────────────────────────────────
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
                              child: Text(
                                  "• ${med["name"]} ${med["dosage"]}",
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
                  border: Border.all(
                      color: warningColor(level).withOpacity(.25)),
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
                        // اسم الدواء + category badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(med["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                            if ((med["category"] ?? "").isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.blueColor.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  med["category"],
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        // Active Ingredient
                        if ((med["activeIngredient"] ?? "").isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.biotech_outlined,
                                size: 13, color: Colors.purple.shade400),
                            const SizedBox(width: 4),
                            Text(med["activeIngredient"],
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple.shade400)),
                          ]),
                        ],
                        const SizedBox(height: 6),
                        // Instructions
                        if ((med["instructions"] ?? "").isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14, color: Colors.teal.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  med["instructions"],
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        // Contraindications
                        if ((med["contraindications"] ?? "").isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.red.shade100),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.block,
                                    size: 14, color: Colors.red.shade600),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Contraindications",
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade600)),
                                      const SizedBox(height: 2),
                                      Text(
                                        "• ${med["contraindications"]}",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Interactions
                        if ((med["interactions"] ?? "").isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.deepOrange.shade100),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.compare_arrows,
                                    size: 14,
                                    color: Colors.deepOrange.shade600),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Drug Interactions",
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange
                                                  .shade600)),
                                      const SizedBox(height: 2),
                                      Text(
                                        "• ${med["interactions"]}",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.deepOrange
                                                .shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isEnabled
                              ? Colors.green.withOpacity(.1)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEnabled ? "Active" : "Paused",
                          style: TextStyle(
                              color: isEnabled ? Colors.green : Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("${med["dosage"]} • ${med["frequency"]}",
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600)),
                  Text("🕐 ${med["time"]}",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                  // ── Category badge ──
                  if ((med["category"] ?? "").isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withOpacity(.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        med["category"],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: AppColors.blueColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          MedicationInfoScreen(medication: med)),
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
          colors: [
            AppColors.blueColor,
            AppColors.blueColor.withOpacity(0.75)
          ],
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
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CompleteSignupScreen()));
            _checkProfileComplete();
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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

  // ─── BUILD ────────────────────────────────────────────────────────────────
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
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    if (medications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(Icons.medication_outlined,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text("No medications yet",
                                  style:
                                      TextStyle(color: Colors.grey.shade500)),
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