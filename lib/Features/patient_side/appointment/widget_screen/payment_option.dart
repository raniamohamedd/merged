import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class PaymentOption extends StatefulWidget {
  final Function(String) onPaymentSelected; // دالة لإرسال القيمة للخارج

  const PaymentOption({super.key, required this.onPaymentSelected});

  @override
  State<PaymentOption> createState() => _PaymentOptionState();
}

class _PaymentOptionState extends State<PaymentOption> {
  String? paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Payment Option",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.purpleColor,
          ),
        ),
        Row(
          children: [
            Radio<String>(
              value: "Credit Card",
              groupValue: paymentMethod,
              activeColor: AppColors.blueColor,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value;
                });
                widget.onPaymentSelected(value!); // إرسال القيمة للخارج
              },
            ),
            const SizedBox(width: 5),
            const Text(
              "Credit Card",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            Radio<String>(
              value: "Fawry",
              groupValue: paymentMethod,
              activeColor: AppColors.blueColor,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value;
                });
                widget.onPaymentSelected(value!); // إرسال القيمة للخارج
              },
            ),
            const SizedBox(width: 5),
            const Text(
              "Fawry",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
