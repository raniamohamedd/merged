import 'package:cloud_firestore/cloud_firestore.dart';

class RecomendationDoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int reviews;
  final bool isRecommended;

  RecomendationDoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.isRecommended,
  });

  factory RecomendationDoctorModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecomendationDoctorModel(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      specialization: (data['specialization'] ?? '').toString(),
      hospital: (data['hospital'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      rating: (data['rating'] ?? 0).toDouble(),
      reviews: (data['reviews'] ?? 0) as int,
      isRecommended: (data['isRecommended'] ?? false) as bool,
    );
  }
}
