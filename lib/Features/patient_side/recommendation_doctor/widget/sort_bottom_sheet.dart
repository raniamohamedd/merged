import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/model/doctor_specialist.dart';
import 'package:flutter_application_2/Features/patient_side/recommendation_doctor/widget/filter_chip_custom.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({
    super.key,
    required this.selectedSpeciality,
    required this.selectedRating,
    required this.onApply,
  });

  final String selectedSpeciality;
  final int selectedRating;
  final Function(String, int) onApply;

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late String speciality;
  late int rating;

  @override
  void initState() {
    super.initState();
    speciality = widget.selectedSpeciality;
    rating = widget.selectedRating;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey.withOpacity(.09),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Sort By',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorBlack,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Speciality',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textColorBlack,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 10,
              children: [
                // الاستيراد صحيح

                // ... داخل الـ Wrap:
                FilterChipCustom(
                  label: 'All',
                  selected: speciality == 'All',
                  onTap: () => setState(() => speciality = 'All'),
                ),
                // ✳️ هنا التعديل: شيل النقطة قبل items
                ...items.map(
                  (s) => FilterChipCustom(
                    label: s.title,
                    img: s.imgUrl,
                    selected: speciality == s.title,
                    onTap: () => setState(() => speciality = s.title),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rating',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textColorBlack,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              FilterChipCustom(
                label: 'All',
                selected: rating == 0,
                icon: Icons.star,
                onTap: () => setState(() => rating = 0),
              ),
              for (int i = 5; i >= 3; i--)
                FilterChipCustom(
                  label: '$i',
                  selected: rating == i,
                  icon: Icons.star,
                  onTap: () => setState(() => rating = i),
                ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColorBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                widget.onApply(speciality, rating);
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
