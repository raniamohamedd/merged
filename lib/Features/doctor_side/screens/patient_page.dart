import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_detailsdoc.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class Patient {
  final int id;
  final String name;
  final int age;
  final int medicationCount;
  final int adherence;
  final String status;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.medicationCount,
    required this.adherence,
    required this.status,
  });
}

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final List<Patient> allPatients = [
    Patient(id: 1, name: 'John Doe', age: 45, medicationCount: 5, adherence: 92, status: 'stable'),
    Patient(id: 2, name: 'Mary Smith', age: 62, medicationCount: 8, adherence: 78, status: 'monitoring'),
    Patient(id: 3, name: 'Robert King', age: 58, medicationCount: 6, adherence: 95, status: 'stable'),
    Patient(id: 4, name: 'Lisa Martin', age: 71, medicationCount: 10, adherence: 85, status: 'monitoring'),
    Patient(id: 5, name: 'James Wilson', age: 55, medicationCount: 7, adherence: 65, status: 'critical'),
    Patient(id: 6, name: 'Emma Roberts', age: 48, medicationCount: 4, adherence: 88, status: 'stable'),
    Patient(id: 7, name: 'Michael Brown', age: 67, medicationCount: 9, adherence: 72, status: 'monitoring'),
    Patient(id: 8, name: 'Sarah Davis', age: 53, medicationCount: 5, adherence: 90, status: 'stable'),
  ];

  String searchQuery = '';
  String filter = 'all';

  List<Patient> get filteredPatients {
    return allPatients.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = filter == 'all' || p.status == filter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color statusColor(String status) {
    switch (status) {
      case 'stable':
        return Colors.green.shade100;
      case 'monitoring':
        return Colors.yellow.shade100;
      case 'critical':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color statusTextColor(String status) {
    switch (status) {
      case 'stable':
        return Colors.green.shade800;
      case 'monitoring':
        return Colors.orange.shade800;
      case 'critical':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget filterButton(String label, String value) {
    final isActive = filter == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.blueColor : Colors.grey.shade100,
        foregroundColor: isActive ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          filter = value;
        });
      },
      child: Text(label),
    );
  }

  Widget buildSearchAndFilters(double width) {
    final isMobile = width < 600;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              filterButton('All', 'all'),
              filterButton('Low Risk', 'stable'),
              filterButton('Medium', 'monitoring'),
              filterButton('High Risk', 'critical'),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Wrap(
            spacing: 8,
            children: [
              filterButton('All', 'all'),
              filterButton('Low Risk', 'stable'),
              filterButton('Medium', 'monitoring'),
              filterButton('High Risk', 'critical'),
            ],
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   toolbarHeight: 80,
      //   title: const Text('Patients',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
      //   backgroundColor: Colors.white,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 40,),

        Text('Patients',style: TextStyle(color:  AppColors.blueColor,fontWeight: FontWeight.bold,fontSize: 22),),
                    SizedBox(height: 20,),

            buildSearchAndFilters(width),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Colors.grey.shade100),
                  dataRowColor: WidgetStateColor.resolveWith(
                    (states) => states.contains(WidgetState.hovered)
                        ? Colors.grey.shade50
                        : Colors.white,
                  ),
                  columns: const [
                                        DataColumn(label: Text('Action')),

                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Age')),
                    DataColumn(label: Text('Medications')),
                    DataColumn(label: Text('Adherence %')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: filteredPatients
                      .map(
                        (p) => DataRow(
                          cells: [
                             DataCell(
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientDetailsPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.remove_red_eye, size: 18),
                                label: const Text('View'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue.shade700,
                                ),
                              ),
                            ),
                            DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(p.age.toString())),
                            DataCell(Text(p.medicationCount.toString())),
                            DataCell(Text('${p.adherence}%')),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor(p.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p.status == 'stable'
                                    ? 'Stable'
                                    : p.status == 'monitoring'
                                        ? 'Under Monitoring'
                                        : 'Critical',
                                style: TextStyle(
                                  color: statusTextColor(p.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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