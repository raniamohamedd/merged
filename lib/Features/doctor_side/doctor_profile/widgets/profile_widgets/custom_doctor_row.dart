import 'package:flutter/material.dart';

class CustomDoctorRow extends StatelessWidget {
  const CustomDoctorRow({
    super.key,
    required this.onpress,
    required this.icon,
    required this.text,
  });
  final VoidCallback onpress;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[100],
              child: Icon(icon, size: 25, color: Colors.blue),
            ),
            SizedBox(width: 30),
            Text(text, style: TextStyle(color: Colors.black, fontSize: 20)),
          ],
        ),
        IconButton(
          onPressed: onpress,
          icon: Icon(
            Icons.arrow_forward_ios_sharp,
            size: 20,
            color: Colors.blue,
            
          ),
          hoverColor: Colors.blue.withOpacity(0.1),
          highlightColor:Colors.blue.withOpacity(0.1)
        ),
      ],
    );
  }
}
