import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class CustomGenderDropdown extends StatefulWidget {
  const CustomGenderDropdown({super.key, required this.controller});

  final TextEditingController controller; // هنا هنخزن القيمة المختارة

  @override
  State<CustomGenderDropdown> createState() => _CustomGenderDropdownState();
}

class _CustomGenderDropdownState extends State<CustomGenderDropdown> {
  final List<String> genderList = ['Male', 'Female'];
  late String selectedGender;

  @override
  void initState() {
    super.initState();

    selectedGender = widget.controller.text.isNotEmpty
        ? widget.controller.text
        : 'Select Gender';

    widget.controller.text = selectedGender;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.greyColor.withOpacity(0.03),
              border: Border.all(color: AppColors.greyLightColor, width: 1.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: DropdownButtonHideUnderline(
              
              child: DropdownButton<String>(
                
                dropdownColor: AppColors.whiteColor.withOpacity(0.9),

                hint: Text(
                  "  $selectedGender",
                  style: TextStyle(color: AppColors.greyColor),
                ),
                // value: selectedGender,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue),
                items: genderList.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                     
                    child: Text(
                      gender,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.blackColor,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedGender = newValue;
                      widget.controller.text = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
