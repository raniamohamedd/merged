import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/chats_doctor/view/chat_details_screen.dart' hide AppColors;
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/shared/widgets/error_dialog.dart';

class Medication {
  final String name, dosage, frequency, nextDose, sideEffects;
  final bool taken;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.nextDose,
    required this.taken,
    required this.sideEffects,
  });
}

class Symptom {
  final String date, description, severity;

  Symptom({
    required this.date,
    required this.description,
    required this.severity,
  });
}

class Emergency {
  final String date, reason;
  final bool resolved;

  Emergency({
    required this.date,
    required this.reason,
    required this.resolved,
  });
}

class Patient {
  final String name;
  final int age;
  final List<String> conditions;
  final String status;
  final List<Medication> medications;
  final List<Symptom> symptoms;
  final List<Emergency> emergencyHistory;

  Patient({
    required this.name,
    required this.age,
    required this.conditions,
    required this.status,
    required this.medications,
    required this.symptoms,
    required this.emergencyHistory,
  });
}

class PatientDetailsPage extends StatefulWidget {
  final String patientId;

  const PatientDetailsPage({super.key, required this.patientId});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  Map<String, dynamic>? patientData;

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  Future<void> loadPatient() async {
    try {
      final response =
          await ApiService.getPatientById(widget.patientId);

      setState(() {
        patientData = response["data"];
      });
    } catch (e) {
  showErrorDialog(context, message: e.toString());
    }
  }

int calculateAge(String dob) {
  final birthDate = DateTime.parse(dob);
  final today = DateTime.now();

  int age = today.year - birthDate.year;

  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  return age;
}
  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stable':
        return Colors.green;
      case 'monitoring':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'stable':
        return Colors.green.shade50;
      case 'monitoring':
        return Colors.orange.shade50;
      case 'critical':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.yellow.shade700;
      case 'medium':
        return Colors.orange.shade700;
      case 'high':
        return Colors.red.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  Color severityBgColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.yellow.shade50;
      case 'medium':
        return Colors.orange.shade50;
      case 'high':
        return Colors.red.shade50;
      default:
        return Colors.green.shade50;
    }
  }

  Widget buildSoftCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.blueColor.withOpacity(.10),
          child: Icon(
            icon,
            color: AppColors.blueColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget infoMiniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(.07),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(.14),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMedicationCard(Medication med) {
    final takenColor = med.taken ? Colors.green : Colors.red;
    final takenBg = med.taken ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.blueColor.withOpacity(.10),
                child: Icon(
                  Icons.medication_outlined,
                  color: AppColors.blueColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  med.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: takenBg,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  med.taken ? "Taken" : "Missed",
                  style: TextStyle(
                    color: takenColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniLine(
                  icon: Icons.science_outlined,
                  label: "Dosage",
                  value: med.dosage,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniLine(
                  icon: Icons.repeat,
                  label: "Frequency",
                  value: med.frequency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniLine(
                  icon: Icons.schedule,
                  label: "Next Dose",
                  value: med.nextDose,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniLine(
                  icon: Icons.warning_amber_outlined,
                  label: "Side Effects",
                  value: med.sideEffects,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniLine({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.blueColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSymptomCard(Symptom symptom) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: severityBgColor(symptom.severity),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: severityColor(symptom.severity).withOpacity(.12),
            child: Icon(
              Icons.monitor_heart_outlined,
              color: severityColor(symptom.severity),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  symptom.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              symptom.severity[0].toUpperCase() +
                  symptom.severity.substring(1).toLowerCase(),
              style: TextStyle(
                color: severityColor(symptom.severity),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmergencyCard(Emergency em) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red.withOpacity(.10),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  em.date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: em.resolved
                      ? Colors.green.shade50
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  em.resolved ? "Resolved" : "Open",
                  style: TextStyle(
                    color: em.resolved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              em.reason,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (patientData == null) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}if (patientData == null || patientData!["userId"] == null) {
  return const Scaffold(
    body: Center(child: Text("Patient data not found")),
  );
}
     final medications = (patientData?["medications"] as List?) ?? [];
final symptoms = (patientData?["symptoms"] as List?) ?? [];
final emergencies = (patientData?["emergencyHistory"] as List?) ?? [];
final diseases = (patientData?["chronicDiseases"] as List?) ?? [];
final user = patientData?["userId"];
final phone = user?["phone"] ?? "";
final gender = user?["gender"] ?? "";
final bloodType = patientData?["bloodType"] ?? "";
final height = patientData?["height"]?.toString() ?? "";
final weight = patientData?["weight"]?.toString() ?? "";
final allergies = patientData?["allergies"] ?? "";
final name = user?["fullName"] ?? "Unknown";

final dob = user?["DOB"];
final age = (dob != null && dob.toString().isNotEmpty)
    ? calculateAge(dob)
    : 0;
final status = diseases.isNotEmpty
    ? diseases[0]["status"] ?? "stable"
    : "stable";

final conditions =
    diseases.map<String>((e) => e["name"].toString()).toList();
    final patientStatusColor = statusColor(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER الثابت
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueColor.withOpacity(.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                   // في الـ build دور على الكونتينر ده وعدّله
Container(
  width: 56,
  height: 56,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.white.withOpacity(.3),
      width: 2,
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: () {
      final userImage = user?['image'];
      String? imageUrl;
      if (userImage is Map) {
        imageUrl = userImage['secure_url']?.toString();
      } else if (userImage is String && userImage.isNotEmpty) {
        imageUrl = userImage;
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.white.withOpacity(.18),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      }
      return Container(
        color: Colors.white.withOpacity(.18),
        child: const Icon(
          Icons.person_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      );
    }(),
  ),
),  const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Patient Details",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                 InkWell(
                  
                   child: 
                   SizedBox(
                        width: 56,
                        height: 56,
                        // decoration: BoxDecoration(
                        //   color: Colors.white.withOpacity(.18),
                        //   borderRadius: BorderRadius.circular(18),
                        // ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                
                onTap: () {
                    //  Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatsPageDoctor(
                                        doctorName: 'john smith',
                                        chatId: 'hh',
                                      ),
                        
                        // (route) => false,
                      ));
                
                  },
                       
                
                
                
                
                
                 ),
                    const SizedBox(width: 14),  ],
                ),
              ),
            ),

            /// SCROLLABLE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

buildSoftCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle("Personal Info", Icons.person_outline),
      const SizedBox(height: 16),

      Row(
        children: [
          infoMiniCard(
            title: "Phone",
            value: phone,
            icon: Icons.phone_outlined,
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          infoMiniCard(
            title: "Gender",
            value: gender,
            icon: Icons.person_outline,
            color: Colors.purple,
          ),
        ],
      ),

      const SizedBox(height: 10),

      Row(
        children: [
          infoMiniCard(
            title: "Blood",
            value: bloodType,
            icon: Icons.bloodtype_outlined,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          infoMiniCard(
            title: "Height",
            value: "$height cm",
            icon: Icons.height,
            color: Colors.blue,
          ),
        ],
      ),

      const SizedBox(height: 10),

      Row(
        children: [
          infoMiniCard(
            title: "Weight",
            value: "$weight kg",
            icon: Icons.monitor_weight_outlined,
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          infoMiniCard(
            title: "Allergies",
            value: allergies,
            icon: Icons.warning_amber_outlined,
            color: Colors.redAccent,
          ),
        ],
      ),
    ],
  ),
),
                    buildSoftCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              infoMiniCard(
                                title: "Age",
                                value: "$age",
                                icon: Icons.cake_outlined,
                                color: AppColors.blueColor,
                              ),
                              const SizedBox(width: 10),
                              infoMiniCard(
                                title: "Conditions",
                                value: "${conditions.length}",
                                icon: Icons.local_hospital_outlined,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              infoMiniCard(
                                title: "Status",
                                value: status[0].toUpperCase() +
                                    status.substring(1),
                                icon: Icons.favorite_outline,
                                color: patientStatusColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: conditions.map((condition) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueColor.withOpacity(.08),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    condition,
                                    style: TextStyle(
                                      color: AppColors.blueColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                   
          

             if (medications.isNotEmpty)
  buildSoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle("Medication Schedule", Icons.medication_outlined),
        const SizedBox(height: 16),

        ...medications.map((e) => buildMedicationCard(
             Medication(
  name: e["medicationName"] ?? "",
  dosage: e["dosage"] ?? "",
  frequency: e["repeat"] ?? "",
  nextDose: e["reminderTime"] ?? "",
  taken: e["taken"] ?? false,
  sideEffects: (e["sideEffects"] is List)
      ? (e["sideEffects"] as List).join(", ")
      : "",
),
            )),
      ],
    ),
  ),
                    const SizedBox(height: 16),
if (symptoms.isNotEmpty)
  buildSoftCard(
    child: Column(
      children: [
        sectionTitle("Symptoms Log", Icons.monitor_heart_outlined),
        const SizedBox(height: 16),

        ...symptoms.map((e) => buildSymptomCard(
              Symptom(
                date: e["date"] ?? "",
                description: e["description"] ?? "",
                severity: e["severity"] ?? "low",
              ),
            )),
      ],
    ),
  ),
                    const SizedBox(height: 16),

    if (emergencies.isNotEmpty)
  buildSoftCard(
    child: Column(
      children: [
        sectionTitle("Emergency History", Icons.warning_amber_rounded),
        const SizedBox(height: 16),

        ...emergencies.map((e) => buildEmergencyCard(
              Emergency(
                date: e["date"] ?? "",
                reason: e["reason"] ?? "",
                resolved: e["resolved"] ?? false,
              ),
            )),
      ],
    ),
  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}