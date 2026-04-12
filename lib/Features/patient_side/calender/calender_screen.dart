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

// class AppColors {
//   static const Color blueColor = Color(0xFF1565C0);
// }

class Reportscreen extends StatefulWidget {
  const Reportscreen({super.key});

  @override
  State<Reportscreen> createState() => _ReportscreenState();
}

class _ReportscreenState extends State<Reportscreen> {
  bool isGenerating = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Health Reports",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueColor,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 2, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Overview',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Last week's data"),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                icon: isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  isGenerating ? "Generating PDF..." : "Download PDF Report",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isGenerating ? null : generateAndSavePdf,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Blood Pressure",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Recent readings (7 days)",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      key: _bloodPressureKey,
                      child: Container(
                        color: Colors.white,
                        child: const AnimatedBloodPressureChart(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendItem(Colors.green, "Diastolic"),
                        const SizedBox(width: 16),
                        _legendItem(Colors.blue, "Systolic"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Glucose Levels",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Morning Readings (mg/dL)",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      key: _glucoseKey,
                      child: Container(
                        color: Colors.white,
                        child: SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              minY: 80,
                              maxY: 120,
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 10,
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  left: BorderSide(color: Colors.grey),
                                  bottom: BorderSide(color: Colors.grey),
                                  right: BorderSide(color: Colors.transparent),
                                  top: BorderSide(color: Colors.transparent),
                                ),
                              ),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 10,
                                    reservedSize: 35,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 2,
                                    getTitlesWidget: (value, meta) {
                                      const labels = {
                                        0: 'Sep 25',
                                        2: 'Sep 27',
                                        4: 'Sep 29',
                                        6: 'Oct 01',
                                      };
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          labels[value.toInt()] ?? '',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 105),
                                    FlSpot(1, 98),
                                    FlSpot(2, 110),
                                    FlSpot(3, 102),
                                    FlSpot(4, 108),
                                    FlSpot(5, 95),
                                    FlSpot(6, 103),
                                  ],
                                  isCurved: true,
                                  color: Colors.orange,
                                  barWidth: 2,
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendItem(Colors.orange, "Glucose"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Medication Adherence",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Adherence Rate",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      key: _adherenceKey,
                      child: Container(
                        color: Colors.white,
                        child: SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              maxY: 100,
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 25,
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  left: BorderSide(color: Colors.grey),
                                  bottom: BorderSide(color: Colors.grey),
                                  right: BorderSide(color: Colors.transparent),
                                  top: BorderSide(color: Colors.transparent),
                                ),
                              ),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 25,
                                    reservedSize: 35,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      const labels = {
                                        0: 'Mon',
                                        1: 'Tue',
                                        2: 'Wed',
                                        3: 'Thu',
                                        4: 'Fri',
                                        5: 'Sat',
                                        6: 'Sun',
                                      };
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          labels[value.toInt()] ?? '',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [
                                  BarChartRodData(
                                    toY: 100,
                                    color: Colors.purple,
                                    width: 12,
                                  ),
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  BarChartRodData(
                                    toY: 100,
                                    color: Colors.purple,
                                    width: 12,
                                  ),
                                ]),
                                BarChartGroupData(x: 2, barRods: [
                                  BarChartRodData(
                                    toY: 75,
                                    color: Colors.purple,
                                    width: 12,
                                  ),
                                ]),
                                BarChartGroupData(x: 3, barRods: [
                                  BarChartRodData(
                                    toY: 100,
                                    color: Colors.purple,
                                    width: 12,
                                  ),
                                ]),
                                BarChartGroupData(x: 4, barRods: [
                                  BarChartRodData(
                                    toY: 100,
                                    color: Colors.purple,
                                    width: 12,
                                  ),
                                ]),
                                BarChartGroupData(x: 5, barRods: [
                                  BarChartRodData(
                                    toY: 100,
                                    color: Colors.purple,
                                    width: 12,
                                  ),
                                ]),
                                BarChartGroupData(x: 6, barRods: [
                                  BarChartRodData(
                                    toY: 100,
                                    color: Colors.purple,
                                    width: 12,
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendItem(Colors.purple, "Adherence"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                summaryCard(
                  "Avg Blood Pressure",
                  "120/80 mmHg",
                  "Normal",
                  Colors.blue,
                  Colors.green,
                ),
                summaryCard(
                  "Avg Glucose",
                  "103 mg/dL",
                  "Normal",
                  Colors.amber,
                  Colors.green,
                ),
                summaryCard(
                  "Med Adherence",
                  "96%",
                  "Excellent",
                  Colors.purple,
                  Colors.green,
                ),
                summaryCard(
                  "Weight",
                  "75 kg",
                  "Stable",
                  Colors.blue,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

Widget _legendItem(Color color, String text) {
  return Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12)),
    ],
  );
}

Widget summaryCard(
  String title,
  String value,
  String status,
  Color valueColor,
  Color statusColor,
) {
  return Card(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(color: statusColor)),
        ],
      ),
    ),
  );
}

class AnimatedBloodPressureChart extends StatefulWidget {
  const AnimatedBloodPressureChart({super.key});

  @override
  State<AnimatedBloodPressureChart> createState() =>
      _AnimatedBloodPressureChartState();
}

class _AnimatedBloodPressureChartState
    extends State<AnimatedBloodPressureChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 60,
          maxY: 140,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 20,
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.grey),
              bottom: BorderSide(color: Colors.grey),
              right: BorderSide(color: Colors.transparent),
              top: BorderSide(color: Colors.transparent),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const labels = {
                    0: 'Mon',
                    1: 'Tue',
                    2: 'Wed',
                    3: 'Thu',
                    4: 'Fri',
                    5: 'Sat',
                    6: 'Sun',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 80),
                FlSpot(1, 82),
                FlSpot(2, 78),
                FlSpot(3, 81),
                FlSpot(4, 79),
                FlSpot(5, 80),
                FlSpot(6, 77),
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: const [
                FlSpot(0, 120),
                FlSpot(1, 122),
                FlSpot(2, 118),
                FlSpot(3, 124),
                FlSpot(4, 121),
                FlSpot(5, 119),
                FlSpot(6, 117),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}