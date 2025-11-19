import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class FilterChipCustom extends StatelessWidget {
  const FilterChipCustom({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.img,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? img;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (img != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Image.asset(img!, width: 20, height: 20),
            ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                icon,
                color: selected
                    ? AppColors.textColorWhite
                    : AppColors.backgroundGrey,
                size: 18,
              ),
            ),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap?.call(),
      selectedColor: AppColors.backgroundColorBlue,
      backgroundColor: AppColors.backgroundGrey.withOpacity(.5),
      labelStyle: TextStyle(
        color: selected ? AppColors.textColorWhite : AppColors.textColorBlack,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
