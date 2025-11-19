import 'package:flutter/cupertino.dart';
import 'package:flutter_application_2/core/constants/colors.dart';



class PriceView extends StatelessWidget {
  const PriceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Price:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: AppColors.purpleColor),),
            Text("250 \$",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.darkGreyColor),),
          ],
        ),
      ],
    );
  }
}
