import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String doctorId;
  final int STR;
  final String name;
  final String specialization;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String specializationKey;
  final bool isRecommended;
  final String? aboutMe;
  final String? workingTime;
  final double price;
  final List<String>? appointmentIds;
  final Timestamp? createdAt;

  DoctorModel({
    required this.doctorId,
    required this.name,
    required this.specialization,
    required this.hospital,
    this.appointmentIds,
    this.imageUrl =
        "lib/images/profile.png",
    this.rating = 0.0,
    this.reviews = 0,
    this.isRecommended = true,
    this.aboutMe =
        "",
    this.workingTime = "Monday - Friday, 9:00 AM - 5:00 PM",
    this.price = 0.0,
    this.STR = 123456,
    this.createdAt,
    String? specializationKey,
  }) : specializationKey = specializationKey ?? specialization.toLowerCase();

  // 🔁 fromMap
  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      doctorId: id,
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      hospital: map['hospital'] ?? 'Unknown Hospital',
      imageUrl: map['imageUrl'] ??
          "lib/images/profile.png",
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviews: map['reviews'] ?? 0,
      specializationKey: map['specializationKey'],
      isRecommended: map['isRecommended'] ?? true,
      aboutMe: map['aboutMe'] ?? '',
      workingTime: map['workingTime'] ?? '',
     price: (map['price'] is String)
    ? double.tryParse(map['price']) ?? 0.0
    : (map['price'] ?? 0.0).toDouble(),
      appointmentIds: map["appointmentIds"]??[],
      STR: map['STR'] is int ? map['STR'] : int.tryParse(map['STR'].toString()) ?? 0,
      createdAt: map['createdAt'],
    );
  }

  // 🗃️ toMap
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'name': name,
      'specialization': specialization,
      'hospital': hospital,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'specializationKey': specializationKey,
      'isRecommended': isRecommended,
      'aboutMe': aboutMe,
      'workingTime': workingTime,
      'price': price,
      'appointmentIds':appointmentIds, 
      'STR': STR,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // 🧩 copyWith method
  DoctorModel copyWith({
    String? doctorId,
    int? STR,
    String? name,
    String? specialization,
    String? hospital,
    String? imageUrl,
    double? rating,
    int? reviews,
    String? specializationKey,
    bool? isRecommended,
    String? aboutMe,
    String? workingTime,
    double? price,
    List<String>?appointmentIds, 
    Timestamp? createdAt,
  }) {
    return DoctorModel(
      doctorId: doctorId ?? this.doctorId,
      STR: STR ?? this.STR,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      hospital: hospital ?? this.hospital,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      specializationKey: specializationKey ?? this.specializationKey,
      isRecommended: isRecommended ?? this.isRecommended,
      aboutMe: aboutMe ?? this.aboutMe,
      workingTime: workingTime ?? this.workingTime,
      price: price ?? this.price,
      appointmentIds:appointmentIds??this.appointmentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
