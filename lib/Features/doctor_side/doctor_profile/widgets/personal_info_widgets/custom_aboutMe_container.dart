import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/doctor_side/doctor_profile/widgets/personal_info_widgets/custom_profile_button.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class CustomAboutmeContainer extends StatefulWidget {
  const CustomAboutmeContainer({super.key, required this.controller, required this.label, required this.onSave});
final TextEditingController controller;
  final String label;
  final Future<void> Function(String newValue) onSave;
  @override
  State<CustomAboutmeContainer> createState() => _CustomAboutmeContainerState();
}

class _CustomAboutmeContainerState extends State<CustomAboutmeContainer> {

 bool isEditing = false;
  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyLightColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "  About Me",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
          
          SizedBox(height: 10),
          TextFormField(
            controller: widget.controller,
             focusNode: _focusNode,
                readOnly: !isEditing,
            maxLines: 4,
            style: TextStyle(
              fontSize: isEditing ? 14.5 : 15,
              color: Colors.black, 
            ),
            decoration: InputDecoration(
              hintText: "Write about yourself",
              filled: true,
              fillColor: AppColors.whiteColor,
              //  contentPadding: EdgeInsets.symmetric(
              //       vertical:  16,
              //       horizontal: 8,
              //     ),
              
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
              ),
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
