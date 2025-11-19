import 'package:flutter/material.dart';

class CustomDoctorAvatar extends StatelessWidget {
  const CustomDoctorAvatar({
    super.key,
    required this.docName,
    required this.imageUrl,
  });

  final String docName;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue[100]!, width: 2.5),
          ),
          child: CircleAvatar(
            radius: 58,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(imageUrl), 
          ),
        ),
        const SizedBox(height: 10),
        Text(
          docName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
