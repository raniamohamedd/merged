import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/medication_info_screen.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/notification_services.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _PatientDashboardUIState();
}

class _PatientDashboardUIState extends State<HomeScreen> {
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

String _buildFrequencyLabel(String repeatType, List<String> times) {
  if (repeatType == "Custom times") {
    if (times.length == 1) return "Once daily";
    return "${times.length} times daily";
  }
  if (repeatType == "Daily") return "Once daily";
  if (repeatType == "Weekly") return "Once weekly";
  return repeatType;
}

int _weekdayFromString(String day) {
  switch (day) {
    case "Monday":
      return DateTime.monday;
    case "Tuesday":
      return DateTime.tuesday;
    case "Wednesday":
      return DateTime.wednesday;
    case "Thursday":
      return DateTime.thursday;
    case "Friday":
      return DateTime.friday;
    case "Saturday":
      return DateTime.saturday;
    case "Sunday":
      return DateTime.sunday;
    default:
      return DateTime.monday;
  }
}
  final Map<String, Map<String, String>> medicationDefaults = {
    "aspirin": {
      "sideEffects": "Mild stomach pain, heartburn",
      "warningLevel": "low",
      "bestTime": "Morning",
      "usageTip": "Best taken in the morning at the same time every day",
      "foodAdvice": "Take after food",
    },
    "metformin": {
      "sideEffects": "Nausea, diarrhea, dizziness",
      "warningLevel": "medium",
      "bestTime": "Morning & Evening",
      "usageTip": "Take it regularly at the same times each day",
      "foodAdvice": "Take with meals",
    },
    "lisinopril": {
      "sideEffects": "Dry cough, dizziness",
      "warningLevel": "low",
      "bestTime": "Morning",
      "usageTip": "Take once daily and monitor blood pressure regularly",
      "foodAdvice": "Can be taken with or without food",
    },
    "atorvastatin": {
      "sideEffects": "Muscle pain, weakness",
      "warningLevel": "high",
      "bestTime": "Night",
      "usageTip": "Usually preferred at night for better cholesterol control",
      "foodAdvice": "Can be taken with or without food",
    },
    "panadol": {
      "sideEffects": "Nausea, mild rash",
      "warningLevel": "low",
      "bestTime": "As needed",
      "usageTip": "Use only when needed and do not exceed the recommended dose",
      "foodAdvice": "Can be taken after food if stomach is sensitive",
    },
    "amoxicillin": {
      "sideEffects": "Diarrhea, skin rash, nausea",
      "warningLevel": "medium",
      "bestTime": "Morning / Afternoon / Night",
      "usageTip": "Take at evenly spaced times",
      "foodAdvice": "Preferably after food",
    },
    "warfarin": {
      "sideEffects": "Bleeding, bruising, dizziness",
      "warningLevel": "high",
      "bestTime": "Evening",
      "usageTip": "Take at the same time daily and monitor INR regularly",
      "foodAdvice": "Take consistently with regard to meals",
    },
    "insulin": {
      "sideEffects": "Low blood sugar, sweating, shakiness",
      "warningLevel": "high",
      "bestTime": "Before meals / as prescribed",
      "usageTip": "Follow the schedule exactly as prescribed",
      "foodAdvice": "Usually related to meals",
    },
  };
 List<Map<String, dynamic>> medications = [
  {
    "id": 1000,
    "name": "Aspirin",
    "dosage": "100mg",
    "frequency": "Once daily",
    "repeatType": "Daily",
    "weeklyDay": null,
    "time": "08:00 AM",
    "reminder": true,
    "sideEffects": "Mild stomach pain, heartburn",
    "warningLevel": "low",
    "bestTime": "Morning",
    "usageTip": "Best taken in the morning at the same time every day",
    "foodAdvice": "Take after food",
  },
  {
    "id": 2000,
    "name": "Metformin",
    "dosage": "500mg",
    "frequency": "Twice daily",
    "repeatType": "Twice daily",
    "weeklyDay": null,
    "time": "08:00 AM, 08:00 PM",
    "reminder": true,
    "sideEffects": "Nausea, diarrhea, dizziness",
    "warningLevel": "medium",
    "bestTime": "Morning & Evening",
    "usageTip": "Take it regularly at the same times each day",
    "foodAdvice": "Take with meals",
  },
  {
    "id": 3000,
    "name": "Lisinopril",
    "dosage": "10mg",
    "frequency": "Once daily",
    "repeatType": "Daily",
    "weeklyDay": null,
    "time": "09:00 AM",
    "reminder": false,
    "sideEffects": "Dry cough, dizziness",
    "warningLevel": "low",
    "bestTime": "Morning",
    "usageTip": "Take once daily and monitor blood pressure regularly",
    "foodAdvice": "Can be taken with or without food",
  },
  {
    "id": 4000,
    "name": "Atorvastatin",
    "dosage": "20mg",
    "frequency": "Once daily",
    "repeatType": "Daily",
    "weeklyDay": null,
    "time": "10:00 PM",
    "reminder": true,
    "sideEffects": "Muscle pain, weakness",
    "warningLevel": "high",
    "bestTime": "Night",
    "usageTip": "Usually preferred at night for better cholesterol control",
    "foodAdvice": "Can be taken with or without food",
  },
];  List<Map<String, String>> upcomingReminders = [];

  @override
  void initState() {
    super.initState();
    _refreshUpcomingReminders();
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

  Map<String, String> getDefaultMedicationData(String medName) {
    final key = medName.trim().toLowerCase();

    if (medicationDefaults.containsKey(key)) {
      return medicationDefaults[key]!;
    }

    return {
      "sideEffects": "No common side effects recorded",
      "warningLevel": "low",
      "bestTime": "As prescribed",
      "usageTip": "Follow your doctor's instructions",
      "foodAdvice": "Take as directed",
    };
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
    final parts = timeText.trim().split(RegExp(r'[: ]'));
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    final ampm = parts[2].toUpperCase();

    if (ampm == 'PM' && hour != 12) hour += 12;
    if (ampm == 'AM' && hour == 12) hour = 0;

    final now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
 Future<void> _scheduleMedicationReminders(Map<String, dynamic> med) async {
  final times = _extractTimes(med["time"] as String);

  for (int i = 0; i < times.length; i++) {
    final timeText = times[i];
    final scheduledDate = _parseTimeToDate(timeText);

    // 🔹 النوتيفيكيشن الأساسي
    await NotificationService.showScheduledNotification(
      id: (med["id"] as int) + i,
      title: 'Reminder: ${med["name"]}',
      body: 'Time to take ${med["dosage"]} at $timeText',
      scheduledTime: tz.TZDateTime.from(scheduledDate, tz.local),
    );

    // 🔹 نوتيفيكيشن بعد 5 دقائق (الجديد)
    final followUpTime = scheduledDate.add(const Duration(minutes: 5));

    await NotificationService.showScheduledNotification(
      id: (med["id"] as int) + i + 1000, // مهم ID مختلف
      title: 'Did you take ${med["name"]}?',
      body: 'Please confirm if you took ${med["dosage"]}',
      scheduledTime: tz.TZDateTime.from(followUpTime, tz.local),
    );
  }
} Future<void> _cancelMedicationReminders(Map<String, dynamic> med) async {
    final times = _extractTimes(med["time"] as String);

    for (int i = 0; i < times.length; i++) {
      await NotificationService.cancelNotification((med["id"] as int) + i);
    }
  }


  void _refreshUpcomingReminders() {
    upcomingReminders.clear();

    for (final med in medications) {
      if (med["reminder"] == true) {
        final medFullName = "${med["name"]} ${med["dosage"]}";
        final times = _extractTimes(med["time"] as String);

        for (final t in times) {
          upcomingReminders.add({
            "time": t,
            "medication": medFullName,
          });
        }
      }
    }
  }
String _formatTime12(int hour, int minute, String period) {
  final formattedHour = hour.toString().padLeft(2, '0');
  final formattedMinute = minute.toString().padLeft(2, '0');
  return "$formattedHour:$formattedMinute $period";
}

Future<String?> _showTimeWheelPicker({
  String? initialTime,
}) async {
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

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: 360,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Select Reminder Time",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatTime12(selectedHour, selectedMinute, selectedPeriod),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueColor,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedHour - 1,
                          ),
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedHour = index + 1;
                            });
                          },
                          children: List.generate(
                            12,
                            (index) => Center(
                              child: Text(
                                (index + 1).toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedMinute,
                          ),
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedMinute = index;
                            });
                          },
                          children: List.generate(
                            60,
                            (index) => Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedPeriod == "AM" ? 0 : 1,
                          ),
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              selectedPeriod = index == 0 ? "AM" : "PM";
                            });
                          },
                          children: const [
                            Center(
                              child: Text(
                                "AM",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            Center(
                              child: Text(
                                "PM",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.blueColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: AppColors.blueColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              context,
                              _formatTime12(
                                selectedHour,
                                selectedMinute,
                                selectedPeriod,
                              ),
                            );
                          },
                          child: const Text(
                            "Done",
                            style: TextStyle(color: Colors.white),
                          ),
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
  void toggleReminder(int id) async {
    final index = medications.indexWhere((med) => med["id"] == id);
    if (index == -1) return;

    final med = medications[index];

    setState(() {
      med["reminder"] = !(med["reminder"] as bool);
    });

    try {
      if (med["reminder"] == true) {
        await _scheduleMedicationReminders(med);
      } else {
        await _cancelMedicationReminders(med);
      }

      setState(() {
        _refreshUpcomingReminders();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reminder error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void openEditTimeDialog(Map<String, dynamic> med) {
    final controller = TextEditingController(text: med["time"]);
    String editedTime = med["time"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
              ),
              onPressed: () async {
                if (!_isValidTimeInput(editedTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Enter time like 08:00 AM or 08:00 AM, 08:00 PM",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _cancelMedicationReminders(med);

                  setState(() {
                    med["time"] = editedTime.trim();
                    med["frequency"] = _extractTimes(editedTime).length > 1
                        ? "Multiple times daily"
                        : "Once daily";
                    _refreshUpcomingReminders();
                  });

                  if (med["reminder"] == true) {
                    await _scheduleMedicationReminders(med);
                  }

                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Reminder time updated for ${med["name"]}"),
                      backgroundColor: AppColors.blueColor,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Update error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }void openManualAddDialog() {
  String medName = "";
  String dosage = "";
  String sideEffects = "";
  String warningLevel = "";
  String repeatType = "Daily";
  String weeklyDay = "Monday";
  List<String> selectedTimes = ["08:00 AM"];

  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final sideEffectsController = TextEditingController();

  InputDecoration customInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.blueColor),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.blueColor, width: 1.5),
      ),
    );
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.blueColor.withOpacity(.12),
                  child: Icon(Icons.medication_outlined, color: AppColors.blueColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Add New Reminder",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: customInput("Medication Name", Icons.medical_services),
                    onChanged: (value) => medName = value,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: dosageController,
                    decoration: customInput("Dosage", Icons.scale_outlined),
                    onChanged: (value) => dosage = value,
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: repeatType,
                    decoration: customInput("Repeat", Icons.repeat),
                    items: repeatOptions.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        repeatType = value ?? "Daily";

                        if (repeatType == "Daily") {
                          selectedTimes = ["08:00 AM"];
                        } else if (repeatType == "Twice daily") {
                          selectedTimes = ["08:00 AM", "08:00 PM"];
                        } else if (repeatType == "Three times daily") {
                          selectedTimes = ["08:00 AM", "02:00 PM", "08:00 PM"];
                        } else if (repeatType == "Weekly") {
                          selectedTimes = ["08:00 AM"];
                        } else if (repeatType == "Custom times") {
                          selectedTimes = [];
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  if (repeatType == "Weekly")
                    DropdownButtonFormField<String>(
                      value: weeklyDay,
                      decoration: customInput("Day of week", Icons.calendar_today),
                      items: weekDays.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          weeklyDay = value ?? "Monday";
                        });
                      },
                    ),

                  if (repeatType == "Weekly") const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: AppColors.blueColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                repeatType == "Weekly"
                                    ? "Reminder Time"
                                    : "Reminder Times",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (repeatType == "Custom times")
                              GestureDetector(
                                onTap: () async {
                                  final pickedTime = await _showTimeWheelPicker();
                                  if (pickedTime != null &&
                                      !selectedTimes.contains(pickedTime)) {
                                    setDialogState(() {
                                      selectedTimes.add(pickedTime);
                                      selectedTimes.sort();
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (selectedTimes.isEmpty)
                          Text(
                            "No reminder time selected yet",
                            style: TextStyle(color: Colors.grey.shade600),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedTimes.map((time) {
                              final canDelete = repeatType == "Custom times";
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.blueColor.withOpacity(.10),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.blueColor.withOpacity(.20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final pickedTime =
                                            await _showTimeWheelPicker(
                                          initialTime: time,
                                        );
                                        if (pickedTime != null) {
                                          setDialogState(() {
                                            final index =
                                                selectedTimes.indexOf(time);
                                            if (index != -1) {
                                              selectedTimes[index] = pickedTime;
                                              selectedTimes =
                                                  selectedTimes.toSet().toList();
                                              selectedTimes.sort();
                                            }
                                          });
                                        }
                                      },
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          color: AppColors.blueColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (canDelete) ...[
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          setDialogState(() {
                                            selectedTimes.remove(time);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: sideEffectsController,
                    decoration: customInput(
                      "Side Effects (Optional)",
                      Icons.warning_amber_outlined,
                    ),
                    onChanged: (value) => sideEffects = value,
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: warningLevel.isEmpty ? null : warningLevel,
                    decoration: customInput(
                      "Warning Level (Optional)",
                      Icons.info_outline,
                    ),
                    items: const [
                      DropdownMenuItem(value: "low", child: Text("Low")),
                      DropdownMenuItem(value: "medium", child: Text("Medium")),
                      DropdownMenuItem(value: "high", child: Text("High")),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        warningLevel = value ?? "";
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        if (medName.trim().isEmpty ||
                            dosage.trim().isEmpty ||
                            selectedTimes.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please fill medication, dosage and choose at least one time",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final defaultData = getDefaultMedicationData(medName);

                          final finalSideEffects = sideEffects.trim().isEmpty
                              ? defaultData["sideEffects"]!
                              : sideEffects.trim();

                          final finalWarningLevel = warningLevel.isEmpty
                              ? defaultData["warningLevel"]!
                              : warningLevel;

                          final int newId = _generateMedicationId();
                          final selectedTimesString = selectedTimes.join(", ");

                          final newMedication = <String, dynamic>{
                            "id": newId,
                            "name": medName.trim(),
                            "dosage": dosage.trim(),
                            "frequency":
                                _buildFrequencyLabel(repeatType, selectedTimes),
                            "repeatType": repeatType,
                            "weeklyDay": repeatType == "Weekly" ? weeklyDay : null,
                            "time": selectedTimesString,
                            "reminder": true,
                            "sideEffects": finalSideEffects,
                            "warningLevel": finalWarningLevel,
                            "bestTime": defaultData["bestTime"]!,
                            "usageTip": defaultData["usageTip"]!,
                            "foodAdvice": defaultData["foodAdvice"]!,
                          };

                          setState(() {
                            medications.add(newMedication);
                            _refreshUpcomingReminders();
                          });

                          await _scheduleMedicationReminders(newMedication);

                          if (!mounted) return;
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Reminder added for ${newMedication["name"]}",
                              ),
                              backgroundColor: AppColors.blueColor,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error scheduling reminder: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      ),
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
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Scanning Medication"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medical_services,
                size: 60,
                color: AppColors.blueColor,
              ),
              const SizedBox(height: 15),
              const Text(
                "Analyzing image using AI...",
                style: TextStyle(fontSize: 14),
              ),
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
              borderRadius: BorderRadius.circular(16),
            ),
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
                  backgroundColor: AppColors.blueColor,
                ),
                child: const Text(
                  "Add Reminder",
                  style: TextStyle(color: Colors.white),
                ),
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

  void openAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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

  Widget dismissibleMedicationCard(Map<String, dynamic> med) {
    return Dismissible(
      key: Key(med["id"].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text("Delete Reminder?"),
                  content: const Text(
                    "Are you sure you want to delete this reminder?",
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (direction) async {
        await _cancelMedicationReminders(med);

        setState(() {
          medications.removeWhere((item) => item["id"] == med["id"]);
          _refreshUpcomingReminders();
        });
      },
      child: medicationCard(med),
    );
  }

  Color warningColor(String level) {
    switch (level) {
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

  Map<String, List<Map<String, dynamic>>> groupedSideEffects() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final med in medications.where((m) => m["reminder"] == true)) {
      final effect = (med["sideEffects"] == null ||
              med["sideEffects"].toString().trim().isEmpty)
          ? "No side effects recorded"
          : med["sideEffects"].toString();

      if (!grouped.containsKey(effect)) {
        grouped[effect] = [];
      }
      grouped[effect]!.add(med);
    }

    return grouped;
  }

  Map<String, List<Map<String, dynamic>>> groupedWarnings() {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      "high": [],
      "medium": [],
      "low": [],
    };

    for (final med in medications.where((m) => m["reminder"] == true)) {
      final level = med["warningLevel"] ?? "low";
      if (grouped.containsKey(level)) {
        grouped[level]!.add(med);
      }
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
            const Text(
              "Grouped Side Effects",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Medications grouped by similar side effects",
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (grouped.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "No side effects available",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ...grouped.entries.map((entry) {
                final effect = entry.key;
                final meds = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.blueColor.withOpacity(.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Side Effect: $effect",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...meds.map(
                        (med) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "• ${med["name"]} ${med["dosage"]}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
            const Text(
              "Warnings Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Warning levels for active medication reminders",
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            ...["high", "medium", "low"].map((level) {
              final meds = grouped[level]!;
              final color = warningColor(level);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: color.withOpacity(.15),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${level[0].toUpperCase()}${level.substring(1)} Warning",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (meds.isEmpty)
                      Text(
                        "No medications in this level",
                        style: TextStyle(color: Colors.grey[700]),
                      )
                    else
                      ...meds.map(
                        (med) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "• ${med["name"]} ${med["dosage"]}  (${med["sideEffects"] == null || med["sideEffects"].toString().isEmpty ? "No side effects" : med["sideEffects"]})",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
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
    final activeMeds = medications.where((m) => m["reminder"] == true).toList();

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Medication Recommendations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Suggested times and usage tips for your active medications",
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (activeMeds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "No medication recommendations available",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ...activeMeds.map((med) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.blueColor.withOpacity(.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                            backgroundColor: AppColors.blueColor.withOpacity(.12),
                            child: Icon(
                              Icons.schedule,
                              color: AppColors.blueColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${med["name"]} ${med["dosage"]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Best Time: ${med["bestTime"] ?? "As prescribed"}",
                        style: TextStyle(
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tip: ${med["usageTip"] ?? "Follow your doctor's advice"}",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Food Advice: ${med["foodAdvice"] ?? "Take as directed"}",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

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
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Medications",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: openAddReminderDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueColor,
                            padding: const EdgeInsets.all(10),
                            elevation: 4,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "Manage your medications and reminders",
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 11),
                    ...medications.map((med) => dismissibleMedicationCard(med)),
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

  Widget medicationCard(Map<String, dynamic> med) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        med["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      if (med["reminder"] == true)
                        Row(
                          children: [
                            Container(
                              width: 110,
                              height: 23,
                              decoration: BoxDecoration(
                                color: AppColors.blueColor,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Center(
                                child: Text(
                                  'Active Reminder',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MedicationInfoScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.blueColor.withOpacity(.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "i",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            Text("Dosage: ${med["dosage"]}"),
Text("Frequency: ${med["frequency"]}"),
if (med["repeatType"] != null)
  Text(
    med["repeatType"] == "Weekly" && med["weeklyDay"] != null
        ? "Repeat: Weekly on ${med["weeklyDay"]}"
        : "Repeat: ${med["repeatType"]}",
    style: TextStyle(
      color: Colors.grey.shade700,
      fontSize: 13,
    ),
  ),
GestureDetector(
  onTap: () => openEditTimeDialog(med),
  child: Text(
    "Time: ${med["time"]}",
    style: TextStyle(
      color: AppColors.blueColor,
      fontWeight: FontWeight.w500,
    ),
  ),
),
                ],
              ),
            ),
            Row(
              children: [
                Switch(
                  inactiveTrackColor:
                      const Color.fromARGB(255, 249, 249, 249),
                  activeTrackColor: AppColors.blueColor,
                  activeThumbColor: AppColors.whiteColor,
                  value: med["reminder"] as bool,
                  onChanged: (_) => toggleReminder(med["id"] as int),
                ),
                GestureDetector(
                  onTap: () => openEditTimeDialog(med),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget reminderCard(Map<String, String> reminder) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.blue[50],
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(reminder["medication"]!),
        subtitle: Text(reminder["time"]!),
      ),
    );
  }

  Widget statRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
 
}
