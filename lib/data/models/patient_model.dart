class PatientModel {
  final String patientId;
  final List<String>? appointmentIds;
  // final String? dateOfBirth;
  final DateTime createdAt;

  PatientModel({
    required this.patientId,
    this.appointmentIds,
    // this.dateOfBirth,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    return PatientModel(
      patientId: id,
      appointmentIds: map["appointmentIds"] != null
          ? List<String>.from(map["appointmentIds"])
          : [],
      // dateOfBirth: map["dateOfBirth"] ?? "",
      createdAt: map["createdAt"] != null
          ? DateTime.parse(map["createdAt"])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "patientId":patientId,
      "appointmentIds": appointmentIds ?? [],
      // "dateOfBirth": dateOfBirth ?? "",
      "createdAt": createdAt.toIso8601String(),
    };
  }

  PatientModel copyWith({
    String? patientId,
    List<String>? appointmentIds,
    // String? dateOfBirth,
    DateTime? createdAt,
  }) {
    return PatientModel(
      patientId: patientId ?? this.patientId,
      appointmentIds: appointmentIds ?? this.appointmentIds,
      // dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
