import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class AppointmentType extends StatefulWidget {
  final Function(String)? onTypeSelected;
  const AppointmentType({super.key, this.onTypeSelected});

  @override
  State<AppointmentType> createState() => _AppointmentTypeState();
}

class _AppointmentTypeState extends State<AppointmentType> {
  String? appointmentType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Appointment Type",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Icon(Icons.person, color: AppColors.blueColor),
            const SizedBox(width: 5),
            const Text("In Person", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const Spacer(),
            Radio<String>(
              value: "In Person",
              activeColor: AppColors.blueColor,
              groupValue: appointmentType,
              onChanged: (value) {
                setState(() {
                  appointmentType = value;
                });
                widget.onTypeSelected?.call(value!);
              },
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.red),
            const SizedBox(width: 5),
            const Text("Chat", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const Spacer(),
            Radio<String>(
              value: "Chat",
              activeColor: AppColors.blueColor,
              groupValue: appointmentType,
              onChanged: (value) {
                setState(() {
                  appointmentType = value;
                });
                widget.onTypeSelected?.call(value!);
              },
            ),
          ],
        ),
      ],
    );
  }
}
