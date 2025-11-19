import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';


class PaymentDetailsConfirmation extends StatelessWidget {
  const PaymentDetailsConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Details:",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              spacing: 7,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Method:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: AppColors.purpleColor),),
                Text("Amount Paid:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: AppColors.purpleColor),),
              ],
            ),
            Column(
              spacing: 7,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cash at Clinic",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: AppColors.greyColor),),
                Text("110 \$",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: AppColors.greyColor),),
              ],
            )
          ],
        ),
        Divider(color: AppColors.purpleColor,),
      ],
    );
  }
}
