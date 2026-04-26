import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/medication_info_screen.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/core/services/notification_services.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
     };
 List<Map<String, dynamic>> medications = [


];  List<Map<String, String>> upcomingReminders = [];
Future<void> _loadMedications() async {
  try {
    final data = await ApiService.getMyMedications();

    final loaded = data.map<Map<String, dynamic>>((item) {
      return {
        "id": item["id"],
        "name": item["medicationName"] ?? "",
        "dosage": item["dosage"] ?? "",
        "frequency": item["repeat"] ?? "",
        "repeatType": item["repeat"] ?? "",
        "time": item["reminderTime"] ?? "",
        "reminder": true,
        "sideEffects": item["sideEffects"]?.join(", ") ?? "",
        "warningLevel": item["warningLevel"] ?? "low",
      };
    }).toList();

    setState(() {
      medications = loaded;
    });

    // 🔥 مهم: جدولة الإشعارات بعد تحميل البيانات
    for (final med in medications) {
      if (med["reminder"] == true) {
        await _scheduleMedicationReminders(med);
      }
    }

    _refreshUpcomingReminders();
  } catch (e) {
    print("Error loading meds: $e");
  }
}@override
  void initState() {
  super.initState();
  _loadMedications();
}
int _notifId(int medId, int index, int offset) {
  return medId * 1000 + index + offset;
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
int reminderId(int medId, int i) {
  return medId * 1000 + i;
}
int followUpId(int medId, int i) {
  return medId * 1000 + 500 + i;
}
DateTime _parseTimeToDate(String timeText) {
  final now = DateTime.now();

  final cleaned = timeText.trim().toUpperCase();

  // Case 1: AM/PM format
  final ampmRegex = RegExp(r'(\d{1,2}):(\d{2})\s?(AM|PM)');
  final ampmMatch = ampmRegex.firstMatch(cleaned);

  int hour;
  int minute;

  if (ampmMatch != null) {
    hour = int.parse(ampmMatch.group(1)!);
    minute = int.parse(ampmMatch.group(2)!);
    final period = ampmMatch.group(3)!;

    if (period == "PM" && hour != 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;
  } else {
    // Case 2: 24-hour format (08:00)
   final parts = cleaned.split(":");
if (parts.length < 2) throw Exception("Invalid time format");

hour = int.parse(parts[0]);
minute = int.parse(parts[1]);
  }

  DateTime scheduled = DateTime(
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  return scheduled;
}
 Future<void> _scheduleMedicationReminders(Map<String, dynamic> med) async {
  final times = _extractTimes(med["time"] as String);
  final repeatType = med["repeatType"];

  for (int i = 0; i < times.length; i++) {
    final timeText = times[i];

    print("TIME = ${med["time"]}");
    print("timeText = $timeText");

    final localDate = _parseTimeToDate(timeText);

    DateTime finalDate = localDate;

    // weekly fix
    if (repeatType == "Weekly" && med["weeklyDay"] != null) {
      final targetWeekday = _weekdayFromString(med["weeklyDay"]);

      while (finalDate.weekday != targetWeekday) {
        finalDate = finalDate.add(const Duration(days: 1));
      }
    }

    final scheduledTime = tz.TZDateTime.from(finalDate, tz.local);

    final followUpTime = tz.TZDateTime.from(
      finalDate.add(const Duration(minutes:1)),
      tz.local,
    );

    // reminder
    await NotificationService.showScheduledNotification(
id: med["id"].hashCode + i,      title: 'Reminder: ${med["name"]}',
      body: 'Time to take ${med["dosage"]} at $timeText',
      scheduledTime: scheduledTime,
    );
print("🔥 Scheduling at: $scheduledTime");
print("🔥 Medication: ${med["name"]}");
    // follow up
   await NotificationService.showScheduledNotification(
  id: med["id"].hashCode + i + 1000,
  title: 'Did you take ${med["name"]}?',
  body: 'Please confirm your dose',
  scheduledTime: followUpTime,
  payload: jsonEncode({
    "type": "dose_confirmation",
    "medicationId": med["id"],
    "medicationName": med["name"],
    "dosage": med["dosage"],
    "scheduledTime": followUpTime.toString(),
  }),
);
  }
}Future<void> _cancelMedicationReminders(Map<String, dynamic> med) async {
    final times = _extractTimes(med["time"] as String);

    for (int i = 0; i < times.length; i++) {
      await NotificationService.cancelNotification(  med["id"].hashCode + i,
);
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
    } 
    catch (e) {
     Navigator.pop(context);
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
                    initialValue: repeatType,
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
                      initialValue: weeklyDay,
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
                    initialValue: warningLevel.isEmpty ? null : warningLevel,
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
                      onPressed:
                      
                     () async {
  if (medName.trim().isEmpty ||
      dosage.trim().isEmpty ||
      selectedTimes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("من فضلك املى البيانات"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    // تحويل side effects → list
    final sideEffectsList = sideEffects
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // 🔥 استدعاء API
   await ApiService.addMedication(
  medicationName: medName.trim(),
  dosage: dosage.trim(),
  repeat: mapRepeatToApi(repeatType), // ✅ FIX
reminderTime: selectedTimes.map(formatTimeForApi).join(","),  sideEffects: sideEffectsList,
  warningLevel: mapWarningToApi(
    warningLevel.isEmpty ? "low" : warningLevel,
  ), // ✅ FIX
  startDate: getStartDate(), // ✅ مهم جدًا
);
    // ✅ إضافة في UI
final newMed = {
  "id": DateTime.now().millisecondsSinceEpoch,
  "name": medName,
  "dosage": dosage,
  "frequency": repeatType,
  "repeatType": repeatType,
  "weeklyDay": repeatType == "Weekly" ? weeklyDay : null, // ✅ مهم
  "time": selectedTimes.join(", "),
  "reminder": true,
  "sideEffects": sideEffects,
  "warningLevel": warningLevel.isEmpty ? "low" : warningLevel, // ✅ fix
};

    setState(() {
      medications.add(newMed);
      _refreshUpcomingReminders();
    });

    await _scheduleMedicationReminders(newMed);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تمت الإضافة بنجاح"),
        backgroundColor: AppColors.blueColor,
      ),
    );
  } catch (e) {
        Navigator.pop(context);

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
String mapRepeatToApi(String repeatType) {
  switch (repeatType) {
    case "Daily":
      return "daily";
    case "Weekly":
      return "weekly";
    case "Twice daily":
    case "Three times daily":
    case "Custom times":
      return "every_x_hours";
    default:
      return "daily";
  }
}
String mapWarningToApi(String level) {
  switch (level) {
    case "low":
      return "safe";
    case "medium":
      return "moderate";
    case "high":
      return "severe";
    default:
      return "safe";
  }
}
String getStartDate() {
  final now = DateTime.now().toUtc();
  final formatted =
      "${now.toIso8601String().split('.')[0]}Z";
  return formatted;
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
key: ValueKey("${med["id"]}_${med["name"]}"),      direction: DismissDirection.endToStart,
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
            Text("Dosage: ${med["dosage"]} mg"),
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
