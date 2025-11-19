import 'package:flutter/material.dart';

class CustomDoctorNavbar extends StatelessWidget implements PreferredSizeWidget{
  const CustomDoctorNavbar({super.key, required this.onPress});
 final  VoidCallback onPress;
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
  preferredSize: Size.fromHeight(kToolbarHeight),
  child: Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2), 
          offset: Offset(1, 3),
          blurRadius: 6, 
        ),
      ],
    ),
    child: AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        onPressed: onPress,
        icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
      ),
      title: Text(
        "Profile",
        style: TextStyle(fontSize: 22, color: Colors.black),
      ),
    ),
  ),
);
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}