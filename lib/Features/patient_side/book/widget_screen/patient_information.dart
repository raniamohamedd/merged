import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class PatientInformation extends StatefulWidget {
  final Function(bool)? onSelectionChanged;
  const PatientInformation({super.key, this.onSelectionChanged});

  @override
  State<PatientInformation> createState() => _PatientInformationState();
}

class _PatientInformationState extends State<PatientInformation> {
  bool isSelectedYou = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Patient Information", style: TextStyle(fontSize: 20, color: AppColors.blueColor)),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildOption("You", true),
            const SizedBox(width: 15),
            buildOption("Someone Else", false),
          ],
        ),
      ],
    );
  }

  Widget buildOption(String title, bool value) {
    final bool selected = (isSelectedYou == value);
    return InkWell(
      onTap: () {
        setState(() {
          isSelectedYou = value;
        });
        widget.onSelectionChanged?.call(value);
      },
      child: Container(
        height: 39,
        width: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.redColor),
          color: selected ? AppColors.redColor : AppColors.whiteColor,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.whiteColor : AppColors.blackColor,
            ),
          ),
        ),
      ),
    );
  }
}
