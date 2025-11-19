import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/Features/patient_side/doctor_specialisty/speciality.dart';
import 'package:flutter_application_2/Features/patient_side/home_screen/model/doctor_specialist.dart';
import 'package:flutter_application_2/Features/patient_side/recommendation_doctor/recommendation.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/constants/sizes.dart';
import 'package:flutter_application_2/shared/widgets/sea_all.dart';

class DoctorSpecialistWidget extends StatelessWidget {
  const DoctorSpecialistWidget({super.key, required this.items, this.onSelect});

  final List<DoctorSpecialist> items;
  final void Function(String spec)? onSelect;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Doctor Speciality",
              style: AppFonts.bodyLarge.copyWith(
                color: AppColors.textColorBlack,
              ),
            ),
            const Spacer(),
            SEAALL(
              onTap: () {
                // يفتح شاشة كل التخصصات
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Speciality(items: items),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: AppFonts.spaceMedium),

        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final spec = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: InkWell(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);

                    if (onSelect != null) {
                      onSelect!(spec.title);
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Recommendation(
                          initialSpec: spec.title,
                          initialQuery: '',
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColorBlue.withOpacity(
                            0.08,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ClipOval(
                            child: Image.asset(spec.imgUrl, fit: BoxFit.fill),
                          ),
                        ),
                      ),
                      SizedBox(height: AppFonts.spaceMedium),
                      Text(spec.title, style: AppFonts.bodyMedium),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Divider(color: AppColors.backgroundGrey, thickness: 1.25),
        SizedBox(height: AppFonts.spaceSmall),
      ],
    );
  }
}
