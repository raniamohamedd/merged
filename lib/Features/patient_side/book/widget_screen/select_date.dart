import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class SelectDate extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const SelectDate({super.key, required this.onDateSelected});

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Select Date", style: TextStyle(fontSize: 18)),
            Text(
              "Set Manual",
              style: TextStyle(fontSize: 15, color: AppColors.blueColor),
            ),
          ],
        ),
        const SizedBox(height: 7),
        EasyDateTimeLine(
          initialDate: selectedDate,
          onDateChange: (date) {
            setState(() {
              selectedDate = date;
            });
            widget.onDateSelected(date); // إرسال التاريخ للخارج
          },
          activeColor: AppColors.blueColor,
          dayProps: const EasyDayProps(width: 60, height: 80),
          timeLineProps: const EasyTimeLineProps(separatorPadding: 8),
        ),
      ],
    );
  }
}
