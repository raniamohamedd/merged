import 'package:flutter/material.dart';

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
  Symptom({required this.date, required this.description, required this.severity});
}

class Emergency {
  final String date, reason;
  final bool resolved;
  Emergency({required this.date, required this.reason, required this.resolved});
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

class PatientDetailsPage extends StatelessWidget {
  final Patient patient = Patient(
    name: 'John Doe',
    age: 45,
    conditions: ['Hypertension', 'Type 2 Diabetes'],
    status: 'stable',
    medications: [
      Medication(name: 'Metformin', dosage: '500mg', frequency: 'Twice daily', nextDose: '2:00 PM', taken: true, sideEffects: 'None'),
      Medication(name: 'Lisinopril', dosage: '10mg', frequency: 'Once daily', nextDose: '8:00 AM', taken: true, sideEffects: 'None'),
      Medication(name: 'Atorvastatin', dosage: '20mg', frequency: 'Once daily', nextDose: '8:00 PM', taken: false, sideEffects: 'Mild headache'),
      Medication(name: 'Aspirin', dosage: '81mg', frequency: 'Once daily', nextDose: '8:00 AM', taken: true, sideEffects: 'None'),
    ],
    symptoms: [
      Symptom(date: '2025-11-14', description: 'Mild headache after evening medication', severity: 'low'),
      Symptom(date: '2025-11-12', description: 'Slight dizziness in the morning', severity: 'low'),
      Symptom(date: '2025-11-10', description: 'No symptoms reported', severity: 'none'),
      Symptom(date: '2025-11-08', description: 'Feeling fatigued', severity: 'medium'),
    ],
    emergencyHistory: [
      Emergency(date: '2025-11-13 3:45 PM', reason: 'High blood pressure reading (165/98)', resolved: true),
      Emergency(date: '2025-11-01 10:20 AM', reason: 'Missed multiple medications', resolved: true),
    ],
  );

  Color severityColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.yellow.shade600;
      case 'medium':
        return Colors.orange.shade600;
      case 'high':
        return Colors.red.shade600;
      default:
        return Colors.green.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Patient Details',style: TextStyle(color: Colors.white),),
        backgroundColor:Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.person, size: 40, color: Colors.blue.shade600),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Age: ${patient.age} • Conditions: ${patient.conditions.join(', ')}',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Stable', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Medication Schedule
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medication Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Medication Name')),
                          DataColumn(label: Text('Dosage')),
                          DataColumn(label: Text('Frequency')),
                          DataColumn(label: Text('Next Dose')),
                          DataColumn(label: Text('Taken?')),
                          DataColumn(label: Text('Side Effects')),
                        ],
                        rows: patient.medications.map((med) {
                          return DataRow(cells: [
                            DataCell(Text(med.name)),
                            DataCell(Text(med.dosage)),
                            DataCell(Text(med.frequency)),
                            DataCell(Text(med.nextDose)),
                            DataCell(Icon(med.taken ? Icons.check_circle : Icons.cancel,
                                color: med.taken ? Colors.green : Colors.red)),
                            DataCell(Text(med.sideEffects)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Symptoms Log
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Symptoms Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Column(
                      children: patient.symptoms.map((symptom) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: severityColor(symptom.severity)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(symptom.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(symptom.description, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Emergency History
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emergency History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Column(
                      children: patient.emergencyHistory.map((em) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(em.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('Resolved',
                                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(em.reason, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }).toList(),
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