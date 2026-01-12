// HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/medication_info_screen.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/services/notification_services.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
const HomeScreen({Key? key}) : super(key: key);

@override
State<HomeScreen> createState() => _PatientDashboardUIState();
}

class _PatientDashboardUIState extends State<HomeScreen> {
List<Map<String, dynamic>> medications = [
{
"id": 1,
"name": "Aspirin",
"dosage": "100mg",
"frequency": "Once daily",
"time": "08:00 AM",
"reminder": true
},
{
"id": 2,
"name": "Metformin",
"dosage": "500mg",
"frequency": "Twice daily",
"time": "08:00 AM, 08:00 PM",
"reminder": true
},
{
"id": 3,
"name": "Lisinopril",
"dosage": "10mg",
"frequency": "Once daily",
"time": "09:00 AM",
"reminder": false
},
{
"id": 4,
"name": "Atorvastatin",
"dosage": "20mg",
"frequency": "Once daily",
"time": "10:00 PM",
"reminder": true
},
];

List<Map<String, String>> upcomingReminders = [];

@override
void initState() {
super.initState();
// Initialize upcomingReminders based on active reminders
for (var med in medications) {
if (med["reminder"]) {
final medFullName = "${med["name"]} ${med["dosage"]}";
final times = (med["time"] as String).split(',');
for (var t in times) {
upcomingReminders.add({"time": t.trim(), "medication": medFullName});
}
}
}
}

void toggleReminder(int id) {
setState(() {
final index = medications.indexWhere((med) => med["id"] == id);
final med = medications[index];
med["reminder"] = !(med["reminder"] as bool);

  final medFullName = "${med["name"]} ${med["dosage"]}";

  if (med["reminder"] == false) {
    upcomingReminders.removeWhere((r) => r["medication"] == medFullName);
    NotificationService.cancelNotification(med["id"]);
  } else {
    final times = (med["time"] as String).split(',');
    for (var t in times) {
      upcomingReminders.add({"time": t.trim(), "medication": medFullName});

      // تحويل الوقت إلى TZDateTime
      final parts = t.trim().split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final ampm = parts[2];
      if (ampm.toUpperCase() == 'PM' && hour != 12) hour += 12;
      if (ampm.toUpperCase() == 'AM' && hour == 12) hour = 0;

      DateTime now = DateTime.now();
      DateTime scheduledDate =
          DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      NotificationService.showScheduledNotification(
        id: med["id"],
        title: 'Reminder: ${med["name"]}',
        body: 'Time to take ${med["dosage"]}',
        scheduledTime: tz.TZDateTime.from(scheduledDate, tz.local),
      );
    }
  }
});

}
void openManualAddDialog() {
  String medName = "";
  String dosage = "";
  String time = "";

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text("Add New Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration:
                  const InputDecoration(labelText: "Medication Name"),
              onChanged: (value) => medName = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Dosage"),
              onChanged: (value) => dosage = value,
            ),
            TextField(
              decoration: const InputDecoration(
                  labelText: "Time (e.g. 08:00 AM)"),
              onChanged: (value) => time = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor),
            child: const Text("Add"),
            onPressed: () {
              if (medName.isNotEmpty &&
                  dosage.isNotEmpty &&
                  time.isNotEmpty) {
                setState(() {
                  medications.add({
                    "id": DateTime.now().millisecondsSinceEpoch,
                    "name": medName,
                    "dosage": dosage,
                    "frequency": "Once daily",
                    "time": time,
                    "reminder": true,
                  });

                  upcomingReminders.add({
                    "time": time,
                    "medication": "$medName $dosage"
                  });
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
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
          children:  [
            Icon(Icons.medical_services,
                size: 60, color: AppColors.blueColor),
            SizedBox(height: 15),
            Text("Analyzing image using AI...",
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            CircularProgressIndicator(),
          ],
        ),
      );
    },
  );

  /// ⏳ Fake AI Delay
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context);

    /// Result Dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text("Medication Detected"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Name: Panadol"),
              Text("Dosage: 500 mg"),
              Text("Usage: Pain relief & fever"),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor),
              child: const Text("Add Reminder"),
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
            borderRadius: BorderRadius.circular(16)),
        title: const Text("Add Medication"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.blueColor.withOpacity(.1),
                child:  Icon(Icons.camera_alt,
                    color: AppColors.blueColor),
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
padding: EdgeInsets.only(right: 20),
alignment: Alignment.centerRight,
color: Colors.red,
child: Icon(Icons.delete, color: Colors.white, size: 30),
),
confirmDismiss: (direction) async {
return await showDialog(
context: context,
builder: (context) {
return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12)),
title: Text("Delete Reminder?"),
content: Text("Are you sure you want to delete this reminder?"),
actions: [
TextButton(
style: TextButton.styleFrom(
backgroundColor: Colors.grey[300],
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12))),
child: Text("Cancel", style: TextStyle(color: Colors.black)),
onPressed: () => Navigator.pop(context, false),
),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.blueColor),
child: Text("Delete",
style: TextStyle(color: AppColors.whiteColor)),
onPressed: () => Navigator.pop(context, true),
),
],
);
},
);
},
onDismissed: (direction) {
setState(() {
medications.removeWhere((item) => item["id"] == med["id"]);
upcomingReminders.removeWhere(
(rem) => rem["medication"] == "${med["name"]} ${med["dosage"]}");
NotificationService.cancelNotification(med["id"]);
});
},
child: medicationCard(med),
);
}

@override
Widget build(BuildContext context) {
final isMobile = MediaQuery.of(context).size.width < 600;

return Scaffold(
  backgroundColor: const Color.fromARGB(255, 249, 249, 249),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        SizedBox(height: 50),
        HeaderWidget(),
        // Medications List
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Medications",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () => openAddReminderDialog(),
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
                const Text("Manage your medications and reminders",
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 11),
                ...medications.map((med) => dismissibleMedicationCard(med)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Upcoming Reminders
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Upcoming Reminders",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                upcomingReminders.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "No Upcoming Reminders",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: upcomingReminders
                            .map((reminder) => reminderCard(reminder))
                            .toList(),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Quick Stats
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Quick Stats",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                statRow("Active Medications", medications.length.toString(),
                    Colors.blue),
                statRow(
                    "Daily Reminders",
                    medications
                        .where((m) => m["reminder"])
                        .length
                        .toString(),
                    Colors.green),
                statRow("Weekly Adherence", "95%", Colors.amber),
              ],
            ),
          ),
        ),
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
if (med["reminder"])
Row(
  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    SizedBox(width: 10,)
,
    // 🔹 Info Button
   ],
   
),  GestureDetector(
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
        child:  Center(
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
Text("Time: ${med["time"]}"),
]),
),
Column(
children: [
Row(
children: [
Switch(
inactiveTrackColor:
const Color.fromARGB(255, 249, 249, 249),
activeTrackColor: AppColors.blueColor,
activeColor: AppColors.whiteColor,
value: med["reminder"],
onChanged: (_) => toggleReminder(med["id"]),
),
const Icon(Icons.notifications_outlined,
size: 20, color: Colors.grey),
],
),
],
)
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
child: Text(value, style: const TextStyle(color: Colors.white)),
)
],
),
);
}
}
