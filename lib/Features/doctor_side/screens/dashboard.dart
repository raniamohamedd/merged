import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/notification_screen.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/setting_pagedoc.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/patient_page.dart';

// ─────────────────────────────────────────────
// Model بسيط للإحصائيات
// ─────────────────────────────────────────────
class _DashboardStats {
  final int totalPatients;
  final int stableCount;
  final int monitoringCount;
  final int criticalCount;
  final int emergencyAlerts;
  final double avgAdherence;
  final List<Patient> patients;

  _DashboardStats({
    required this.totalPatients,
    required this.stableCount,
    required this.monitoringCount,
    required this.criticalCount,
    required this.emergencyAlerts,
    required this.avgAdherence,
    required this.patients,
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

  // بيانات ثابتة للرسومات البيانية (يمكن ربطها بـ API لاحقاً)
  final List<Map<String, dynamic>> _dosesData = const [
    {"day": "Mon", "scheduled": 45, "taken": 42},
    {"day": "Tue", "scheduled": 48, "taken": 46},
    {"day": "Wed", "scheduled": 50, "taken": 44},
    {"day": "Thu", "scheduled": 47, "taken": 45},
    {"day": "Fri", "scheduled": 52, "taken": 48},
    {"day": "Sat", "scheduled": 40, "taken": 38},
    {"day": "Sun", "scheduled": 38, "taken": 36},
  ];

  final List<Map<String, dynamic>> _medicationCategories = const [
    {"name": "Diabetes", "value": 35, "color": Colors.lightBlue},
    {"name": "Cardiovascular", "value": 28, "color": Colors.blueAccent},
    {"name": "Pain Relief", "value": 20, "color": Colors.lightGreen},
    {"name": "Antibiotics", "value": 17, "color": Colors.orangeAccent},
  ];

  // ─── تحميل البيانات الحقيقية ───────────────
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ① جلب قائمة المرضى من الـ API
      final response = await ApiService.getPatients();
      final List rawData = response['data'] ?? [];
      final patients = rawData.map((e) => Patient.fromJson(e)).toList();

      // ② جلب الـ SOS (Emergency Alerts)
      int emergencyCount = 0;
      try {
        final sosList = await ApiService.getSos();
        emergencyCount = sosList
            .where((e) => e['isResolved'] == false)
            .length;
      } catch (_) {
        // لو فشل الـ SOS مش هيوقف الباقي
      }

      // ③ حساب الإحصائيات محلياً من بيانات المرضى
      final stable = patients.where((p) => p.status == 'stable').length;
      final monitoring = patients.where((p) => p.status == 'monitoring').length;
      final critical = patients.where((p) => p.status == 'critical').length;

      // متوسط الـ adherence (لو مش موجود في الـ API نحطه 0)
      double avgAdherence = 0;
      if (patients.isNotEmpty) {
        // يمكن ربطها بحقل حقيقي لو موجود
        avgAdherence = 87.0;
      }

      setState(() {
        _stats = _DashboardStats(
          totalPatients: patients.length,
          stableCount: stable,
          monitoringCount: monitoring,
          criticalCount: critical,
          emergencyAlerts: emergencyCount,
          avgAdherence: avgAdherence,
          patients: patients,
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

  // ─── Helpers ────────────────────────────────
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

  Widget _sectionTitle({required String title, required IconData icon}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.blueColor.withOpacity(.10),
          child: Icon(icon, color: AppColors.blueColor, size: 18),
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

  // ─── KPI Card ────────────────────────────────
  Widget _kpiCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.12),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Adherence Bar Chart ─────────────────────
  Widget _buildAdherenceChart() {
    if (_stats == null) return const SizedBox.shrink();

    // نبني بيانات الـ chart من المرضى الحقيقيين
    final patients = _stats!.patients.take(6).toList();

    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Patient Status Overview",
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 8),
          Text(
            "Number of patients by status",
            style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: (_stats!.totalPatients > 0
                        ? _stats!.totalPatients.toDouble()
                        : 10) *
                    1.3,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: _stats!.totalPatients > 0
                      ? (_stats!.totalPatients / 4).ceilToDouble()
                      : 2,
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
                            child: Text(
                              labels[idx],
                              style: const TextStyle(fontSize: 11),
                            ),
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
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _stats!.stableCount.toDouble(),
                        width: 30,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _stats!.monitoringCount.toDouble(),
                        width: 30,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: _stats!.criticalCount.toDouble(),
                        width: 30,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(Colors.green, "Stable (${_stats!.stableCount})"),
              const SizedBox(width: 16),
              _legendItem(
                  Colors.orange, "Monitoring (${_stats!.monitoringCount})"),
              const SizedBox(width: 16),
              _legendItem(Colors.red, "Critical (${_stats!.criticalCount})"),
            ],
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
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // ─── Pie Chart ───────────────────────────────
  Widget _buildPieChartCard() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Medication Categories",
            icon: Icons.pie_chart_outline_rounded,
          ),
          const SizedBox(height: 8),
          Text(
            "Distribution of medication types",
            style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13),
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
                      sections: _medicationCategories.map((item) {
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
                  children: _medicationCategories.map((item) {
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

  // ─── Doses Line Chart ────────────────────────
  Widget _buildDosesChart() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Scheduled vs Taken Doses",
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 8),
          Text(
            "Weekly comparison",
            style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _dosesData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                              e.key.toDouble(),
                              e.value["scheduled"].toDouble(),
                            ))
                        .toList(),
                    isCurved: true,
                    color: Colors.grey.withOpacity(0.5),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: _dosesData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                              e.key.toDouble(),
                              e.value["taken"].toDouble(),
                            ))
                        .toList(),
                    isCurved: true,
                    color: AppColors.blueColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < _dosesData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _dosesData[idx]["day"],
                              style: const TextStyle(fontSize: 10),
                            ),
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
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 10,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE5E7EB),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent Patients List ────────────────────
  Widget _buildRecentPatients() {
    if (_stats == null || _stats!.patients.isEmpty) return const SizedBox();

    final recent = _stats!.patients.take(4).toList();

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
            title: "Recent Patients",
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
                      backgroundColor:
                          AppColors.blueColor.withOpacity(.12),
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
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Age ${p.age} • ${p.medicationCount} meds",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            statusColor(p.status).withOpacity(.15),
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

  // ─── Main Build ──────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 650;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ثابت ──────────────────────
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
                        // زر رفرش
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

            // ── Body قابل للتمرير ─────────────────
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
                              Text(
                                "Failed to load data",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade600),
                              ),
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
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            child: Column(
                              children: [
                                // ── KPI Cards 2×2 ─────────────────
                                GridView.count(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  mainAxisExtent: 110,
                                  children: [
                                    _kpiCard(
                                      icon: Icons.people,
                                      label: "Total Patients",
                                      value: _stats!.totalPatients
                                          .toString(),
                                      color: AppColors.blueColor,
                                    ),
                                    _kpiCard(
                                      icon: Icons.favorite_border,
                                      label: "Stable Patients",
                                      value: _stats!.stableCount
                                          .toString(),
                                      color: Colors.green,
                                    ),
                                    _kpiCard(
                                      icon:
                                          Icons.warning_amber_rounded,
                                      label: "Emergency Alerts",
                                      value: _stats!.emergencyAlerts
                                          .toString(),
                                      color: Colors.red,
                                    ),
                                    _kpiCard(
                                      icon: Icons.monitor_heart,
                                      label: "Monitoring",
                                      value: _stats!.monitoringCount
                                          .toString(),
                                      color: Colors.orange,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // ── Charts ────────────────────────
                                if (isMobile) ...[
                                  _buildAdherenceChart(),
                                  const SizedBox(height: 16),
                                  _buildRecentPatients(),
                                  const SizedBox(height: 16),
                                  _buildPieChartCard(),
                                  const SizedBox(height: 16),
                                  _buildDosesChart(),
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
}