import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _reportData;

  Map<String, dynamic>? _selectedPatient;

  String _statusFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadReport();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      _animCtrl.reset();
      final data = await ApiService.getDoctorReport();
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
      _animCtrl.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return const Color(0xFFE53935);
      case 'moderate':
        return const Color(0xFFF57C00);
      case 'stable':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return Icons.emergency_rounded;
      case 'moderate':
        return Icons.warning_amber_rounded;
      case 'stable':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _warningColor(String level) {
    switch (level.toLowerCase()) {
      case 'severe':
        return const Color(0xFFE53935);
      case 'moderate':
        return const Color(0xFFF57C00);
      case 'mild':
        return const Color(0xFFF9A825);
      case 'caution':
        return const Color(0xFFFF8F00);
      case 'safe':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  String _calcAge(String? dob) {
    if (dob == null) return '—';
    try {
      final birth = DateTime.parse(dob);
      final age = DateTime.now().difference(birth).inDays ~/ 365;
      return '$age y';
    } catch (_) {
      return '—';
    }
  }

  List<Map<String, dynamic>> get _allPatients {
    return ((_reportData?['data'] as List?) ?? []).cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> get _filteredPatients {
    return _allPatients.where((p) {
      final status =
          (p['stats'] as Map<String, dynamic>?)?['healthStatus']?.toString() ??
              '';
      final name = (p['patientInfo'] as Map<String, dynamic>?)?['fullName']
              ?.toString()
              .toLowerCase() ??
          '';
      final statusOk =
          _statusFilter == 'all' || status.toLowerCase() == _statusFilter;
      final searchOk =
          _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());
      return statusOk && searchOk;
    }).toList();
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: _isLoading
          ? _buildLoader()
          : _error != null
              ? _buildError()
              : _selectedPatient != null
                  ? _buildPatientDetail(_selectedPatient!)
                  : _buildMainReport(),
    );
  }

  // ── Loader ───────────────────────────────────────────────────────────────────
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.blueColor),
          const SizedBox(height: 16),
          const Text('Loading report…',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.red, size: 54),
            const SizedBox(height: 16),
            const Text('Failed to load report',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label:
                  const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Report ──────────────────────────────────────────────────────────────
  Widget _buildMainReport() {
    final summary =
        (_reportData!['summary'] as Map<String, dynamic>?) ?? {};

    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        onRefresh: _loadReport,
        color: AppColors.blueColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 40, 4, 0),
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
                        child: const Icon(Icons.book,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doctor Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sorted by most recent first',
                              style:
                                  TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Summary Cards
              _buildSummaryGrid(summary),
              const SizedBox(height: 20),

              // ── Charts stacked vertically ──
              _buildAllPatientsStatusChart(summary),
              const SizedBox(height: 14),
              _buildAllPatientsMissedDosesChart(),
              const SizedBox(height: 20),

              // Filters + Search
              _buildFiltersBar(),
              const SizedBox(height: 12),

              // Patients List
              _buildPatientsHeader(),
              const SizedBox(height: 10),
              ..._buildFilteredList(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary Grid ─────────────────────────────────────────────────────────────
  Widget _buildSummaryGrid(Map<String, dynamic> s) {
    final items = [
      {
        'label': 'Total',
        'value': '${s['totalPatients'] ?? 0}',
        'icon': Icons.people_alt_rounded,
        'color': AppColors.blueColor,
      },
      {
        'label': 'Critical',
        'value': '${s['criticalPatients'] ?? 0}',
        'icon': Icons.emergency_rounded,
        'color': const Color(0xFFE53935),
      },
      {
        'label': 'Moderate',
        'value': '${s['moderatePatients'] ?? 0}',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFF57C00),
      },
      {
        'label': 'Stable',
        'value': '${s['stablePatients'] ?? 0}',
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFF2E7D32),
      },
      {
        'label': 'Active Meds',
        'value': '${s['totalActiveMedications'] ?? 0}',
        'icon': Icons.medication_rounded,
        'color': const Color(0xFF7B1FA2),
      },
      {
        'label': 'Warn Meds',
        'value': '${s['patientsWithWarningMeds'] ?? 0}',
        'icon': Icons.report_problem_rounded,
        'color': const Color(0xFFFF8F00),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.05,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(item['value'] as String,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 2),
              Text(item['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  // ── All Patients Status Donut Chart (full width) ──────────────────────────────
  Widget _buildAllPatientsStatusChart(Map<String, dynamic> s) {
    final critical = (s['criticalPatients'] ?? 0) as int;
    final moderate = (s['moderatePatients'] ?? 0) as int;
    final stable = (s['stablePatients'] ?? 0) as int;
    final total = critical + moderate + stable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pie_chart_rounded,
                    color: AppColors.blueColor, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Patient Status Overview',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          total == 0
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child:
                        Text('No data', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : Row(
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          sections: [
                            if (critical > 0)
                              PieChartSectionData(
                                value: critical.toDouble(),
                                color: const Color(0xFFE53935),
                                title:
                                    '${(critical / total * 100).round()}%',
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                radius: 52,
                              ),
                            if (moderate > 0)
                              PieChartSectionData(
                                value: moderate.toDouble(),
                                color: const Color(0xFFF57C00),
                                title:
                                    '${(moderate / total * 100).round()}%',
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                radius: 52,
                              ),
                            if (stable > 0)
                              PieChartSectionData(
                                value: stable.toDouble(),
                                color: const Color(0xFF2E7D32),
                                title:
                                    '${(stable / total * 100).round()}%',
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                radius: 52,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendRow(const Color(0xFFE53935), 'Critical',
                              critical, total),
                          const SizedBox(height: 12),
                          _legendRow(const Color(0xFFF57C00), 'Moderate',
                              moderate, total),
                          const SizedBox(height: 12),
                          _legendRow(
                              const Color(0xFF2E7D32), 'Stable', stable, total),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade200),
                          const SizedBox(height: 8),
                          Text('Total: $total patients',
                              style: TextStyle(
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label, int count, int total) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ),
        Text('$count',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        const SizedBox(width: 4),
        Text('($pct%)',
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  // ── Taken vs Missed Grouped Bar Chart ────────────────────────────────────────
  Widget _buildAllPatientsMissedDosesChart() {
    final patients = _allPatients;
    if (patients.isEmpty) return const SizedBox.shrink();

    // taken = totalMedications - missedDoses  (أقرب تقريب متاح من الـ API)
    final takenData = patients.map((p) {
      final stats = p['stats'] as Map<String, dynamic>? ?? {};
      final total = (stats['totalMedications'] ?? 0) as int;
      final missed = (stats['missedDoses'] ?? 0) as int;
      return (total - missed).clamp(0, total);
    }).toList();

    final missedData = patients.map((p) {
      final stats = p['stats'] as Map<String, dynamic>? ?? {};
      return (stats['missedDoses'] ?? 0) as int;
    }).toList();

    final patientNames = patients
        .map((p) =>
            (p['patientInfo'] as Map<String, dynamic>?)?['fullName']
                ?.toString()
                .split(' ')
                .first ??
            '?')
        .toList();

    final allValues = [...takenData, ...missedData];
    final maxY = allValues.isEmpty
        ? 5.0
        : (allValues.reduce((a, b) => a > b ? a : b) + 1).toDouble();

    // عرض ديناميكي — كل مريض عنده عمودين فالعرض أكبر
    const double barWidth = 14;
    const double groupSpace = 10;
    final double chartWidth = patients.length > 4
        ? patients.length * (barWidth * 2 + groupSpace + 18)
        : double.infinity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + legend في نفس الصف
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart_rounded,
                    color: AppColors.blueColor, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Taken vs Missed — All Patients',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            children: [
              _legendDot(const Color(0xFF2E7D32), 'Taken'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFE53935), 'Missed'),
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
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.grey.shade100,
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
                            if (idx < 0 || idx >= patientNames.length) {
                              return const SizedBox.shrink();
                            }
                            final name = patientNames[idx];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                name.length > 6
                                    ? name.substring(0, 6)
                                    : name,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Grouped bars: عمود أخضر (taken) + عمود أحمر (missed)
                    barGroups: List.generate(patients.length, (i) {
                      final taken = takenData[i];
                      final missed = missedData[i];
                      return BarChartGroupData(
                        x: i,
                        barsSpace: 4,
                        barRods: [
                          // ✅ العمود الأخضر — taken
                          BarChartRodData(
                            toY: taken > 0 ? taken.toDouble() : 0.2,
                            color: const Color(0xFF2E7D32),
                            width: barWidth,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          // ✅ العمود الأحمر — missed
                          BarChartRodData(
                            toY: missed > 0 ? missed.toDouble() : 0.2,
                            color: missed > 0
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
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label = rodIndex == 0 ? 'Taken' : 'Missed';
                          final val = rodIndex == 0
                              ? takenData[group.x]
                              : missedData[group.x];
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

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ── Filters Bar ──────────────────────────────────────────────────────────────
  Widget _buildFiltersBar() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'critical', 'label': 'Critical'},
      {'key': 'moderate', 'label': 'Moderate'},
      {'key': 'stable', 'label': 'Stable'},
    ];

    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search patient…',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon:
                const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: Colors.grey, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: filters.map((f) {
              final isActive = _statusFilter == f['key'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _statusFilter = f['key'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppColors.blueColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                                color: AppColors.blueColor.withOpacity(.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Text(
                    f['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Patients Header ──────────────────────────────────────────────────────────
  Widget _buildPatientsHeader() {
    final count = _filteredPatients.length;
    return Row(
      children: [
        const Text('Patients',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blueColor.withOpacity(.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count result${count != 1 ? 's' : ''}',
            style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w600,
                fontSize: 12),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFilteredList() {
    final list = _filteredPatients;
    if (list.isEmpty) {
      return [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 52, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No patients found',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 15)),
            ],
          ),
        ),
      ];
    }
    return list.map((p) => _buildPatientCard(p)).toList();
  }

  // ── Patient Card ─────────────────────────────────────────────────────────────
  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final info = patient['patientInfo'] as Map<String, dynamic>;
    final stats = patient['stats'] as Map<String, dynamic>? ?? {};
    final status = stats['healthStatus']?.toString() ?? 'unknown';
    final imageUrl = info['image']?['secure_url'] as String?;
    final name = info['fullName']?.toString() ?? 'Unknown';
    final dob = info['DOB']?.toString();
    final gender = info['gender']?.toString() ?? '';
    final totalMeds = stats['totalMedications'] ?? 0;
    final missedDoses = stats['missedDoses'] ?? 0;
    final warningMeds = stats['warningMedications'] ?? 0;
    final chronicDiseases = stats['chronicDiseases'] ?? 0;
    final statusColor = _statusColor(status);

    return GestureDetector(
      onTap: () => setState(() => _selectedPatient = patient),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: statusColor.withOpacity(.08),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: statusColor.withOpacity(.12),
                    backgroundImage:
                        imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(
                          '${_calcAge(dob)} · ${gender.isNotEmpty ? gender[0].toUpperCase() + gender.substring(1) : '—'} · ${patient['bloodType'] ?? '—'}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: statusColor.withOpacity(.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(status),
                            color: statusColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _miniStat(Icons.medication_rounded, '$totalMeds meds',
                        AppColors.blueColor),
                    _miniStat(Icons.warning_amber_rounded,
                        '$warningMeds warn', const Color(0xFFF57C00)),
                    _miniStat(Icons.local_hospital_rounded,
                        '$chronicDiseases chr', const Color(0xFF7B1FA2)),
                    _miniStat(
                        Icons.cancel_outlined,
                        '$missedDoses miss',
                        missedDoses > 0
                            ? Colors.red
                            : Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 3),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Patient Detail ───────────────────────────────────────────────────────────
  Widget _buildPatientDetail(Map<String, dynamic> patient) {
    final info = patient['patientInfo'] as Map<String, dynamic>;
    final stats = patient['stats'] as Map<String, dynamic>? ?? {};
    final activeMeds = (patient['activeMedications'] as List?) ?? [];
    final chronicDiseases = (patient['chronicDiseases'] as List?) ?? [];
    final medStats = (patient['medicationStats'] as List?) ?? [];
    final imageUrl = info['image']?['secure_url'] as String?;
    final name = info['fullName']?.toString() ?? 'Unknown';
    final status = stats['healthStatus']?.toString() ?? 'unknown';
    final statusColor = _statusColor(status);

    final missedMap = <String, int>{};
    for (final ms in medStats) {
      final id = ms['medicineId']?.toString() ?? '';
      missedMap[id] = (ms['missedDoses'] as num?)?.toInt() ?? 0;
    }

    final warnCounts = <String, int>{
      'safe': 0,
      'mild': 0,
      'moderate': 0,
      'caution': 0,
      'severe': 0,
    };
    for (final m in activeMeds) {
      final lvl =
          (m as Map<String, dynamic>)['warningLevel']?.toString() ?? 'safe';
      warnCounts[lvl] = (warnCounts[lvl] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button header
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedPatient = null),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Profile header
          _buildDetailHeader(
              info, name, imageUrl, status, statusColor, patient),
          const SizedBox(height: 14),

          // ── Patient-specific charts stacked vertically ──
          _buildPatientStatusChart(stats),
          const SizedBox(height: 14),
          _buildDetailWarningLevelsChart(warnCounts),
          const SizedBox(height: 14),
          _buildDetailMissedDosesChart(activeMeds, missedMap),
          const SizedBox(height: 14),

          // Medical info
          _buildMedicalInfo(patient),
          const SizedBox(height: 14),

          // Chronic diseases
          if (chronicDiseases.isNotEmpty) ...[
            _sectionTitle('Chronic Diseases'),
            const SizedBox(height: 8),
            ...chronicDiseases
                .map((d) => _buildDiseaseCard(d as Map<String, dynamic>)),
            const SizedBox(height: 14),
          ],

          // Active medications
          Row(
            children: [
              _sectionTitle('Active Medications'),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${activeMeds.length}',
                    style: TextStyle(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (activeMeds.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.medication_outlined,
                        size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('No active medications',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            ...activeMeds.map((med) {
              final m = med as Map<String, dynamic>;
              final medId =
                  m['_id']?.toString() ?? m['medicineId']?.toString() ?? '';
              final missed = missedMap[medId] ?? 0;
              return _buildMedCard(m, missed);
            }),
        ],
      ),
    );
  }

  // ── Patient Status Summary Chart (detail page) ────────────────────────────────
  Widget _buildPatientStatusChart(Map<String, dynamic> stats) {
    final status = stats['healthStatus']?.toString() ?? 'unknown';
    final statusColor = _statusColor(status);
    final totalMeds = (stats['totalMedications'] ?? 0) as int;
    final missedDoses = (stats['missedDoses'] ?? 0) as int;
    final warningMeds = (stats['warningMedications'] ?? 0) as int;
    final chronicDiseases = (stats['chronicDiseases'] ?? 0) as int;

    final statItems = [
      {
        'label': 'Total Meds',
        'value': totalMeds,
        'icon': Icons.medication_rounded,
        'color': AppColors.blueColor,
      },
      {
        'label': 'Warning Meds',
        'value': warningMeds,
        'icon': Icons.report_problem_rounded,
        'color': const Color(0xFFFF8F00),
      },
      {
        'label': 'Chronic',
        'value': chronicDiseases,
        'icon': Icons.local_hospital_rounded,
        'color': const Color(0xFF7B1FA2),
      },
      {
        'label': 'Missed',
        'value': missedDoses,
        'icon': Icons.cancel_outlined,
        'color': missedDoses > 0
            ? const Color(0xFFE53935)
            : const Color(0xFF2E7D32),
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: statusColor.withOpacity(.07),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_statusIcon(status), color: statusColor, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Patient Overview',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(.3)),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: statItems.map((item) {
              final color = item['color'] as Color;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(.15)),
                  ),
                  child: Column(
                    children: [
                      Icon(item['icon'] as IconData, color: color, size: 20),
                      const SizedBox(height: 6),
                      Text('${item['value']}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      const SizedBox(height: 3),
                      Text(item['label'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Patient Warning Levels Chart (detail page) ────────────────────────────────
  Widget _buildDetailWarningLevelsChart(Map<String, int> warnCounts) {
    final warnLabels = ['Safe', 'Mild', 'Moderate', 'Caution', 'Severe'];
    final warnColors = [
      const Color(0xFF43A047),
      const Color(0xFFF9A825),
      const Color(0xFFF57C00),
      const Color(0xFFFF8F00),
      const Color(0xFFE53935),
    ];
    final warnKeys = ['safe', 'mild', 'moderate', 'caution', 'severe'];
    final warnValues = warnKeys.map((k) => warnCounts[k] ?? 0).toList();
    final maxWarn =
        warnValues.isEmpty ? 1 : warnValues.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.report_problem_rounded,
                    color: Color(0xFFFF8F00), size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Warning Levels',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: (maxWarn + 1).toDouble(),
                groupsSpace: 12,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
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
                      reservedSize: 24,
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
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= warnLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            warnLabels[idx].length > 4
                                ? warnLabels[idx].substring(0, 4)
                                : warnLabels[idx],
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(warnValues.length, (i) {
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: warnValues[i] > 0
                          ? warnValues[i].toDouble()
                          : 0.2,
                      color: warnColors[i],
                      width: 28,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Patient Missed Doses per Medication Chart (detail page) ───────────────────
  Widget _buildDetailMissedDosesChart(
      List activeMeds, Map<String, int> missedMap) {
    if (activeMeds.isEmpty) return const SizedBox.shrink();

    final missedValues = activeMeds.map((m) {
      final med = m as Map<String, dynamic>;
      final id =
          med['_id']?.toString() ?? med['medicineId']?.toString() ?? '';
      return missedMap[id] ?? 0;
    }).toList();

    final medNames = activeMeds.map((m) {
      final name =
          (m as Map<String, dynamic>)['medicationName']?.toString() ?? '?';
      return name.length > 7 ? name.substring(0, 7) : name;
    }).toList();

    final maxMissed =
        missedValues.isEmpty ? 1 : missedValues.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: Color(0xFFE53935), size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Missed Doses per Medication',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: (maxMissed + 1).toDouble(),
                groupsSpace: 12,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
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
                      reservedSize: 24,
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
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= medNames.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(medNames[idx],
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(missedValues.length, (i) {
                  final v = missedValues[i];
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: v > 0 ? v.toDouble() : 0.2,
                      color: v > 0
                          ? const Color(0xFFE53935)
                          : AppColors.blueColor.withOpacity(.5),
                      width: 22,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader(
    Map<String, dynamic> info,
    String name,
    String? imageUrl,
    String status,
    Color statusColor,
    Map<String, dynamic> patient,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: statusColor.withOpacity(.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: statusColor.withOpacity(.12),
            backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 26),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 3),
                Text(info['email']?.toString() ?? '',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 3),
                Text(
                  '${info['phone'] ?? ''} · ${info['gender'] ?? ''}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon(status), color: statusColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Medical Info ─────────────────────────────────────────────────────────────
  Widget _buildMedicalInfo(Map<String, dynamic> patient) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Medical Info'),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('🩸 ${patient['bloodType'] ?? '—'}',
                  Colors.red.shade50, Colors.red),
              const SizedBox(width: 8),
              _infoChip('📏 ${patient['height'] ?? '—'} cm',
                  Colors.blue.shade50, Colors.blue),
              const SizedBox(width: 8),
              _infoChip('⚖️ ${patient['weight'] ?? '—'} kg',
                  Colors.green.shade50, Colors.green),
            ],
          ),
          if (patient['allergies'] != null &&
              patient['allergies'].toString().toLowerCase() != 'no' &&
              patient['allergies'].toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Allergies: ${patient['allergies']}',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(String label, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87));
  }

  // ── Disease Card ─────────────────────────────────────────────────────────────
  Widget _buildDiseaseCard(Map<String, dynamic> disease) {
    final statusD = disease['status']?.toString() ?? 'unknown';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.03), blurRadius: 6)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7B1FA2).withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: Color(0xFF7B1FA2), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(disease['name']?.toString() ?? '—',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(statusD).withOpacity(.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusD[0].toUpperCase() + statusD.substring(1),
                    style: TextStyle(
                        color: _statusColor(statusD),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (disease['notes'] != null &&
                    disease['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(disease['notes'].toString(),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Medication Card ──────────────────────────────────────────────────────────
  Widget _buildMedCard(Map<String, dynamic> med, int missed) {
    final warnLevel = med['warningLevel']?.toString() ?? 'safe';
    final warnColor = _warningColor(warnLevel);
    final sideEffects = (med['sideEffects'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warnColor.withOpacity(.2)),
        boxShadow: [
          BoxShadow(
              color: warnColor.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: warnColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.medication_rounded,
                    color: warnColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med['medicationName']?.toString() ?? '—',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '${med['dosage']} · ${med['repeat']} · ⏰ ${med['reminderTime']}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: warnColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: warnColor.withOpacity(.4)),
                ),
                child: Text(
                  warnLevel[0].toUpperCase() + warnLevel.substring(1),
                  style: TextStyle(
                      color: warnColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (missed > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_outlined,
                      color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$missed missed dose${missed > 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          if (sideEffects.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: sideEffects.map((se) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(se,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}