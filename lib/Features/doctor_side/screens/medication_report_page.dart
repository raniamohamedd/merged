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

// ============================================================
//  Data Models
// ============================================================

class _PatientSummary {
  final String name;
  final int medicationCount;
  final String status;
  final int adherence; // estimated from status

  _PatientSummary({
    required this.name,
    required this.medicationCount,
    required this.status,
  }) : adherence = status == 'stable'
            ? 90
            : status == 'monitoring'
                ? 75
                : 60;
}

class _MedEvent {
  final String patientName;
  final String medicationName;
  final String dosage;
  final String severity; // low | medium | high (from warningLevel)
  final String event;    // from medication taken status

  _MedEvent({
    required this.patientName,
    required this.medicationName,
    required this.dosage,
    required this.severity,
    required this.event,
  });
}

// ============================================================
//  Page
// ============================================================

class MedicationReportsPage extends StatefulWidget {
  const MedicationReportsPage({super.key});

  @override
  State<MedicationReportsPage> createState() => _MedicationReportsPageState();
}

class _MedicationReportsPageState extends State<MedicationReportsPage> {
  // ── state ──────────────────────────────────────────────────
  bool isLoading = true;
  bool isGenerating = false;
  String errorMessage = '';

  List<_PatientSummary> patients = [];
  List<_MedEvent> events = [];

  String selectedPatient = 'all';
  String selectedLevel = 'all';

  // ── chart capture keys ─────────────────────────────────────
  final GlobalKey _adherenceKey = GlobalKey();
  final GlobalKey _pieKey = GlobalKey();

  // ── lifecycle ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── load real data ─────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await ApiService.getPatients();
      final List rawPatients = response['data'] ?? [];

      final List<_PatientSummary> loaded = [];
      final List<_MedEvent> loadedEvents = [];

      for (final p in rawPatients) {
        final user = p['userId'] ?? {};
        final name = user['fullName'] ?? 'Unknown';

        final diseases = (p['chronicDiseases'] as List?) ?? [];
        final status =
            diseases.isNotEmpty ? (diseases[0]['status'] ?? 'stable') : 'stable';

        final medications = (p['medications'] as List?) ?? [];

        loaded.add(_PatientSummary(
          name: name,
          medicationCount: medications.length,
          status: status,
        ));

        for (final med in medications) {
          final medName = med['name'] ?? med['medicationName'] ?? 'Unknown';
          final dosage = med['dosage'] ?? '';
          final rawWarning = med['warningLevel'] ?? 'low';
          // map backend values → low/medium/high
          final severity = _mapWarning(rawWarning);
          final taken = med['taken'] ?? false;
          final event = taken ? 'Taken on Time' : 'Missed Dose';

          loadedEvents.add(_MedEvent(
            patientName: name,
            medicationName: medName,
            dosage: dosage,
            severity: severity,
            event: event,
          ));
        }
      }

      setState(() {
        patients = loaded;
        events = loadedEvents;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _mapWarning(String raw) {
    switch (raw) {
      case 'severe':
        return 'high';
      case 'moderate':
        return 'medium';
      default:
        return 'low';
    }
  }

  // ── filtered events ────────────────────────────────────────
  List<_MedEvent> get filteredEvents {
    return events.where((e) {
      final matchPatient =
          selectedPatient == 'all' || e.patientName == selectedPatient;
      final matchLevel =
          selectedLevel == 'all' || e.severity == selectedLevel;
      return matchPatient && matchLevel;
    }).toList();
  }

  int get highCount => events.where((e) => e.severity == 'high').length;
  int get mediumCount => events.where((e) => e.severity == 'medium').length;
  int get lowCount => events.where((e) => e.severity == 'low').length;

  // ── color helpers ──────────────────────────────────────────
  Color _severityColor(String s) {
    switch (s) {
      case 'high':
        return const Color(0xFFE74C3C);
      case 'medium':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF27AE60);
    }
  }

  Color _severityBg(String s) => _severityColor(s).withOpacity(0.10);

  // ── PDF helpers ────────────────────────────────────────────
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final s = await Permission.storage.request();
      if (s.isGranted) return true;
      return (await Permission.manageExternalStorage.request()).isGranted;
    }
    return true;
  }

  Future<Uint8List?> _capture(GlobalKey key) async {
    try {
      final ctx = key.currentContext;
      if (ctx == null) return null;
      final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final img = await boundary.toImage(pixelRatio: 2.5);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      return bd?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _generatePdf() async {
    setState(() => isGenerating = true);
    try {
      if (!await _requestPermission()) throw Exception('No storage permission');
      await Future.delayed(const Duration(milliseconds: 300));

      final adherenceImg = await _capture(_adherenceKey);
      final pieImg = await _capture(_pieKey);

      final pdf = pw.Document();

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => [
          pw.Center(
            child: pw.Text(
              'Medication Report',
              style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text('Generated by MedPal — ${patients.length} patients',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          ),
          pw.SizedBox(height: 20),

          // Summary row
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
            _pdfStat('Patients', '${patients.length}', PdfColors.blue700),
            _pdfStat('High Risk Meds', '$highCount', PdfColors.red700),
            _pdfStat('Moderate', '$mediumCount', PdfColors.orange700),
            _pdfStat('Low Risk', '$lowCount', PdfColors.green700),
          ]),

          pw.SizedBox(height: 18),
          if (adherenceImg != null) ...[
            _pdfSection('Patient Adherence Overview'),
            pw.Image(pw.MemoryImage(adherenceImg), height: 180),
            pw.SizedBox(height: 12),
          ],
          if (pieImg != null) ...[
            _pdfSection('Medication Status Distribution'),
            pw.Image(pw.MemoryImage(pieImg), height: 180),
            pw.SizedBox(height: 12),
          ],

          _pdfSection('Medication Event Log'),
          pw.TableHelper.fromTextArray(
            headers: ['Patient', 'Medication', 'Dosage', 'Risk', 'Event'],
            data: events.take(30).map((e) => [
              e.patientName,
              e.medicationName,
              e.dosage,
              e.severity.toUpperCase(),
              e.event,
            ]).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.all(5),
          ),
        ],
      ));

      final dir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();
      if (!await dir.exists()) await dir.create(recursive: true);

      final file = File('${dir.path}/med_report.pdf');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PDF saved: ${file.path}'),
        backgroundColor: AppColors.blueColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ));
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  pw.Widget _pdfStat(String label, String val, PdfColor color) {
    return pw.Column(children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      pw.SizedBox(height: 4),
      pw.Text(val,
          style: pw.TextStyle(
              fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
    ]);
  }

  pw.Widget _pdfSection(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(title,
          style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800)),
    );
  }

  // ── UI helpers ─────────────────────────────────────────────
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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.blueColor.withOpacity(0.10),
        child: Icon(icon, color: AppColors.blueColor, size: 18),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
    ]);
  }

  Widget _statsCard(
      {required String title,
      required String value,
      required Color color,
      required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F2F5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.10),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ── adherence bar chart ─────────────────────────────────────
  Widget _buildAdherenceChart() {
    final visible = patients.take(8).toList();
    if (visible.isEmpty) {
      return const SizedBox(
          height: 180,
          child: Center(child: Text('No patient data yet')));
    }
    return _softCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Patient Adherence', Icons.bar_chart_rounded),
        const SizedBox(height: 4),
        Text('Estimated adherence by status',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 18),
        RepaintBoundary(
          key: _adherenceKey,
          child: SizedBox(
            height: 220,
            child: BarChart(BarChartData(
              maxY: 100,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Color(0xFFE5E7EB), strokeWidth: 1)),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < visible.length) {
                        final parts = visible[idx].name.split(' ');
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(parts[0],
                              style: const TextStyle(fontSize: 10)),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 20,
                      getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                          style: const TextStyle(fontSize: 10))),
                ),
              ),
              barGroups: visible.asMap().entries.map((e) {
                final p = e.value;
                final color = p.status == 'stable'
                    ? const Color(0xFF27AE60)
                    : p.status == 'monitoring'
                        ? const Color(0xFFF39C12)
                        : const Color(0xFFE74C3C);
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: p.adherence.toDouble(),
                      width: 18,
                      borderRadius: BorderRadius.circular(8),
                      color: color,
                    )
                  ],
                );
              }).toList(),
            )),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legendDot(const Color(0xFF27AE60), 'Stable'),
          const SizedBox(width: 16),
          _legendDot(const Color(0xFFF39C12), 'Monitoring'),
          const SizedBox(width: 16),
          _legendDot(const Color(0xFFE74C3C), 'Critical'),
        ]),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
    ]);
  }

  // ── medication status pie ───────────────────────────────────
  Widget _buildPieChart() {
    final takenCount = events.where((e) => e.event == 'Taken on Time').length;
    final missedCount = events.where((e) => e.event == 'Missed Dose').length;
    final total = takenCount + missedCount;

    return _softCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Medication Status', Icons.pie_chart_outline_rounded),
        const SizedBox(height: 4),
        Text('Taken vs Missed across all patients',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 18),
        if (total == 0)
          const SizedBox(
              height: 160,
              child: Center(child: Text('No medication data yet')))
        else
          RepaintBoundary(
            key: _pieKey,
            child: SizedBox(
              height: 200,
              child: Column(children: [
                Expanded(
                  child: PieChart(PieChartData(
                    centerSpaceRadius: 36,
                    sectionsSpace: 4,
                    sections: [
                      PieChartSectionData(
                        value: takenCount.toDouble(),
                        color: const Color(0xFF27AE60),
                        title: total > 0
                            ? '${((takenCount / total) * 100).round()}%'
                            : '',
                        radius: 55,
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      PieChartSectionData(
                        value: missedCount.toDouble(),
                        color: const Color(0xFFE74C3C),
                        title: total > 0
                            ? '${((missedCount / total) * 100).round()}%'
                            : '',
                        radius: 55,
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _legendDot(const Color(0xFF27AE60), 'Taken ($takenCount)'),
                  const SizedBox(width: 20),
                  _legendDot(const Color(0xFFE74C3C), 'Missed ($missedCount)'),
                ]),
              ]),
            ),
          ),
      ]),
    );
  }

  // ── event log ──────────────────────────────────────────────
  Widget _buildEventCard(_MedEvent event) {
    final color = _severityColor(event.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(Icons.medication_outlined, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event.patientName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 3),
            Text('${event.medicationName} — ${event.dosage}',
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 3),
            Text(event.event,
                style: TextStyle(
                    color: event.event == 'Taken on Time'
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFE74C3C),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: _severityBg(event.severity),
              borderRadius: BorderRadius.circular(20)),
          child: Text(event.severity.toUpperCase(),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 11)),
        ),
      ]),
    );
  }

  // ── filters ────────────────────────────────────────────────
  Widget _buildFilters() {
    final patientNames =
        patients.map((p) => p.name).toSet().toList()..sort();

    return _softCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Filters', Icons.tune_rounded),
        const SizedBox(height: 14),
        _filterDropdown<String>(
          label: 'Patient',
          value: selectedPatient,
          items: [
            const DropdownMenuItem(value: 'all', child: Text('All Patients')),
            ...patientNames.map((n) =>
                DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis))),
          ],
          onChanged: (v) => setState(() => selectedPatient = v!),
        ),
        const SizedBox(height: 12),
        _filterDropdown<String>(
          label: 'Risk Level',
          value: selectedLevel,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Levels')),
            DropdownMenuItem(value: 'high', child: Text('High Risk')),
            DropdownMenuItem(value: 'medium', child: Text('Medium Risk')),
            DropdownMenuItem(value: 'low', child: Text('Low Risk')),
          ],
          onChanged: (v) => setState(() => selectedLevel = v!),
        ),
      ]),
    );
  }

  Widget _filterDropdown<T>({
    required String label,
    required T value,
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
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.blueColor),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(children: [
          // ── fixed header ───────────────────────────────────
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
                      color: AppColors.blueColor.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Row(children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Medication Reports',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                            '${patients.length} patients · ${events.length} medication records',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ]),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.blueColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isGenerating ? null : _generatePdf,
                  icon: isGenerating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.blue))
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(isGenerating ? '...' : 'Export'),
                ),
              ]),
            ),
          ),

          // ── scrollable body ────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(children: [
                  // stats row
                  Row(children: [
                    _statsCard(
                      title: 'Total Patients',
                      value: '${patients.length}',
                      color: AppColors.blueColor,
                      icon: Icons.people_outline,
                    ),
                    const SizedBox(width: 10),
                    _statsCard(
                      title: 'High Risk',
                      value: '$highCount',
                      color: const Color(0xFFE74C3C),
                      icon: Icons.priority_high_rounded,
                    ),
                    const SizedBox(width: 10),
                    _statsCard(
                      title: 'Medium Risk',
                      value: '$mediumCount',
                      color: const Color(0xFFF39C12),
                      icon: Icons.warning_amber_rounded,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _buildFilters(),
                  const SizedBox(height: 16),

                  _buildAdherenceChart(),
                  const SizedBox(height: 16),

                  _buildPieChart(),
                  const SizedBox(height: 16),

                  // event log
                  _softCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                              'Medication Event Log', Icons.list_alt_rounded),
                          const SizedBox(height: 14),
                          if (filteredEvents.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text('No matching events',
                                    style: TextStyle(
                                        color: Colors.grey.shade500)),
                              ),
                            )
                          else
                            ...filteredEvents.map(_buildEventCard),
                        ]),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}