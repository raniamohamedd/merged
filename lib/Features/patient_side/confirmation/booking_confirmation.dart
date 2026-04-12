import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/confirmation/widgets/header_booking_confirmation.dart';
import 'package:flutter_application_2/Features/patient_side/confirmation/widgets/instructions.dart';
import 'package:flutter_application_2/shared/widgets/custom_button.dart';
import 'package:flutter_application_2/core/routing/navigators/navigator_patient.dart';

import '../../../core/constants/colors.dart';

class BookingConfirmation extends StatelessWidget {
  const BookingConfirmation({
    super.key,
    required this.bookingFor,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.paymentMethod,
    required this.prise,
  });

  final String bookingFor;
  final String fullName;
  final String age;
  final String gender;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String paymentMethod;
  final int prise;

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
        title: Text(
          "Booking Confirmation",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xff247CFF),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 10,
            children: [
              HeaderBookingConfirmation(),
              Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Booking Details:",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        spacing: 7,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Full Name:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color:AppColors.purpleColor),),
                          Text("Age:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
                          Text("Gender:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
                          Text("Date: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
                          Text("Time: ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
                          Text("Session Status:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.purpleColor),),
                        ],
                      ),
                      Column(
                        spacing: 5,
                        children: [
                          Text(fullName,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
                          Text(age,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
                          Text(gender,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
                          // 🟢 هنا التاريخ فقط
                          Text(
                            "${appointmentDate.day.toString().padLeft(2,'0')}/${appointmentDate.month.toString().padLeft(2,'0')}/${appointmentDate.year}",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),
                          ),
                          Text(appointmentTime,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: AppColors.greyColor),),
                        ],
                      )
                    ],
                  ),


                  Divider(color: Color(0xff6D7CCD),),
                ],
              ),
              Column(
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
                          Text(paymentMethod,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: AppColors.greyColor),),
                          Text("$prise \$",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: AppColors.greyColor),),
                        ],
                      )
                    ],
                  ),
                  Divider(color: AppColors.purpleColor,),
                ],
              ),
              Instructions(),
              SizedBox(height: 20),
              CustomButton(name: 'Back to Home', page: NavigationnScreen()),
            ],
          ),
        ),
      ),
    );
  }
}
