import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class PatientReportScreen extends StatefulWidget {
  const PatientReportScreen({super.key});

  @override
  State<PatientReportScreen> createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  bool isLoading = true;
  bool isGenerating = false;
  Map<String, dynamic> summary = {};
  List<dynamic> logs = [];
  String errorMessage = '';
  String selectedStatus = 'all';

  final GlobalKey _pieKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final data = await ApiService.getPatientReport();
      setState(() {
        summary = data["summary"] ?? {};
        logs = data["logs"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<dynamic> get filteredLogs {
    if (selectedStatus == 'all') return logs;
    return logs.where((l) => l["status"] == selectedStatus).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'taken':
        return const Color(0xFF27AE60);
      case 'missed':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFF39C12);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'taken':
        return Icons.check_circle_rounded;
      case 'missed':
        return Icons.cancel_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } catch (_) {
      return iso;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  // ── PDF
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;
      return (await Permission.manageExternalStorage.request()).isGranted;
    }
    return true;
  }

  Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      final ctx = key.currentContext;
      if (ctx == null) return null;
      final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      return bd?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<Directory> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      final d = Directory('/storage/emulated/0/Download');
      if (await d.exists()) return d;
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<void> _generatePdf() async {
    setState(() => isGenerating = true);
    try {
      if (!await _requestStoragePermission()) {
        throw Exception("Storage permission denied");
      }
      await Future.delayed(const Duration(milliseconds: 300));
      final pieImage = await _captureWidget(_pieKey);

      final taken = summary["taken"] ?? 0;
      final missed = summary["missed"] ?? 0;
      final pending = summary["pending"] ?? 0;
      final adherence = summary["adherenceRate"] ?? "0%";
      final activeMeds = summary["activeMedications"] ?? 0;
      final total = summary["total"] ?? 0;

      final pdf = pw.Document();

      final logsTableData = [
        ['Medication', 'Date', 'Scheduled', 'Status', 'Taken At'],
        ...logs.map((log) => [
              log["medicineName"] ?? "Unknown",
              _formatDate(log["scheduledTime"] ?? ""),
              _formatTime(log["scheduledTime"] ?? ""),
              (log["status"] ?? "pending").toString(),
              log["takenAt"] != null ? _formatTime(log["takenAt"]) : "-",
            ]),
      ];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (ctx) => [
            pw.Center(
              child: pw.Text(
                'My Medication Report',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'Daily medication adherence summary — Generated by MedPal',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary row
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfItem("Adherence", adherence, PdfColors.purple),
                  _pdfItem("Total", "$total", PdfColors.blue700),
                  _pdfItem("Taken", "$taken", PdfColors.green),
                  _pdfItem("Missed", "$missed", PdfColors.red),
                  _pdfItem("Pending", "$pending", PdfColors.orange),
                  _pdfItem("Active Meds", "$activeMeds", PdfColors.teal),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Pie chart
            if (pieImage != null) ...[
              pw.Text(
                'Status Distribution',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                height: 200,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Image(pw.MemoryImage(pieImage)),
              ),
              pw.SizedBox(height: 16),
            ],

            // Logs table
            pw.Text(
              'Medication Log Details',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: logsTableData.first,
              data: logsTableData.sublist(1),
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.7),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blue700),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.center,
              headerAlignment: pw.Alignment.center,
              cellPadding: const pw.EdgeInsets.all(5),
              headerPadding: const pw.EdgeInsets.all(7),
            ),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text(
              "Generated by MedPal App",
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      );

      final dir = await _getSaveDirectory();
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File('${dir.path}/medication_report.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      setState(() => isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ PDF saved:\n${file.path}'),
          backgroundColor: AppColors.blueColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taken = summary["taken"] ?? 0;
    final missed = summary["missed"] ?? 0;
    final pending = summary["pending"] ?? 0;
    final total = summary["total"] ?? 0;
    final adherence = summary["adherenceRate"] ?? '0%';
    final activeMeds = summary["activeMedications"] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded,
                      color: AppColors.blueColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "My Report",
                    style: TextStyle(
                      color: AppColors.blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Download button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: isGenerating || isLoading ? null : _generatePdf,
              icon: isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded,
                      color: Colors.white, size: 18),
              label: Text(
                isGenerating ? "..." : "PDF",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loadReport,
                          child: const Text("Retry")),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReport,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      // ── Adherence Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.blueColor,
                              AppColors.blueColor.withOpacity(0.7)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Adherence Rate",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(adherence,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("$activeMeds active medications",
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13)),
                                ]),
                          ),
                          const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 56),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // ── Stats Row
                      Row(children: [
                        _statCard('Total', '$total', AppColors.blueColor,
                            Icons.list_alt_rounded),
                        const SizedBox(width: 8),
                        _statCard('Taken', '$taken',
                            const Color(0xFF27AE60), Icons.check_circle_rounded),
                        const SizedBox(width: 8),
                        _statCard('Missed', '$missed',
                            const Color(0xFFE74C3C), Icons.cancel_rounded),
                        const SizedBox(width: 8),
                        _statCard('Pending', '$pending',
                            const Color(0xFFF39C12), Icons.access_time_rounded),
                      ]),
                      const SizedBox(height: 16),

                      // ── Pie Chart
                      if (total > 0) ...[
                        _buildPieChart(taken, missed, pending),
                        const SizedBox(height: 16),
                      ],

                      // ── Logs
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(.04),
                                blurRadius: 10)
                          ],
                        ),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(children: [
                              const Icon(Icons.list_alt_rounded,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              const Text("Medication Logs",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const Spacer(),
                              _filterDropdown(),
                            ]),
                          ),
                          const Divider(height: 1),
                          if (filteredLogs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Text("No logs found",
                                  style: TextStyle(color: Colors.grey)),
                            )
                          else
                            ...filteredLogs.map((log) => _buildLogCard(log)),
                          const SizedBox(height: 8),
                        ]),
                      ),

                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
    );
  }

  Widget _statCard(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.04), blurRadius: 8)
          ],
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(title,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _buildPieChart(int taken, int missed, int pending) {
    final total = taken + missed + pending;
    return RepaintBoundary(
      key: _pieKey,
      child: Container(
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.04), blurRadius: 10)
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.pie_chart_rounded, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text("Status Overview",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 3,
                sections: [
                  if (taken > 0)
                    PieChartSectionData(
                      value: taken.toDouble(),
                      color: const Color(0xFF27AE60),
                      title:
                          '${((taken / total) * 100).round()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  if (missed > 0)
                    PieChartSectionData(
                      value: missed.toDouble(),
                      color: const Color(0xFFE74C3C),
                      title:
                          '${((missed / total) * 100).round()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  if (pending > 0)
                    PieChartSectionData(
                      value: pending.toDouble(),
                      color: const Color(0xFFF39C12),
                      title:
                          '${((pending / total) * 100).round()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                ],
              )),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _legendDot(
                  const Color(0xFF27AE60), 'Taken ($taken)'),
              const SizedBox(width: 16),
              _legendDot(
                  const Color(0xFFE74C3C), 'Missed ($missed)'),
              const SizedBox(width: 16),
              _legendDot(
                  const Color(0xFFF39C12), 'Pending ($pending)'),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF4B5563))),
    ]);
  }

  Widget _filterDropdown() {
    return DropdownButton<String>(
      value: selectedStatus,
      underline: const SizedBox(),
      style: const TextStyle(fontSize: 12, color: Colors.black87),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All')),
        DropdownMenuItem(value: 'taken', child: Text('Taken')),
        DropdownMenuItem(value: 'missed', child: Text('Missed')),
        DropdownMenuItem(
            value: 'pending', child: Text('Pending')),
      ],
      onChanged: (v) => setState(() => selectedStatus = v!),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final status = log["status"] ?? "pending";
    final color = _statusColor(status);
    final icon = _statusIcon(status);
    final name = log["medicineName"] ?? "Unknown";
    final scheduled = _formatTime(log["scheduledTime"] ?? "");
    final date = _formatDate(log["scheduledTime"] ?? "");
    final takenAt =
        log["takenAt"] != null ? _formatTime(log["takenAt"]) : null;

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 3),
                Text("Scheduled: $date at $scheduled",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600)),
                if (takenAt != null) ...[
                  const SizedBox(height: 2),
                  Text("Taken at: $takenAt",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF27AE60))),
                ],
              ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12),
          ),
        ),
      ]),
    );
  }
}

// ── PDF helper
pw.Widget _pdfItem(String title, String value, PdfColor color) {
  return pw.Expanded(
    child: pw.Column(children: [
      pw.Text(title,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      pw.SizedBox(height: 3),
      pw.Text(value,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color)),
    ]),
  );
}