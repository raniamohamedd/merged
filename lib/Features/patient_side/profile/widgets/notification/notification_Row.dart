import 'package:flutter/material.dart';

class NotificationRow extends StatefulWidget {
  const NotificationRow({super.key, required this.title});
  final String title ;

  @override
  State<NotificationRow> createState() => _NotificationRowState();
}

class _NotificationRowState extends State<NotificationRow> {
  bool isSwitched = false; // الحالة الحالية للزر

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
    
        Switch(
          padding: EdgeInsets.zero,
          value: isSwitched,
          activeThumbColor: Colors.white, 
          
          activeTrackColor: Colors.blue,
        
          inactiveThumbColor: Colors.grey[500], // لون الزر لما يكون مقفول
          inactiveTrackColor: Colors.grey[300], // لون الخلفية لما يكون مقفول
      
          trackOutlineColor: WidgetStateProperty.all(
            Colors.transparent,
          ), // ← يخفي أي حد خارجي
        
          onChanged: (value) {
            setState(() {
              isSwitched = value;
            });
          },
        ),
      ],
    );
  }
}
