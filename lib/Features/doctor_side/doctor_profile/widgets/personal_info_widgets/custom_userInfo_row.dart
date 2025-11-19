import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/personal_info_widgets/custom_profile_button.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class CustomUserinfoRow extends StatefulWidget {
  const CustomUserinfoRow({
    super.key,
    required this.controller,
    required this.label,
    required this.onSave,
  });

  final TextEditingController controller;
  final String label;
  final Future<void> Function(String newValue) onSave;

  @override
  State<CustomUserinfoRow> createState() => _CustomUserinfoRowState();
}

class _CustomUserinfoRowState extends State<CustomUserinfoRow> {
  bool isEditing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '   ${widget.label}',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                readOnly: !isEditing,
                 style: TextStyle(
                  fontSize: isEditing ? 14.5 : 15,
                  color: Colors.black, 
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical:  16,
                    horizontal: 8,
                  ),
                  hintText: "write your ${widget.label.toLowerCase()}",
                  filled: true,
                  fillColor: AppColors.whiteColor,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),


            CustomProfileButton(
              label: isEditing ? "Save" : "Edit",
              onPressed: () async {
                if (isEditing) {
                  await widget.onSave(widget.controller.text.trim());
                  setState(() => isEditing = false);

                } else {
                  setState(() => isEditing = true);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    FocusScope.of(context).requestFocus(_focusNode);
                  });
                }
              },
            ),
          ],
        ),

        // ),
      ],
    );
  }
}
