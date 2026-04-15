import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/notification_screen.dart';
import 'package:flutter_application_2/Features/doctor_side/screens/setting_pagedoc.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class DoctorDashboard extends StatelessWidget {
  DoctorDashboard({super.key});

  final List<Map<String, dynamic>> kpiData = [
    {
      "icon": Icons.people,
      "label": "Total Patients",
      "value": "247",
      "color": AppColors.blueColor,
    },
    {
      "icon": Icons.percent,
      "label": "Avg Adherence Rate",
      "value": "87%",
      "color": AppColors.blueColor,
    },
    {
      "icon": Icons.warning_amber_rounded,
      "label": "Emergency Alerts",
      "value": "3",
      "color": AppColors.blueColor,
    },
    {
      "icon": Icons.description_outlined,
      "label": "Pending Reports",
      "value": "12",
      "color": AppColors.blueColor,
    },
  ];

  final List<Map<String, dynamic>> adherenceData = const [
    {"patient": "John D.", "adherence": 92},
    {"patient": "Mary S.", "adherence": 78},
    {"patient": "Robert K.", "adherence": 95},
    {"patient": "Lisa M.", "adherence": 85},
    {"patient": "James W.", "adherence": 70},
    {"patient": "Emma R.", "adherence": 88},
  ];

  final List<Map<String, dynamic>> dosesData = const [
    {"day": "Mon", "scheduled": 45, "taken": 42},
    {"day": "Tue", "scheduled": 48, "taken": 46},
    {"day": "Wed", "scheduled": 50, "taken": 44},
    {"day": "Thu", "scheduled": 47, "taken": 45},
    {"day": "Fri", "scheduled": 52, "taken": 48},
    {"day": "Sat", "scheduled": 40, "taken": 38},
    {"day": "Sun", "scheduled": 38, "taken": 36},
  ];

  final List<Map<String, dynamic>> medicationCategories = const [
    {"name": "Diabetes", "value": 35, "color": Colors.lightBlue},
    {"name": "Cardiovascular", "value": 28, "color": Colors.blueAccent},
    {"name": "Pain Relief", "value": 20, "color": Colors.lightGreen},
    {"name": "Antibiotics", "value": 17, "color": Colors.orangeAccent},
  ];

  final List<Map<String, dynamic>> notifications = const [
    {
      "icon": Icons.error_outline,
      "text": "SOS alert by John Doe",
      "color": Colors.redAccent,
      "time": "5 min ago",
    },
    {
      "icon": Icons.timeline_outlined,
      "text": "New symptom reported by Mary S.",
      "color": Colors.orangeAccent,
      "time": "15 min ago",
    },
    {
      "icon": Icons.notifications_none_rounded,
      "text": "Missed dose - Robert K.",
      "color": Colors.amber,
      "time": "1h ago",
    },
    {
      "icon": Icons.chat_bubble_outline_rounded,
      "text": "New message from Lisa M.",
      "color": Colors.lightBlue,
      "time": "2h ago",
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 650;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Column(
          children: [
            /// Header ثابت
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
              child: 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 16,
                ),
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
                            "Welcome Dr. Sarah Mitchell",
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
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                size: 28,
                                color: Colors.white,
                              ),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.blueColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "3",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                            color: Colors.white,
                          ),
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
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
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

            /// باقي الصفحة scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: kpiData.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 120,
                      ),
                      itemBuilder: (context, index) {
                        final kpi = kpiData[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.blueColor.withOpacity(0.9),
                                AppColors.blueColor.withOpacity(0.55),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blueColor.withOpacity(.12),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        kpi["label"],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        kpi["value"],
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
                                  backgroundColor:
                                      Colors.white.withOpacity(0.25),
                                  child: Icon(
                                    kpi["icon"] as IconData,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    if (isMobile) ...[
                      buildAdherenceChart(),
                      const SizedBox(height: 16),
                      buildPieChartCard(),
                      const SizedBox(height: 16),
                      buildDosesChart(),
                      const SizedBox(height: 16),
                      buildNotifications(),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                buildAdherenceChart(),
                                const SizedBox(height: 16),
                                buildDosesChart(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                buildPieChartCard(),
                                const SizedBox(height: 16),
                                buildNotifications(),
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
          ],
        ),
      ),
    );
  }

  Widget buildAdherenceChart() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Daily Medication Adherence",
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 8),
          const Text(
            "Adherence rate by patient",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE5E7EB),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < adherenceData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              adherenceData[idx]["patient"],
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
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  adherenceData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: adherenceData[index]["adherence"].toDouble(),
                        width: 16,
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blueColor,
                            AppColors.blueColor.withOpacity(.60),
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

  Widget buildDosesChart() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Scheduled vs Taken Doses",
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 8),
          const Text(
            "Weekly comparison of scheduled and taken doses",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: dosesData
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value["scheduled"].toDouble(),
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: Colors.grey.withOpacity(0.5),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: dosesData
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value["taken"].toDouble(),
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: AppColors.blueColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < dosesData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dosesData[idx]["day"],
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

  Widget buildNotifications() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: "Recent Notifications",
            icon: Icons.notifications_none_rounded,
          ),
          const SizedBox(height: 14),
          Column(
            children: notifications
                .map(
                  (n) => Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: (n["color"] as Color).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: (n["color"] as Color).withOpacity(0.20),
                          child: Icon(
                            n["icon"] as IconData,
                            size: 18,
                            color: n["color"] as Color,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            n["text"],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          n["time"],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}