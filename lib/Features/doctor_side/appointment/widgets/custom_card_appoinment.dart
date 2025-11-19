import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';

class CustomCardAppointment extends StatelessWidget {
  const CustomCardAppointment({
    super.key,
    required this.appointmentStatue,
    required this.day,
    required this.time,
    required this.color,
    required this.name,
    required this.status,
    required this.imgPath,
  });

  final String appointmentStatue;
  final String day;
  final String time;
  final Color color;
  final String name;
  final String status;
  final String imgPath;

  @override
  Widget build(BuildContext context) {
    return
      // Padding(
      // padding: const EdgeInsets.only(left: 7,top: 10),
      // child:
    Card(
        // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        elevation: 2,
        color: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.greyColor,
            width: 1,
          ),
        ), child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointmentStatue,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "$day | $time",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.greyColor,
                fontWeight: FontWeight.w500,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundImage: AssetImage(imgPath)),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        //#0000005C
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
                ),
        ),
    );
  }
}
