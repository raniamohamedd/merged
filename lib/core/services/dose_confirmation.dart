import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/core/services/dose_log_services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DoseConfirmationScreen extends StatefulWidget {
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String scheduledTime;

  const DoseConfirmationScreen({
    super.key,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
  });

  @override
  State<DoseConfirmationScreen> createState() => _DoseConfirmationScreenState();
}

class _DoseConfirmationScreenState extends State<DoseConfirmationScreen> {
  String? currentStatus;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final log = await DoseLogService.getDoseForToday(
      medicationId: widget.medicationId,
      scheduledTime: widget.scheduledTime,
    );

    if (!mounted) return;
    setState(() {
      currentStatus = log?["status"];
    });
  }

Future<void> _saveStatus(String status) async {
  setState(() => isSaving = true);

  if (status == "taken") {
    try {
      // ✅ جيب الـ pending logs وابحث عن اللي بيطابق الـ medicineId
      final pending = await ApiService.getPendingMedications();

      final log = pending.firstWhere(
        (p) => p["medicineId"].toString() == widget.medicationId,
        orElse: () => null,
      );

      if (log != null) {
        final logId = log["_id"].toString();
        await ApiService.takeMedication(logId);
        print("✅ Taken with logId: $logId");
      } else {
        print("⚠️ No pending log found for medicineId: ${widget.medicationId}");
      }
    } catch (e) {
      print("Take medication API error: $e");
    }
  }

  await DoseLogService.saveOrUpdateDose(
    medicationId: widget.medicationId,
    medicationName: widget.medicationName,
    dosage: widget.dosage,
    scheduledTime: widget.scheduledTime,
    status: status,
  );

  if (!mounted) return;
  setState(() {
    currentStatus = status;
    isSaving = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Dose marked as $status"),
      backgroundColor: AppColors.blueColor,
    ),
  );
}
  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (currentStatus) {
      "taken" => Colors.green,
      "skipped" => Colors.red,
      _ => Colors.grey,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Dose Confirmation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.medicationName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Dosage: ${widget.dosage}"),
                const SizedBox(height: 4),
                Text("Scheduled time: ${widget.scheduledTime}"),
                const SizedBox(height: 16),
                if (currentStatus != null)
                  _statusChip("Current status: $currentStatus", statusColor),
                const SizedBox(height: 24),
                const Text(
                  "Did you take this medication?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (isSaving)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {_saveStatus("taken");
                                              Navigator.pop(context);

                          } ,
                          child: const Text(
                            "Taken",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: ()  { Navigator.pop(context);},
                          child: const Text(
                            "Skip dose",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}