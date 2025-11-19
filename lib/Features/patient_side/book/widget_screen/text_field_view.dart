import 'package:flutter/material.dart';

class TextFieldView extends StatelessWidget {
  const TextFieldView({
    super.key,
    required this.onNameChanged,
    required this.onAgeChanged,
  });

  final Function(String) onNameChanged;
  final Function(String) onAgeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Enter Name",
            fillColor: Colors.grey[200],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey[50]!,)
            ),
          ),
          onChanged: onNameChanged,
        ),

        const SizedBox(height: 5),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter Age",
            fillColor: Colors.grey[200],
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey[50]!,)
            ),
          ),
          onChanged: onAgeChanged,
        ),
      ],
    );
  }
}
