import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/shared/widgets/custom_button.dart';

// import '../../core/constants/colors.dart';
// import '../../shared/widgets/custom_button.dart';
import '../confirmation/booking_confirmation.dart';

class PaymentDetails extends StatelessWidget {
  const PaymentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Payment Details",style: TextStyle(fontWeight: FontWeight.w800),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              spacing: 30,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(image: AssetImage("lib/images/card.png")),
                Center(child: Text("110 \$",style: TextStyle(fontSize:35,fontWeight: FontWeight.bold,color: AppColors.greyColor,),)),
                TextFormField(
                  decoration: InputDecoration(hintText: "CARD NUMBER",hintStyle:TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: AppColors.greyColor,), ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*.50,
                      child: TextFormField(
                        decoration: InputDecoration(hintText: "EXPIRTY DATE (MM/YY)",hintStyle:TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: AppColors.greyColor,), ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*.08,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*.25,
                      child: TextFormField(
                        decoration: InputDecoration(hintText: "CVV",hintStyle:TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: AppColors.greyColor,), ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(
                  width: MediaQuery.of(context).size.width*.50,
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "CARDHOLDERNAME",hintStyle:TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: AppColors.greyColor,), ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*.04,
                ),
                // CustomButton(name: 'Pay', page: BookingConfirmation(),color: AppColors.greenColor,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
