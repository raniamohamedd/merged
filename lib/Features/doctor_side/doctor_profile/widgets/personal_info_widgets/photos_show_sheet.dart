import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/services/firestore_services.dart';
import 'package:flutter_application_2/shared/user_session.dart';

Future<String?> showImagePickerSheet(
  BuildContext context,
  String userId,
) async {
  final firestoreService = FirestoreService();

  bool isDoctor ;
  if(UserSession.currentUser!.role == 'Doctor'&& UserSession.currentUser != null){
    isDoctor = true;
  }
  else{
    isDoctor = false;
  }

  final List<String> doctorImages = [
    'lib/images/Doctors/Image-1.png',
    'lib/images/Doctors/Image-2.png',
    'lib/images/Doctors/Image-3.png',
    'lib/images/Doctors/Image-4.png',
    'lib/images/Doctors/Image.png',
  ];

  final List<String> patientImages = [
  
    'lib/images/patientt.png',
    "lib/images/patients/patient1.png",
    "lib/images/patients/patient2.png",
    "lib/images/patients/patient3.jpg",
    "lib/images/patients/patient4.png",

  ];

  final List<String> imagePaths = isDoctor ? doctorImages : patientImages;

  return await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            final imagePath = imagePaths[index];

            return GestureDetector(
              onTap: () async {
                if (isDoctor) {
                  // await firestoreService.updateDoctorField(
                  //   'imageUrl',
                  //   imagePath,
                  // );
                  await firestoreService.updateUserField('image', imagePath);
                  UserSession.currentDoctor = UserSession.currentDoctor!
                      .copyWith(imageUrl: imagePath);
                  UserSession.currentUser = UserSession.currentUser!.copyWith(
                    image: imagePath,
                  );
                } else {
                  await firestoreService.updateUserField('image', imagePath);
                  UserSession.currentUser = UserSession.currentUser!.copyWith(
                    image: imagePath,
                  );

                }

                // 👇 إغلاق النافذة بعد الاختيار
                Navigator.pop(context, imagePath);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      
                           'your profile photo updated successfully',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            );
          },
        ),
      );
    },
  );
}
