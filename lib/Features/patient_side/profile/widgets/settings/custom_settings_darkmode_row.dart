import 'package:flutter/material.dart';

class DarkModeSwitch extends StatefulWidget {
  const DarkModeSwitch({super.key});

  @override
  State<DarkModeSwitch> createState() => _DarkModeSwitchState();
}

class _DarkModeSwitchState extends State<DarkModeSwitch> {
  bool isSwitched = false; // الحالة الحالية للزر

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 5.0,
        bottom: 5.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Dark Mode",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),

          Switch(
            value: isSwitched,
            activeThumbColor: Colors.white, 
            
            activeTrackColor: Colors.blue,
          
            inactiveThumbColor: Colors.grey[500], // لون الزر لما يكون مقفول
            inactiveTrackColor: Colors.grey[300], // لون الخلفية لما يكون مقفول
          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            thumbIcon: WidgetStateProperty.all(
              
              
              
              Icon(
                isSwitched ? Icons.dark_mode : null,
                color: isSwitched ? Colors.white : null,
                size: 21,
              ),
              
            ),
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
      ),
    );
  }
}
