import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/notification_screen.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/setting_pagedoc.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_page.dart';

// ─────────────────────────────────────────────
// Model — إحصائيات الـ Dashboard مربوطة بالـ API
// ─────────────────────────────────────────────
class _DashboardStats {
  final int totalPatients;
  final int stableCount;
  final int monitoringCount;
  final int criticalCount;
  final int emergencyAlerts;
  final int totalMedications;
  final int totalMissed;
  final int totalTaken;
  final int warningMeds;
  final List<Patient> patients;

  // بيانات الـ Taken vs Missed per patient للـ chart
  final List<Map<String, dynamic>> patientsRaw;

  _DashboardStats({
    required this.totalPatients,
    required this.stableCount,
    required this.monitoringCount,
    required this.criticalCount,
    required this.emergencyAlerts,
    required this.totalMedications,
    required this.totalMissed,
    required this.totalTaken,
    required this.warningMeds,
    required this.patients,
    required this.patientsRaw,
  });
}

// ─────────────────────────────────────────────
// Dashboard Widget
// ─────────────────────────────────────────────
class DoctorDashboard extends StatefulWidget {
  DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  _DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ─── تحميل البيانات من getDoctorReport ────────
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ① Report API — بيرجع summary + data (مرضى مع stats)
      final reportResponse = await ApiService.getDoctorReport();
      final summary = (reportResponse['summary'] as Map<String, dynamic>?) ?? {};
      final List rawPatients =
          (reportResponse['data'] as List?) ?? [];

      // ② SOS / Emergency Alerts
      int emergencyCount = 0;
      try {
        final sosList = await ApiService.getSos();
        emergencyCount =
            sosList.where((e) => e['isResolved'] == false).length;
      } catch (_) {}

      // ③ بناء Patient list من الـ report data
      final patients = rawPatients.map((e) {
        final info = e['patientInfo'] as Map<String, dynamic>? ?? {};
        final stats = e['stats'] as Map<String, dynamic>? ?? {};
        final user = {'_id': info['userId'] ?? '', ...info};
        return Patient(
          id: e['patientId']?.toString() ?? '',
          userId: info['userId']?.toString() ?? '',
          name: info['fullName']?.toString() ?? 'Unknown',
          age: info['DOB'] != null
              ? DateTime.now().year - DateTime.parse(info['DOB']).year
              : 0,
          medicationCount: (stats['totalMedications'] ?? 0) as int,
          status: stats['healthStatus']?.toString() ?? 'stable',
        );
      }).toList();

      // ④ حساب totals من summary أو من بيانات المرضى
      final totalMeds =
          (summary['totalActiveMedications'] ?? 0) as int;
      final warnMeds =
          (summary['patientsWithWarningMeds'] ?? 0) as int;

      // missed و taken محسوبين من كل مريض
      int totalMissed = 0;
      int totalTaken = 0;
      for (final p in rawPatients) {
        final stats = p['stats'] as Map<String, dynamic>? ?? {};
        final missed = (stats['missedDoses'] ?? 0) as int;
        final total = (stats['totalMedications'] ?? 0) as int;
        totalMissed += missed;
        totalTaken += (total - missed).clamp(0, total);
      }

      setState(() {
        _stats = _DashboardStats(
          totalPatients: (summary['totalPatients'] ?? patients.length) as int,
          stableCount: (summary['stablePatients'] ??
              patients.where((p) => p.status == 'stable').length) as int,
          monitoringCount: (summary['moderatePatients'] ??
              patients.where((p) => p.status == 'monitoring').length) as int,
          criticalCount: (summary['criticalPatients'] ??
              patients.where((p) => p.status == 'critical').length) as int,
          emergencyAlerts: emergencyCount,
          totalMedications: totalMeds,
          totalMissed: totalMissed,
          totalTaken: totalTaken,
          warningMeds: warnMeds,
          patients: patients,
          patientsRaw: rawPatients.cast<Map<String, dynamic>>(),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ─── Helpers ─────────────────────────────────
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle({required String title, required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.blueColor.withOpacity(.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.blueColor),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1F2937))),
      ],
    );
  }

  // ─── KPI Card ────────────────────────────────
  Widget _kpiCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.white)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ─── Patient Status Bar Chart (real data) ────
  Widget _buildAdherenceChart() {
    if (_stats == null) return const SizedBox.shrink();

    final stable = _stats!.stableCount;
    final monitoring = _stats!.monitoringCount;
    final critical = _stats!.criticalCount;
    final maxY = [stable, monitoring, critical]
            .reduce((a, b) => a > b ? a : b)
            .toDouble() *
        1.4;

    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Patient Status Overview",
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 6),
          Text("Breakdown by health status",
              style:
                  TextStyle(color: const Color(0xFF6B7280), fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY > 0 ? maxY : 5,
                groupsSpace: 24,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval:
                      maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE5E7EB),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Stable', 'Monitor', 'Critical'];
                        final idx = value.toInt();
                        if (idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[idx],
                                style: const TextStyle(fontSize: 11)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: stable > 0 ? stable.toDouble() : 0.2,
                        width: 36,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: monitoring > 0 ? monitoring.toDouble() : 0.2,
                        width: 36,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.orange),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: critical > 0 ? critical.toDouble() : 0.2,
                        width: 36,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(Colors.green, "Stable ($stable)"),
              const SizedBox(width: 16),
              _legendItem(Colors.orange, "Monitoring ($monitoring)"),
              const SizedBox(width: 16),
              _legendItem(Colors.red, "Critical ($critical)"),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Taken vs Missed Grouped Bar Chart (real) ─
  Widget _buildDosesChart() {
    if (_stats == null) return const SizedBox.shrink();

    final rawList = _stats!.patientsRaw;
    if (rawList.isEmpty) return const SizedBox.shrink();

    // أخذ أول 8 مرضى عشان المساحة
    final display = rawList.take(8).toList();

    final names = display.map((p) {
      final info = p['patientInfo'] as Map<String, dynamic>? ?? {};
      final full = info['fullName']?.toString() ?? '?';
      return full.split(' ').first;
    }).toList();

    final takenList = display.map((p) {
      final stats = p['stats'] as Map<String, dynamic>? ?? {};
      final total = (stats['totalMedications'] ?? 0) as int;
      final missed = (stats['missedDoses'] ?? 0) as int;
      return (total - missed).clamp(0, total);
    }).toList();

    final missedList = display.map((p) {
      final stats = p['stats'] as Map<String, dynamic>? ?? {};
      return (stats['missedDoses'] ?? 0) as int;
    }).toList();

    final allVals = [...takenList, ...missedList];
    final maxY = allVals.isEmpty
        ? 5.0
        : (allVals.reduce((a, b) => a > b ? a : b) + 1).toDouble();

    const double barWidth = 13;
    const double groupSpace = 10;
    final double chartWidth = display.length > 4
        ? display.length * (barWidth * 2 + groupSpace + 18)
        : double.infinity;

    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Taken vs Missed Doses",
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 6),
          Text("Per patient — top ${display.length}",
              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13)),
          const SizedBox(height: 10),
          // Legend
          Row(
            children: [
              _legendItem(const Color(0xFF2E7D32), 'Taken'),
              const SizedBox(width: 16),
              _legendItem(const Color(0xFFE53935), 'Missed'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    groupsSpace: groupSpace,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: Color(0xFFE5E7EB),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, _) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= names.length) {
                              return const SizedBox.shrink();
                            }
                            final name = names[idx];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                name.length > 6 ? name.substring(0, 6) : name,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(display.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: takenList[i] > 0
                                ? takenList[i].toDouble()
                                : 0.2,
                            color: const Color(0xFF2E7D32),
                            width: barWidth,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          BarChartRodData(
                            toY: missedList[i] > 0
                                ? missedList[i].toDouble()
                                : 0.2,
                            color: missedList[i] > 0
                                ? const Color(0xFFE53935)
                                : Colors.grey.shade200,
                            width: barWidth,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                      );
                    }),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, _, rod, rodIndex) {
                          final label = rodIndex == 0 ? 'Taken' : 'Missed';
                          final val = rodIndex == 0
                              ? takenList[group.x]
                              : missedList[group.x];
                          final color = rodIndex == 0
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE53935);
                          return BarTooltipItem(
                            '$label: $val',
                            TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status Distribution Pie (real data) ─────
  Widget _buildPieChartCard() {
    if (_stats == null) return const SizedBox.shrink();

    final stable = _stats!.stableCount;
    final monitoring = _stats!.monitoringCount;
    final critical = _stats!.criticalCount;
    final total = stable + monitoring + critical;

    if (total == 0) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[
      if (stable > 0)
        PieChartSectionData(
          color: Colors.green,
          value: stable.toDouble(),
          title: '${(stable / total * 100).round()}%',
          radius: 58,
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      if (monitoring > 0)
        PieChartSectionData(
          color: Colors.orange,
          value: monitoring.toDouble(),
          title: '${(monitoring / total * 100).round()}%',
          radius: 58,
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      if (critical > 0)
        PieChartSectionData(
          color: Colors.red,
          value: critical.toDouble(),
          title: '${(critical / total * 100).round()}%',
          radius: 58,
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
    ];

    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Status Distribution",
            icon: Icons.pie_chart_outline_rounded,
          ),
          const SizedBox(height: 8),
          Text("Patient health breakdown",
              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,
                      sectionsSpace: 3,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(Colors.green, "Stable ($stable)"),
                    const SizedBox(height: 12),
                    _legendItem(Colors.orange, "Monitor ($monitoring)"),
                    const SizedBox(height: 12),
                    _legendItem(Colors.red, "Critical ($critical)"),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Text("Total: $total",
                        style: TextStyle(
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
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

  // ─── Recent Patients List ─────────────────────
  Widget _buildRecentPatients() {
    if (_stats == null || _stats!.patients.isEmpty) return const SizedBox();

    final recent = _stats!.patients.take(10000000).toList();

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

    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "All Patients",
            icon: Icons.people_outline_rounded,
          ),
          const SizedBox(height: 14),
          ...recent.map((p) => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: statusColor(p.status).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.blueColor.withOpacity(.12),
                      child: Text(
                        p.name.isNotEmpty ? p.name[0] : 'P',
                        style: TextStyle(
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(
                            "Age ${p.age} · ${p.medicationCount} meds",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor(p.status).withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.status[0].toUpperCase() + p.status.substring(1),
                        style: TextStyle(
                          color: statusColor(p.status),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ─── Main Build ───────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 650;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 22, horizontal: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Doctor Dashboard",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Here is your current patient overview.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              size: 26, color: Colors.white),
                          onPressed: _loadDashboardData,
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.notifications_none_rounded,
                              size: 28,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationsPageDoctor(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.person_outline_rounded,
                              size: 28,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              size: 28, color: Colors.white),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Body ────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 12),
                              const Text("Failed to load data",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(_error!,
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Colors.grey.shade600)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadDashboardData,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Retry"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blueColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDashboardData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            child: Column(
                              children: [
                                // ── KPI Cards 2×2 ─────────────────────
                                GridView.count(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  mainAxisExtent: 100,
                                  children: [
                                    _kpiCard(
                                      icon: Icons.people,
                                      label: "Total Patients",
                                      value: _stats!.totalPatients.toString(),
                                      color: AppColors.blueColor,
                                    ),
                                    _kpiCard(
                                      icon: Icons.favorite_border,
                                      label: "Stable Patients",
                                      value: _stats!.stableCount.toString(),
                                      color: Colors.green,
                                    ),
                                    _kpiCard(
                                      icon: Icons.warning_amber_rounded,
                                      label: "Emergency Alerts",
                                      value:
                                          _stats!.emergencyAlerts.toString(),
                                      color: Colors.red,
                                    ),
                                    _kpiCard(
                                      icon: Icons.monitor_heart,
                                      label: "Monitoring",
                                      value:
                                          _stats!.monitoringCount.toString(),
                                      color: Colors.orange,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // ── KPI Row: Meds ──────────────────────
                                Row(
                                  children: [
                                    Expanded(
                                      child: _miniKpi(
                                        icon: Icons.medication_rounded,
                                        label: "Active Meds",
                                        value: _stats!.totalMedications
                                            .toString(),
                                        color: const Color(0xFF7B1FA2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _miniKpi(
                                        icon: Icons.check_circle_rounded,
                                        label: "Taken",
                                        value: _stats!.totalTaken.toString(),
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _miniKpi(
                                        icon: Icons.cancel_rounded,
                                        label: "Missed",
                                        value: _stats!.totalMissed.toString(),
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _miniKpi(
                                        icon: Icons.report_problem_rounded,
                                        label: "Warning",
                                        value: _stats!.warningMeds.toString(),
                                        color: const Color(0xFFFF8F00),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // ── Charts ────────────────────────────
                                if (isMobile) ...[
                                  _buildAdherenceChart(),
                                  const SizedBox(height: 16),
                                  _buildDosesChart(),
                                  const SizedBox(height: 16),
                                  _buildRecentPatients(),
                                  const SizedBox(height: 16),
                                  _buildPieChartCard(),
                                  const SizedBox(height: 16),
                                ] else ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            _buildAdherenceChart(),
                                            const SizedBox(height: 16),
                                            _buildDosesChart(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            _buildRecentPatients(),
                                            const SizedBox(height: 16),
                                            _buildPieChartCard(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniKpi({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.2)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(.08),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

}