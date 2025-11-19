import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/sizes.dart';

//                  SEEALL
class SEAALL extends StatelessWidget {
  const SEAALL({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        // navigator
        if (onTap != null) {
          onTap!();
        }
      },
      child: Text(
        "See All",
        style: AppFonts.bodyMedium.copyWith(color: AppColors.textColorBlue),
      ),
    );
  }
}
