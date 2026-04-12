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
      details: 'Blood pressure reading: 180/110. Patient reports severe headache and dizziness. Immediate attention required.',
    ),
    EmergencyCase(
      id: 2,
      patientId: 2,
      patientName: 'Mary Smith',
      time: '09:15 AM',
      alertType: 'Multiple Missed Doses',
      status: 'active',
      severity: 'medium',
      details: 'Patient has missed 3 consecutive doses of Warfarin. Last taken dose was 36 hours ago.',
    ),
    EmergencyCase(
      id: 3,
      patientId: 7,
      patientName: 'Michael Brown',
      time: '08:45 AM',
      alertType: 'Severe Side Effect',
      status: 'active',
      severity: 'high',
      details: 'Patient reports severe allergic reaction to new antibiotic. Symptoms include rash and difficulty breathing.',
    ),
    EmergencyCase(
      id: 4,
      patientId: 1,
      patientName: 'John Doe',
      time: 'Yesterday 3:45 PM',
      alertType: 'High Blood Pressure',
      status: 'resolved',
      severity: 'medium',
      details: 'Blood pressure reading: 165/98. Patient took additional medication as prescribed. Follow-up reading normal.',
    ),
  ];

  EmergencyCase? selectedCase;

  Color severityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.orange.shade100;
      case 'low':
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color severityTextColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red.shade700;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
        return Colors.yellow.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Color statusColor(String status) {
    return status == 'active' ? Colors.red.shade100 : Colors.green.shade100;
  }

  Color statusTextColor(String status) {
    return status == 'active' ? Colors.red.shade700 : Colors.green.shade700;
  }

  Widget buildEmergencyCard(EmergencyCase ec) {
    return Card(
      color:Color.fromARGB(255, 236, 241, 243),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(ec.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Time: ${ec.time}'),
            Text('Alert: ${ec.alertType}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor(ec.severity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ec.severity.toUpperCase(),
                    style: TextStyle(
                      color: severityTextColor(ec.severity),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor(ec.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ec.status == 'active' ? 'Active' : 'Resolved',
                    style: TextStyle(
                      color: statusTextColor(ec.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: () {
            setState(() {
              selectedCase = ec;
            });
            showDialog(
              context: context,
              builder: (_) => EmergencyCaseDialog(emergencyCase: ec),
            );
          },
          child:  Text('View Case',style: TextStyle(color: AppColors.blueColor),),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    final activeCases = emergencyCases.where((c) => c.status == 'active').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
                 SizedBox(height: 40,),

        Text('Emergency Alert',style: TextStyle(color:  AppColors.blueColor,fontWeight: FontWeight.bold,fontSize: 22),),
                    SizedBox(height: 30,),
            if (activeCases.isNotEmpty)
              Card(
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${activeCases.length} Active Emergency Alert${activeCases.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                            Text(
                              'Immediate attention required for critical cases',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 13),
            Expanded(
              child: isMobile
                  ? ListView.builder(
                      itemCount: emergencyCases.length,
                      itemBuilder: (context, index) {
                        return buildEmergencyCard(emergencyCases[index]);
                      },
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Patient')),
                          DataColumn(label: Text('Time')),
                          DataColumn(label: Text('Alert Type')),
                          DataColumn(label: Text('Severity')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: emergencyCases
                            .map(
                              (ec) => DataRow(
                                cells: [
                                  DataCell(Text(ec.patientName)),
                                  DataCell(Text(ec.time)),
                                  DataCell(Text(ec.alertType)),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: severityColor(ec.severity),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      ec.severity.toUpperCase(),
                                      style: TextStyle(
                                        color: severityTextColor(ec.severity),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor(ec.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      ec.status == 'active' ? 'Active' : 'Resolved',
                                      style: TextStyle(
                                        color: statusTextColor(ec.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                                  DataCell(TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => EmergencyCaseDialog(emergencyCase: ec),
                                      );
                                    },
                                    child: const Text('View Case'),
                                  )),
                                ],
                              ),
                            )
                            .toList(),
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
  const EmergencyCaseDialog({super.key, required this.emergencyCase});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Emergency Case Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient: ${emergencyCase.patientName}'),
            Text('Time: ${emergencyCase.time}'),
            const SizedBox(height: 8),
            Text('Alert Type: ${emergencyCase.alertType}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Severity: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: emergencyCase.severity == 'high'
                        ? Colors.red.shade100
                        : emergencyCase.severity == 'medium'
                            ? Colors.orange.shade100
                            : Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    emergencyCase.severity.toUpperCase(),
                    style: TextStyle(
                      color: emergencyCase.severity == 'high'
                          ? Colors.red.shade700
                          : emergencyCase.severity == 'medium'
                              ? Colors.orange.shade700
                              : Colors.yellow.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Details: ${emergencyCase.details}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailsPage(),
              ),
            );
          },
          child: const Text('View Patient Details'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}