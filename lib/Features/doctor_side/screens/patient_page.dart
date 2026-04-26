import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_detailsdoc.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

class Patient {

  final String userId;   // user id (IMPORTANT)
 
  final String id;
  final String name;
  final int age;
  final int medicationCount;
  final String status;

  Patient({
        required this.userId,

    required this.id,
    required this.name,
    required this.age,
    required this.medicationCount,
    required this.status,
  });
  static String _getStatus(Map<String, dynamic> json) {
  final diseases = json['chronicDiseases'] as List?;
  if (diseases != null && diseases.isNotEmpty) {
    return diseases[0]['status'] ?? 'stable';
  }
  return 'stable';
}factory Patient.fromJson(Map<String, dynamic> json) {
  final user = json['userId'] ?? {};

  return Patient(
    id: json['_id'] ?? '',
    userId: user['_id'] ?? '',
    name: user['fullName'] ?? 'Unknown',
    age: user['DOB'] != null
        ? DateTime.now().year - DateTime.parse(user['DOB']).year
        : 0,
    medicationCount: (json['medications'] as List?)?.length ?? 0,
    status: _getStatus(json),
  );
}}

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
 List<Patient> allPatients = [];
bool isLoading = true;
Future<void> loadPatients() async {
  try {
    final response = await ApiService.getPatients();

    print("RAW RESPONSE: $response");

    final List data =
       response['data'] ?? [];

    setState(() {
      allPatients = data
          .map((e) => Patient.fromJson(e))
          .toList();

      isLoading = false;
    });

    print("LOADED: ${allPatients.length}");
  } catch (e) {
    print("ERROR LOAD: $e");
    setState(() {
      isLoading = false;
    });
  }
}

@override
  void initState() {
  super.initState();
  loadPatients();
}

  String searchQuery = '';
  String filter = 'all';

List<Patient> get filteredPatients {
  return allPatients.where((p) {
    final matchesSearch =
        p.name.toLowerCase().contains(searchQuery.toLowerCase());

    final matchesFilter =
        filter == 'all' || p.status == filter;

    return matchesSearch && matchesFilter;
  }).toList();
}

  int get stableCount =>
      allPatients.where((e) => e.status == 'stable').length;

  int get monitoringCount =>
      allPatients.where((e) => e.status == 'monitoring').length;

  int get criticalCount =>
      allPatients.where((e) => e.status == 'critical').length;

  Color statusColor(String status) {
    switch (status) {
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
    switch (status) {
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

  String statusLabel(String status) {
    switch (status) {
      case 'stable':
        return 'Stable';
      case 'monitoring':
        return 'Monitoring';
      case 'critical':
        return 'Critical';
      default:
        return status;
    }
  }

  Widget buildFilterChip(String label, String value) {
    final isActive = filter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          filter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isActive ? AppColors.blueColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.blueColor : Colors.grey.shade300,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.blueColor.withOpacity(.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F2F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(.10),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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

  Widget buildPatientCard(Patient p) {
    final color = statusColor(p.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.blueColor.withOpacity(.10),
                child: Text(
                  p.name.isNotEmpty ? p.name[0] : 'P',
                  style: TextStyle(
                    color: AppColors.blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Age ${p.age} • ${p.medicationCount} medications",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: statusBgColor(p.status),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  statusLabel(p.status),
                  style: TextStyle(
                    color: color,
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
              // Expanded(
              //   child: _miniInfoBox(
              //     title: "Adherence",
              //     value: "${p.adherence}%",
              //     color: p.adherence >= 85
              //         ? Colors.greenx
              //         : p.adherence >= 70
              //             ? Colors.orange
              //             : Colors.red,
              //     icon: Icons.show_chart_rounded,
              //   ),
              // ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniInfoBox(
                  title: "Medications",
                  value: p.medicationCount.toString(),
                  color: AppColors.blueColor,
                  icon: Icons.medication_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailsPage(patientId: p.userId,),
                  ),
                );
              },
              icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
              label: const Text(
                'View Patient Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfoBox({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(.14),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildSearchAndFilters() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0F2F5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search patient by name...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: AppColors.blueColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              buildFilterChip('All', 'all'),
              const SizedBox(width: 8),
              buildFilterChip('Stable', 'stable'),
              const SizedBox(width: 8),
              buildFilterChip('Monitoring', 'monitoring'),
              const SizedBox(width: 8),
              buildFilterChip('Critical', 'critical'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER الثابت
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 39, 16, 0),
              child:
               Container(
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patients',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${filteredPatients.length} patients available",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// الجزء المتحرك فقط
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        buildStatCard(
                          title: "Stable",
                          value: stableCount.toString(),
                          color: Colors.green,
                          icon: Icons.favorite_outline,
                        ),
                        const SizedBox(width: 10),
                        buildStatCard(
                          title: "Monitoring",
                          value: monitoringCount.toString(),
                          color: Colors.orange,
                          icon: Icons.visibility_outlined,
                        ),
                        const SizedBox(width: 10),
                        buildStatCard(
                          title: "Critical",
                          value: criticalCount.toString(),
                          color: Colors.red,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildSearchAndFilters(),
                    const SizedBox(height: 16),
                    filteredPatients.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                "No patients found",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        :  
                        ListView.builder(
                          itemCount: filteredPatients.length,
  shrinkWrap: true,
  physics: const BouncingScrollPhysics(),
                           
                            itemBuilder: (context, index) {
                              return buildPatientCard(filteredPatients[index]);
                            },
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