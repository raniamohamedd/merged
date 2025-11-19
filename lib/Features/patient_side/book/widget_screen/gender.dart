import 'package:flutter/material.dart';

class Gender extends StatefulWidget {
  final Function(String)? onGenderChanged; // 🟢 إضافة callback
  const Gender({super.key, this.onGenderChanged});

  @override
  State<Gender> createState() => _GenderState();
}

class _GenderState extends State<Gender> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Radio<String>(
              value: "Male",
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
                // 🟢 تمرير القيمة لصفحة BookAppointment
                widget.onGenderChanged?.call(value!);
              },
            ),
            const Text(
              "Male",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 100),
            Radio<String>(
              value: "Female",
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
                // 🟢 تمرير القيمة لصفحة BookAppointment
                widget.onGenderChanged?.call(value!);
              },
            ),
            const Text(
              "Female",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
