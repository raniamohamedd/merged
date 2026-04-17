import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class MedicationReportsPage extends StatefulWidget {
  const MedicationReportsPage({super.key});

  @override
  State<MedicationReportsPage> createState() => _MedicationReportsPageState();
}

class _MedicationReportsPageState extends State<MedicationReportsPage> {
  String selectedPatient = 'all';
  String selectedLevel = 'all';
    bool isGenerating = false;
pw.Widget _pdfSummaryItem(String title, String value, PdfColor color) {
  return pw.Expanded(
    child: pw.Column(
      children: [
        pw.Text(
          title,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

  
  final GlobalKey _bloodPressureKey = GlobalKey();
  final GlobalKey _glucoseKey = GlobalKey();
  final GlobalKey _adherenceKey = GlobalKey();

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;

      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }
    return true;
  }

  Future<Directory> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return downloadDir;
      }
    }

    final docsDir = await getApplicationDocumentsDirectory();
    return docsDir;
  }

 
  final List<Map<String, dynamic>> adherenceComparison = [
    {'patient': 'John', 'adherence': 92},
    {'patient': 'Mary', 'adherence': 78},
    {'patient': 'Robert', 'adherence': 95},
    {'patient': 'Lisa', 'adherence': 85},
    {'patient': 'James', 'adherence': 65},
    {'patient': 'Emma', 'adherence': 88},
  ];

  Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      final context = key.currentContext;
      if (context == null) return null;

      final boundary =
          context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Capture error: $e");
      return null;
    }
  }

  Future<void> generateAndSavePdf() async {
    try {
      setState(() {
        isGenerating = true;
      });

      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception("Storage permission denied");
      }

      await Future.delayed(const Duration(milliseconds: 300));

      final bloodPressureImage = await _captureWidget(_bloodPressureKey);
      final glucoseImage = await _captureWidget(_glucoseKey);
      final adherenceImage = await _captureWidget(_adherenceKey);

      final pdf = pw.Document();

      final bloodPressureTable = [
        ['Day', 'Systolic', 'Diastolic'],
        ['Mon', '120', '80'],
        ['Tue', '122', '82'],
        ['Wed', '118', '78'],
        ['Thu', '124', '81'],
        ['Fri', '121', '79'],
        ['Sat', '119', '80'],
        ['Sun', '117', '77'],
      ];

      final glucoseTable = [
        ['Date', 'Glucose (mg/dL)'],
        ['Sep 25', '105'],
        ['Sep 26', '98'],
        ['Sep 27', '110'],
        ['Sep 28', '102'],
        ['Sep 29', '108'],
        ['Sep 30', '95'],
        ['Oct 01', '103'],
      ];

      final adherenceTable = [
        ['Day', 'Adherence %'],
        ['Mon', '100'],
        ['Tue', '100'],
        ['Wed', '75'],
        ['Thu', '100'],
        ['Fri', '100'],
        ['Sat', '100'],
        ['Sun', '100'],
      ];

      pw.Widget buildSectionTitle(String text) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8, top: 14),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
        );
      }

      pw.Widget buildTable(List<List<String>> data) {
        return pw.TableHelper.fromTextArray(
          headers: data.first,
          data: data.sublist(1),
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.7),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 10,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blue700,
          ),
          cellStyle: const pw.TextStyle(
            fontSize: 10,
          ),
          cellAlignment: pw.Alignment.center,
          headerAlignment: pw.Alignment.center,
          cellPadding: const pw.EdgeInsets.all(6),
          headerPadding: const pw.EdgeInsets.all(8),
        );
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Center(
              child: pw.Text(
                'Health Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                "Weekly health analytics summary",
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfSummaryItem("Avg Blood Pressure", "120/80 mmHg", PdfColors.blue),
                  _pdfSummaryItem("Avg Glucose", "103 mg/dL", PdfColors.orange),
                  _pdfSummaryItem("Med Adherence", "96%", PdfColors.purple),
                  _pdfSummaryItem("Weight", "75 kg", PdfColors.green),
                ],
              ),
            ),

            buildSectionTitle("Blood Pressure Overview"),
            pw.Text(
              "Recent readings for the last 7 days.",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 8),
            if (bloodPressureImage != null)
              pw.Container(
                height: 180,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Image(pw.MemoryImage(bloodPressureImage)),
              ),
            pw.SizedBox(height: 8),
            buildTable(bloodPressureTable),

            buildSectionTitle("Glucose Levels"),
            pw.Text(
              "Morning readings in mg/dL.",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 8),
            if (glucoseImage != null)
              pw.Container(
                height: 180,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Image(pw.MemoryImage(glucoseImage)),
              ),
            pw.SizedBox(height: 8),
            buildTable(glucoseTable),

            buildSectionTitle("Medication Adherence"),
            pw.Text(
              "Daily adherence percentage.",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 8),
            if (adherenceImage != null)
              pw.Container(
                height: 180,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Image(pw.MemoryImage(adherenceImage)),
              ),
            pw.SizedBox(height: 8),
            buildTable(adherenceTable),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text(
              "Generated by MedPal App",
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      );

      final saveDir = await _getSaveDirectory();
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final file = File('${saveDir.path}/health_report.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      setState(() {
        isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved successfully:\n${file.path}'),
          backgroundColor: AppColors.blueColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generation error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

 
  final List<Map<String, dynamic>> medicationCategories = [
    {'name': 'Cardio', 'value': 35, 'color': const Color(0xFF4A90E2)},
    {'name': 'Diabetes', 'value': 28, 'color': const Color(0xFF7B8D93)},
    {'name': 'Pain', 'value': 20, 'color': const Color(0xFF6FCF97)},
    {'name': 'Antibiotics', 'value': 17, 'color': const Color(0xFFF2C94C)},
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

  int get highCount =>
      medicationEvents.where((e) => e['severity'] == 'high').length;

  int get mediumCount =>
      medicationEvents.where((e) => e['severity'] == 'medium').length;

  int get lowCount =>
      medicationEvents.where((e) => e['severity'] == 'low').length;

  void handleDownloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Downloading PDF report...'),
        backgroundColor: AppColors.blueColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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

  Widget _sectionTitle({
    required String title,
    required IconData icon,
  }) {
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
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: InputBorder.none,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.blueColor,
        ),
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
          _sectionTitle(
            title: "Adherence Comparison",
            icon: Icons.bar_chart_rounded,
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
                    return const FlLine(
                      color: Color(0xFFE5E7EB),
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
                        final index = value.toInt();
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
          _sectionTitle(
            title: "Medication Categories",
            icon: Icons.pie_chart_outline_rounded,
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

  Widget _buildEventCard(Map<String, dynamic> event) {
    final color = severityColors[event['severity']] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(.10),
                child: Icon(
                  Icons.medication_liquid_outlined,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event['patient'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  (event['severity'] as String).capitalize(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _miniEventRow("Date", event['date']),
          const SizedBox(height: 8),
          _miniEventRow("Medication", event['medication']),
          const SizedBox(height: 8),
          _miniEventRow("Event", event['event']),
        ],
      ),
    );
  }

  Widget _miniEventRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            "$label:",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
                        Icons.description_outlined,
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
                            'Medication Reports',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Analytics and medication event tracking',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      // onPressed: handleDownloadReport,
                      // style: ElevatedButton.styleFrom(
                      //   backgroundColor: Colors.white,
                      //   foregroundColor: AppColors.blueColor,
                      //   elevation: 0,
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 14,
                      //     vertical: 10,
                      //   ),
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(14),
                      //   ),
                      // ),
                      icon: const Icon(Icons.download_rounded, size: 18,color: Colors.blue,),
                      label: const Text("Export",style: TextStyle(color: Colors.blue),),
                       onPressed: isGenerating ? null : generateAndSavePdf,

                    ),
                  ],
                ),
              ),
            ),

            /// SCROLLABLE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _statsCard(
                          title: "High",
                          value: highCount.toString(),
                          color: const Color(0xFFE74C3C),
                          icon: Icons.priority_high_rounded,
                        ),
                        const SizedBox(width: 10),
                        _statsCard(
                          title: "Medium",
                          value: mediumCount.toString(),
                          color: const Color(0xFFF39C12),
                          icon: Icons.remove_red_eye_outlined,
                        ),
                        const SizedBox(width: 10),
                        _statsCard(
                          title: "Low",
                          value: lowCount.toString(),
                          color: const Color(0xFF27AE60),
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _softCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            title: "Filters",
                            icon: Icons.tune_rounded,
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

                    _softCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            title: "Medication Event Log",
                            icon: Icons.list_alt_rounded,
                          ),
                          const SizedBox(height: 14),
                          filteredEvents.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 28),
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
                              : isMobile
                                  ? Column(
                                      children: filteredEvents
                                          .map(_buildEventCard)
                                          .toList(),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingRowColor:
                                            WidgetStateProperty.all(
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
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: severityColors[
                                                                event['severity']]!
                                                            .withOpacity(.12),
                                                        borderRadius:
                                                            BorderRadius.circular(30),
                                                      ),
                                                      child: Text(
                                                        (event['severity']
                                                                as String)
                                                            .capitalize(),
                                                        style: TextStyle(
                                                          color: severityColors[
                                                              event['severity']],
                                                          fontWeight:
                                                              FontWeight.w700,
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
            ),
          ],
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}