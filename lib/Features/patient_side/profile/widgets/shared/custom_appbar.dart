import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget 
implements PreferredSizeWidget {

  final String title;
  final Color textColor;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.textColor,
    this.onBack, 
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false, // <- add this

      
      backgroundColor: Colors.transparent, 
      elevation: 0,

      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // leading: IconButton(
      //   // icon:  Icon(
      //   //   Icons.arrow_back_ios_rounded,
      //   //   color: textColor,
      //   //   size: 22,
      //   // ),
      //   onPressed: onBack ?? () => Navigator.pop(context),
      // ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
