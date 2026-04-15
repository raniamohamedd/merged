import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_detailsdoc.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class EmergencyCase {
  final int id;
  final int patientId;
  final String patientName;
  final String time;
  final String alertType;
  final String status; // active or resolved
  final String severity; // high, medium, low
  final String details;

  EmergencyCase({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.time,
    required this.alertType,
    required this.status,
    required this.severity,
    required this.details,
  });
}

class EmergencyCasesPage extends StatefulWidget {
  const EmergencyCasesPage({super.key});

  @override
  State<EmergencyCasesPage> createState() => _EmergencyCasesPageState();
}

class _EmergencyCasesPageState extends State<EmergencyCasesPage> {
  final List<EmergencyCase> emergencyCases = [
    EmergencyCase(
      id: 1,
      patientId: 5,
      patientName: 'James Wilson',
      time: '10:30 AM',
      alertType: 'Critical Blood Pressure',
      status: 'active',
      severity: 'high',
      details:
          'Blood pressure reading: 180/110. Patient reports severe headache and dizziness. Immediate attention required.',
    ),
    EmergencyCase(
      id: 2,
      patientId: 2,
      patientName: 'Mary Smith',
      time: '09:15 AM',
      alertType: 'Multiple Missed Doses',
      status: 'active',
      severity: 'medium',
      details:
          'Patient has missed 3 consecutive doses of Warfarin. Last taken dose was 36 hours ago.',
    ),
    EmergencyCase(
      id: 3,
      patientId: 7,
      patientName: 'Michael Brown',
      time: '08:45 AM',
      alertType: 'Severe Side Effect',
      status: 'active',
      severity: 'high',
      details:
          'Patient reports severe allergic reaction to new antibiotic. Symptoms include rash and difficulty breathing.',
    ),
    EmergencyCase(
      id: 4,
      patientId: 1,
      patientName: 'John Doe',
      time: 'Yesterday 3:45 PM',
      alertType: 'High Blood Pressure',
      status: 'resolved',
      severity: 'medium',
      details:
          'Blood pressure reading: 165/98. Patient took additional medication as prescribed. Follow-up reading normal.',
    ),
  ];

  int get activeCount =>
      emergencyCases.where((e) => e.status == 'active').length;

  int get resolvedCount =>
      emergencyCases.where((e) => e.status == 'resolved').length;

  int get highCount =>
      emergencyCases.where((e) => e.severity == 'high').length;

  Color severityColor(String severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFE74C3C);
      case 'medium':
        return const Color(0xFFF39C12);
      case 'low':
        return const Color(0xFFF1C40F);
      default:
        return Colors.grey;
    }
  }

  Color severityBgColor(String severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFE74C3C).withOpacity(.10);
      case 'medium':
        return const Color(0xFFF39C12).withOpacity(.10);
      case 'low':
        return const Color(0xFFF1C40F).withOpacity(.12);
      default:
        return Colors.grey.shade100;
    }
  }

  Color statusColor(String status) {
    return status == 'active'
        ? const Color(0xFFE74C3C)
        : const Color(0xFF27AE60);
  }

  Color statusBgColor(String status) {
    return status == 'active'
        ? const Color(0xFFE74C3C).withOpacity(.10)
        : const Color(0xFF27AE60).withOpacity(.10);
  }

  Widget _softCard({required Widget child}) {
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

  Widget _statsCard({
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

  Widget buildEmergencyCard(EmergencyCase ec) {
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
                radius: 24,
                backgroundColor: severityColor(ec.severity).withOpacity(.10),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: severityColor(ec.severity),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ec.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ec.time,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: severityBgColor(ec.severity),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      ec.severity.toUpperCase(),
                      style: TextStyle(
                        color: severityColor(ec.severity),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor(ec.status),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      ec.status == 'active' ? 'Active' : 'Resolved',
                      style: TextStyle(
                        color: statusColor(ec.status),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              ec.alertType,
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              ec.details,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => EmergencyCaseDialog(emergencyCase: ec),
                );
              },
              icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
              label: const Text(
                "View Case Details",
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

  Widget _buildEmergencyBanner() {
    if (activeCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE74C3C).withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE74C3C).withOpacity(.14),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE74C3C).withOpacity(.12),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE74C3C),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$activeCount active emergency alert${activeCount > 1 ? 's' : ''}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB03A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Immediate attention required for critical cases.",
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppColors.blueColor.withOpacity(.08),
        ),
        columnSpacing: 28,
        dataRowMinHeight: 56,
        dataRowMaxHeight: 68,
        columns: const [
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Alert Type')),
          DataColumn(label: Text('Severity')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Action')),
        ],
        rows: emergencyCases.map((ec) {
          return DataRow(
            cells: [
              DataCell(Text(ec.patientName)),
              DataCell(Text(ec.time)),
              DataCell(Text(ec.alertType)),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: severityBgColor(ec.severity),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    ec.severity.toUpperCase(),
                    style: TextStyle(
                      color: severityColor(ec.severity),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor(ec.status),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    ec.status == 'active' ? 'Active' : 'Resolved',
                    style: TextStyle(
                      color: statusColor(ec.status),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              DataCell(
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EmergencyCaseDialog(emergencyCase: ec),
                    );
                  },
                  child: Text(
                    'View Case',
                    style: TextStyle(color: AppColors.blueColor),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.emergency_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Alerts',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Critical cases requiring immediate attention',
                            style: TextStyle(
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

            /// الجزء المتحرك
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _statsCard(
                          title: "Active",
                          value: activeCount.toString(),
                          color: const Color(0xFFE74C3C),
                          icon: Icons.warning_amber_rounded,
                        ),
                        const SizedBox(width: 10),
                        _statsCard(
                          title: "Resolved",
                          value: resolvedCount.toString(),
                          color: const Color(0xFF27AE60),
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        const SizedBox(width: 10),
                        _statsCard(
                          title: "High Risk",
                          value: highCount.toString(),
                          color: const Color(0xFFF39C12),
                          icon: Icons.priority_high_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildEmergencyBanner(),
                    const SizedBox(height: 16),
                    _softCard(
                      child: isMobile
                          ? Column(
                              children: emergencyCases
                                  .map((ec) => buildEmergencyCard(ec))
                                  .toList(),
                            )
                          : _buildDesktopTable(),
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

class EmergencyCaseDialog extends StatelessWidget {
  final EmergencyCase emergencyCase;

  const EmergencyCaseDialog({
    super.key,
    required this.emergencyCase,
  });

  Color severityColor(String severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFE74C3C);
      case 'medium':
        return const Color(0xFFF39C12);
      case 'low':
        return const Color(0xFFF1C40F);
      default:
        return Colors.grey;
    }
  }

  Color severityBgColor(String severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFE74C3C).withOpacity(.10);
      case 'medium':
        return const Color(0xFFF39C12).withOpacity(.10);
      case 'low':
        return const Color(0xFFF1C40F).withOpacity(.10);
      default:
        return Colors.grey.shade100;
    }
  }

  Color statusColor(String status) {
    return status == 'active'
        ? const Color(0xFFE74C3C)
        : const Color(0xFF27AE60);
  }

  Color statusBgColor(String status) {
    return status == 'active'
        ? const Color(0xFFE74C3C).withOpacity(.10)
        : const Color(0xFF27AE60).withOpacity(.10);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    severityColor(emergencyCase.severity).withOpacity(.10),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 28,
                  color: severityColor(emergencyCase.severity),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Emergency Case Details",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              _detailRow("Patient", emergencyCase.patientName),
              const SizedBox(height: 10),
              _detailRow("Time", emergencyCase.time),
              const SizedBox(height: 10),
              _detailRow("Alert Type", emergencyCase.alertType),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: severityBgColor(emergencyCase.severity),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          emergencyCase.severity.toUpperCase(),
                          style: TextStyle(
                            color: severityColor(emergencyCase.severity),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor(emergencyCase.status),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          emergencyCase.status == 'active'
                              ? 'ACTIVE'
                              : 'RESOLVED',
                          style: TextStyle(
                            color: statusColor(emergencyCase.status),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  emergencyCase.details,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientDetailsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_outline),
                  label: const Text("View Patient Details"),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}