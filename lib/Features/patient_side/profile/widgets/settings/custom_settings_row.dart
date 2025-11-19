import 'package:flutter/material.dart';

class CustomSettingsRow extends StatelessWidget {
  const CustomSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: 5),

            // CircleAvatar(
            // radius: 20,
            // backgroundColor: Colors.grey.shade100,
            // child:
            Icon(icon, color: Colors.blue, size: 25),
            // ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
          color: Colors.blue,
          splashColor: Colors.blue.withOpacity(0.2),
          hoverColor: Colors.blue.withOpacity(0.1),
          onPressed: onTap,
        ),
      ],
    );
  }
}
