import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/material.dart';

class AppointmentModel {
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String appointmentType;
  final String gender;
  final String name;
  final int age;
  final double price;
  final String billingMethod;
  final DateTime createdAt;
  final String status; // جديد: upcoming, canceled, completed

  AppointmentModel({
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentType,
    required this.gender,
    required this.name,
    required this.age,
    required this.price,
    required this.billingMethod,
    DateTime? createdAt,
    this.status = 'upcoming', // الحالة الافتراضية
  }) : createdAt = createdAt ?? DateTime.now();

  // Helper to parse DateTime from various types
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static String _timeOfDayToString(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  static TimeOfDay _stringToTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return const TimeOfDay(hour: 0, minute: 0);
    final format = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);
    final match = format.firstMatch(timeStr);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      appointmentId: map['appointmentId']?.toString() ?? '',
      patientId: map['patientId']?.toString() ?? '',
      doctorId: map['doctorId']?.toString() ?? '',
      appointmentDate: _parseDate(map['appointmentDate']),
      appointmentTime: map['appointmentTime'] is TimeOfDay
          ? _timeOfDayToString(map['appointmentTime'])
          : (map['appointmentTime']?.toString() ?? ''),
      appointmentType: map['appointmentType']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      age: (map['age'] is num) ? map['age'].toInt() : 0,
      price: (map['price'] is num) ? map['price'].toDouble() : 0.0,
      billingMethod: map['billingMethod']?.toString() ?? '',
      createdAt: _parseDate(map['createdAt']),
      status: map['status']?.toString() ?? 'upcoming', // قراءة الحالة من قاعدة البيانات
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'appointmentTime': appointmentTime,
      'appointmentType': appointmentType,
      'gender': gender,
      'name': name,
      'age': age,
      'price': price,
      'billingMethod': billingMethod,
      'createdAt': createdAt.toIso8601String(),
      'status': status, // إضافة الحالة
    };
  }

  AppointmentModel copyWith({
    String? appointmentId,
    String? patientId,
    String? doctorId,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    String? gender,
    String? name,
    int? age,
    double? price,
    String? billingMethod,
    DateTime? createdAt,
    String? status,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      appointmentType: appointmentType ?? this.appointmentType,
      gender: gender ?? this.gender,
      name: name ?? this.name,
      age: age ?? this.age,
      price: price ?? this.price,
      billingMethod: billingMethod ?? this.billingMethod,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status, // تحديث الحالة
    );
  }
}
