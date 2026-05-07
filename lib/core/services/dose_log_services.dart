import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoseLogService {
  static const String _storageKey = "dose_logs";

  static Future<List<Map<String, dynamic>>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> _saveLogs(List<Map<String, dynamic>> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(logs));
  }

  static Future<void> saveOrUpdateDose({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required String scheduledTime,
    required String status,
  }) async {
    final logs = await getLogs();

    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    final doseKey = "${medicationId}_${todayKey}_$scheduledTime";

    final index = logs.indexWhere((e) => e["doseKey"] == doseKey);

    final item = <String, dynamic>{
      "doseKey": doseKey,
      "medicationId": medicationId,
      "medicationName": medicationName,
      "dosage": dosage,
      "scheduledTime": scheduledTime,
      "date": todayKey,
      "status": status,
      "updatedAt": DateTime.now().toIso8601String(),
    };

    if (index == -1) {
      logs.add(item);
    } else {
      logs[index] = item;
    }

    await _saveLogs(logs);
  }

  static Future<Map<String, dynamic>?> getDoseForToday({
    required String medicationId,
    required String scheduledTime,
  }) async {
    final logs = await getLogs();
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    final doseKey = "${medicationId}_${todayKey}_$scheduledTime";

    try {
      return logs.firstWhere((e) => e["doseKey"] == doseKey);
    } catch (_) {
      return null;
    }
  }
}