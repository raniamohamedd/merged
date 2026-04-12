import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String patientId;
  final String doctorId;
  final String? specialityName;
  final double? rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.patientId,
    required this.doctorId,
    this.specialityName,
    this.rating,
    this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ReviewModel copyWith({
    String? reviewId,
    String? patientId,
    String? doctorId,
    String? specialityName,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      specialityName: specialityName ?? this.specialityName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ✅ من Firestore إلى Dart
  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseCreatedAt(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate(); // ✅ دعم Firestore Timestamp
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        return parsed ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ReviewModel(
      reviewId: id,
      patientId: map['patientId'] as String? ?? '',
      doctorId: map['doctorId'] as String? ?? '',
      specialityName: map['specialityName'] as String?,
      rating: (map['rating'] != null)
          ? (map['rating'] is num
          ? (map['rating'] as num).toDouble()
          : double.tryParse(map['rating'].toString()))
          : null,
      comment: map['comment'] as String?,
      createdAt: parseCreatedAt(map['createdAt']),
    );
  }

  // ✅ من Dart إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'patientId': patientId,
      'doctorId': doctorId,
      'specialityName': specialityName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt), // ✅ تخزين Timestamp حقيقي
    };
  }
}
