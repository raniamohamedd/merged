// import 'package:flutter/material.dart';

// class UserImageProfile extends StatelessWidget {
//   const UserImageProfile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 110,
//       height: 110,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white, width: 5),
//         image: DecorationImage(
//           fit: BoxFit.cover,
//           image: 
//             'https://t3.ftcdn.net/jpg/13/11/22/86/360_F_1311228699_YoiLc5aJ3RWz3uRfdEtlV0UYSQjqf7RW.jpg',
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/shared/user_session.dart';

class UserImageProfile extends StatelessWidget {
  const UserImageProfile({
    super.key,
    // required this.name,
    // required this.imageUrl, 
  });

  // final String name;
  // final String email;
  // final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.whiteColor, width: 2.5),
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(UserSession.currentUser?.image ?? 'lib/images/patientt.png'), 
          ),
        ),
        const SizedBox(height: 10),
        // Text(
        //   name,
        //   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        // ),
      ],
    );
  }
}

