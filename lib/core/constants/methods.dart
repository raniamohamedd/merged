
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';


  void snackBarMessage(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color ?? AppColors.greyColor,
        behavior: SnackBarBehavior.floating,
        // margin: EdgeInsets.all(20),
        duration: Duration(seconds: 2),
      ),
    );
  }
