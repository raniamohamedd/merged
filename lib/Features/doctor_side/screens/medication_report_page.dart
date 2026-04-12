import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class MedicationReportsPage extends StatefulWidget {
  const MedicationReportsPage({super.key});

  @override
  State<MedicationReportsPage> createState() => _MedicationReportsPageState();
}

class _MedicationReportsPageState extends State<MedicationReportsPage> {
  String selectedPatient = 'all';
  String selectedLevel = 'all';

  final List<Map<String, dynamic>> adherenceComparison = [
    {'patient': 'John', 'adherence': 92},
    {'patient': 'Mary', 'adherence': 78},
    {'patient': 'Robert', 'adherence': 95},
    {'patient': 'Lisa', 'adherence': 85},
    {'patient': 'James', 'adherence': 65},
    {'patient': 'Emma', 'adherence': 88},
  ];

  final List<Map<String, dynamic>> medicationCategories = [
    {'name': 'Cardio', 'value': 35, 'color': Color(0xFF4A90E2)},
    {'name': 'Diabetes', 'value': 28, 'color': Color(0xFF7B8D93)},
    {'name': 'Pain', 'value': 20, 'color': Color(0xFF6FCF97)},
    {'name': 'Antibiotics', 'value': 17, 'color': Color(0xFFF2C94C)},
  ];

  final List<Map<String, dynamic>> medicationEvents = [
    {
      'date': '2025-11-15',
      'patient': 'James Wilson',
      'medication': 'Metformin',
      'event': 'Missed Dose',
      'severity': 'high'
    },
    {
      'date': '2025-11-15',
      'patient': 'Mary Smith',
      'medication': 'Lisinopril',
      'event': 'Taken on Time',
      'severity': 'low'
    },
    {
      'date': '2025-11-14',
      'patient': 'John Doe',
      'medication': 'Atorvastatin',
      'event': 'Side Effect Reported',
      'severity': 'medium'
    },
    {
      'date': '2025-11-14',
      'patient': 'Lisa Martin',
      'medication': 'Warfarin',
      'event': 'Missed Dose',
      'severity': 'high'
    },
    {
      'date': '2025-11-14',
      'patient': 'Robert King',
      'medication': 'Aspirin',
      'event': 'Taken on Time',
      'severity': 'low'
    },
    {
      'date': '2025-11-13',
      'patient': 'Emma Roberts',
      'medication': 'Insulin',
      'event': 'Taken on Time',
      'severity': 'low'
    },
    {
      'date': '2025-11-13',
      'patient': 'Michael Brown',
      'medication': 'Amoxicillin',
      'event': 'Side Effect Reported',
      'severity': 'medium'
    },
  ];

  final Map<String, Color> severityColors = {
    'high': const Color(0xFFE74C3C),
    'medium': const Color(0xFFF39C12),
    'low': const Color(0xFF27AE60),
  };

  List<Map<String, dynamic>> get filteredEvents {
    return medicationEvents.where((event) {
      final matchesPatient =
          selectedPatient == 'all' || event['patient'] == selectedPatient;
      final matchesLevel =
          selectedLevel == 'all' || event['severity'] == selectedLevel;
      return matchesPatient && matchesLevel;
    }).toList();
  }

  void handleDownloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading PDF report...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: const Color(0xFFF7FAFC),
        surfaceTintColor: Colors.transparent,
        title:  Text(
          'Medication Reports',
          style: TextStyle(
            color:AppColors.blueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: handleDownloadReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text("Export"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comprehensive medication adherence analytics',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            /// FILTERS
            _softCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune_rounded,
                          color: AppColors.blueColor, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  isMobile
                      ? Column(
                          children: [
                            _buildPatientDropdown(),
                            const SizedBox(height: 12),
                            _buildPriorityDropdown(),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildPatientDropdown()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildPriorityDropdown()),
                          ],
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CHARTS
            isMobile
                ? Column(
                    children: [
                      _buildBarChartCard(),
                      const SizedBox(height: 16),
                      buildPieChartCard(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildBarChartCard()),
                      const SizedBox(width: 16),
                      Expanded(child: buildPieChartCard()),
                    ],
                  ),

            const SizedBox(height: 20),

            /// EVENT LOG
            _softCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Medication Event Log",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 14),
                  filteredEvents.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: const Center(
                            child: Text(
                              "No matching events found",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              AppColors.blueColor.withOpacity(.08),
                            ),
                            columnSpacing: 28,
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: 64,
                            columns: const [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Patient')),
                              DataColumn(label: Text('Medication')),
                              DataColumn(label: Text('Event')),
                              DataColumn(label: Text('Priority')),
                            ],
                            rows: filteredEvents
                                .map(
                                  (event) => DataRow(
                                    cells: [
                                      DataCell(Text(event['date'])),
                                      DataCell(Text(event['patient'])),
                                      DataCell(Text(event['medication'])),
                                      DataCell(Text(event['event'])),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: severityColors[event['severity']]!
                                                .withOpacity(.12),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Text(
                                            (event['severity'] as String)
                                                .capitalize(),
                                            style: TextStyle(
                                              color: severityColors[
                                                  event['severity']],
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDropdown() {
    return _customDropdown<String>(
      value: selectedPatient,
      label: "Patient",
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Patients')),
        DropdownMenuItem(value: 'John Doe', child: Text('John Doe')),
        DropdownMenuItem(value: 'Mary Smith', child: Text('Mary Smith')),
        DropdownMenuItem(value: 'James Wilson', child: Text('James Wilson')),
        DropdownMenuItem(value: 'Lisa Martin', child: Text('Lisa Martin')),
      ],
      onChanged: (value) {
        setState(() {
          selectedPatient = value!;
        });
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return _customDropdown<String>(
      value: selectedLevel,
      label: "Priority",
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Levels')),
        DropdownMenuItem(value: 'high', child: Text('High Priority')),
        DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
        DropdownMenuItem(value: 'low', child: Text('Low Priority')),
      ],
      onChanged: (value) {
        setState(() {
          selectedLevel = value!;
        });
      },
    );
  }

  Widget _customDropdown<T>({
    required T value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: InputBorder.none,
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.blueColor),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildBarChartCard() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Adherence Comparison",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Medication adherence rate by patient",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: 100,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 34,
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 42,
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < adherenceComparison.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              adherenceComparison[index]["patient"],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  adherenceComparison.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: adherenceComparison[index]["adherence"].toDouble(),
                        width: 18,
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blueColor.withOpacity(.95),
                            AppColors.blueColor.withOpacity(.65),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPieChartCard() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Medication Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Distribution of medication types",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 42,
                      sectionsSpace: 4,
                      sections: medicationCategories.map((item) {
                        return PieChartSectionData(
                          color: item["color"],
                          value: (item["value"] as int).toDouble(),
                          title: "${item["value"]}%",
                          radius: 58,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  children: medicationCategories.map((item) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item["color"],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item["name"],
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}