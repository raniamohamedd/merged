import 'package:flutter/material.dart';

class AvailableTime extends StatefulWidget {
  final Function(String) onTimeSelected;

  const AvailableTime({super.key, required this.onTimeSelected});

  @override
  State<AvailableTime> createState() => _AvailableTimeState();
}

class _AvailableTimeState extends State<AvailableTime> {
  int currentPage = 0;
  int currentSubPage = 0;
  String? selectedTime;

  final List<List<String>> timePages = [
    ["12:00 AM","1:00 AM","2:00 AM","3:00 AM","4:00 AM","5:00 AM","6:00 AM","7:00 AM","8:00 AM","9:00 AM","10:00 AM","11:00 AM"],
    ["12:00 PM","1:00 PM","2:00 PM","3:00 PM","4:00 PM","5:00 PM","6:00 PM","7:00 PM","8:00 PM","9:00 PM","10:00 PM","11:00 PM"],
  ];

  void selectTime(String time) {
    setState(() {
      selectedTime = time;
    });
    widget.onTimeSelected(time); // إرسال الوقت للخارج
  }

  void nextPage() {
    setState(() {
      if (currentSubPage == 1) {
        currentPage = (currentPage + 1) % timePages.length;
        currentSubPage = 0;
      } else {
        currentSubPage = 1;
      }
    });
  }

  void previousPage() {
    setState(() {
      if (currentSubPage == 0) {
        currentPage = (currentPage - 1 + timePages.length) % timePages.length;
        currentSubPage = 1;
      } else {
        currentSubPage = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allTimes = timePages[currentPage];
    final currentTimes = allTimes.sublist(
      currentSubPage * 6,
      (currentSubPage + 1) * 6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available time", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: previousPage, icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
            Text("${currentPage == 0 ? "Morning" : "Evening"} - Part ${currentSubPage + 1}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(onPressed: nextPage, icon: const Icon(Icons.arrow_forward_ios, size: 20)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: currentTimes.map((time) {
            return SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 24,
              child: GestureDetector(
                onTap: () => selectTime(time),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedTime == time ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(time)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
