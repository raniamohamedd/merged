import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/widget/header.dart';
import 'package:flutter_application_2/core2/constants/colors.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';

class Reportscreen extends StatelessWidget {
  const Reportscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

        backgroundColor: const Color.fromARGB(255, 249, 249, 249),

      // backgroundColor: Colors.white,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text("Health Reports"),
      //   // leading: IconButton(
      //   //   icon: const Icon(Icons.arrow_back),
      //   //   onPressed: () {
      //   //     Navigator.pop(context);
      //   //   },
      //   // ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.language),
      //       onPressed: () {},
      //     )
      //   ],
      // ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
                    SizedBox(height: 20),
  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: 
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 90),
                child: Text(
                  "Health Reports",
                  style:  TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:AppColors.blueColor,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              ],
          ),

          // 🔔 زر الإشعارات
        ],
      ),
    )
 ,  
Padding(
  padding: const EdgeInsets.only(left: 10,top: 2,bottom:10 ),
  child: Align(alignment: Alignment.centerLeft,
  child: Column(children: [
    Text('Health Overview',style: TextStyle(fontWeight: FontWeight.bold),),          // Download button
Text("Last week's data")
 ],)  ),
)  ,     // Download button

Align(
  alignment: Alignment.center,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.download, color: Colors.white), // أيقونة أبيض
    label: const Text(
      "Download Report",
      style: TextStyle(color: Colors.white), // نص أبيض
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor:AppColors.blueColor, // لون الزرار أزرق
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
 textStyle:  TextStyle(
                  // fontSize: 22,
                  // fontWeight: FontWeight.bold,
                  color:AppColors.blueColor,
                ),    ),
    onPressed: () {
      // هنا حط أي كود عند الضغط
    },
  ),
),

            const SizedBox(height: 16),
            // Blood Pressure Chart
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Recent readings (7 days)",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

    AnimatedBloodPressureChart(),
        const SizedBox(height: 12),

        // ===== Legend =====
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
),  const SizedBox(height: 16),
            // Glucose Levels Chart
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Morning Readings (mg/dL)",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 80,
              maxY: 120,

              // ===== Grid =====
              gridData: FlGridData(
                show: true,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
              ),

              // ===== Borders =====
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.transparent),
                  top: BorderSide(color: Colors.transparent),
                ),
              ),

              // ===== Titles =====
              titlesData: FlTitlesData(
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),

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

              // ===== Line =====
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

        const SizedBox(height: 12),

        // ===== Legend =====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(Colors.orange, "Glucose"),
          ],
        ),
      ],
    ),
  ),
),    const SizedBox(height: 16),
            // Medication Adherence
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Adherence Rate",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: 100,

              // ===== Grid =====
              gridData: FlGridData(
                show: true,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  );
                },
              ),

              // ===== Borders =====
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.transparent),
                  top: BorderSide(color: Colors.transparent),
                ),
              ),

              // ===== Titles =====
              titlesData: FlTitlesData(
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),

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

              // ===== Bars =====
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(toY: 100, color: Colors.purple, width: 12)
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: 100, color: Colors.purple, width: 12)
                ]),
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(toY: 75, color: Colors.purple, width: 12)
                ]),
                BarChartGroupData(x: 3, barRods: [
                  BarChartRodData(toY: 100, color: Colors.purple, width: 12)
                ]),
                BarChartGroupData(x: 4, barRods: [
                  BarChartRodData(toY: 100, color: Colors.purple, width: 12)
                ]),
                BarChartGroupData(x: 5, barRods: [
                  BarChartRodData(toY: 100, color: Colors.purple, width: 12)
                ]),
                BarChartGroupData(x: 6, barRods: [
                  BarChartRodData(toY: 100, color: Colors.purple, width: 12)
                ]),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ===== Legend =====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(Colors.purple, "Adherence"),
          ],
        ),
      ],
    ),
  ),
),  const SizedBox(height: 16),
            // Summary Cards
           GridView.count(
  crossAxisCount: 1, // 2 بطاقة في كل صف
  childAspectRatio: 3, // النسبة بين العرض والارتفاع
  shrinkWrap: true,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  physics: const NeverScrollableScrollPhysics(),
  children: [
    summaryCard("Avg Blood Pressure", "120/80 mmHg", "Normal",
        Colors.blue, Colors.green),
    summaryCard("Avg Glucose", "103 mg/dL", "Normal",
        Colors.amber, Colors.green),
    summaryCard("Med Adherence", "96%", "Excellent",
        Colors.purple, Colors.green),
    summaryCard("Weight", "75 kg", "Stable", Colors.blue, Colors.green),
  ],
),
   ],
        ),
      ),
    );
 
  }
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

Widget summaryCard(String title, String value, String status,
      Color valueColor, Color statusColor) {
    return Card(color: Colors.white,
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
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
    extends State<AnimatedBloodPressureChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<FlSpot> systolicSpots = const [
    FlSpot(0, 120),
    FlSpot(1, 118),
    FlSpot(2, 122),
    FlSpot(3, 119),
    FlSpot(4, 121),
    FlSpot(5, 117),
    FlSpot(6, 120),
  ];

  final List<FlSpot> diastolicSpots = const [
    FlSpot(0, 80),
    FlSpot(1, 78),
    FlSpot(2, 82),
    FlSpot(3, 79),
    FlSpot(4, 81),
    FlSpot(5, 77),
    FlSpot(6, 80),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> getLineSpots(List<FlSpot> spots) {
    final t = _controller.value;
    final nSegments = spots.length - 1;
    final totalProgress = t * nSegments;
    final currentSegment = totalProgress.floor().clamp(0, nSegments - 1);
    final segmentT = totalProgress - currentSegment;

    List<FlSpot> visibleSpots = [];

    // نضيف كل النقاط السابقة كاملة
    for (int i = 0; i <= currentSegment; i++) {
      visibleSpots.add(spots[i]);
    }

    // نرسم الخط الحالي segment واحد فقط
    if (currentSegment < nSegments) {
      final start = spots[currentSegment];
      final end = spots[currentSegment + 1];

      final interpolatedX = start.x + (end.x - start.x) * segmentT;
      final interpolatedY = start.y + (end.y - start.y) * segmentT;

      visibleSpots.add(FlSpot(interpolatedX, interpolatedY));
    }

    return visibleSpots;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 140,
              gridData: FlGridData(show: true),
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
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 35,
                    reservedSize: 40,
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
                  spots: getLineSpots(systolicSpots),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: getLineSpots(diastolicSpots),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}