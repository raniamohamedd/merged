import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  final TextEditingController otpController = TextEditingController();

  void verifyOtp() async {
  try {

    final response = await ApiService.confirmEmail(
      email: widget.email.toLowerCase(),
      otp: otpController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? "Email verified")),
    );

    // بعد التأكيد يروح للـ Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Invalid OTP")),
    );
    print(e);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
     
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.start,
               children: [
                SizedBox(height: 100,),
                SizedBox(width: 80,),

                          Text("Email Verification",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: AppColors.blueColor),),
               ],
             )
,        

            const SizedBox(height: 30),

            const Text(
              "Enter the OTP",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "We sent a code to ${widget.email}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
  controller: otpController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: "Enter the OTP",
    labelStyle: const TextStyle(color: Colors.blue), // لون النص
    border: const OutlineInputBorder(), // شكل الحواف الافتراضي
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blue), // لون الحواف العادية
      borderRadius: BorderRadius.circular(12), // حواف مدورة
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blue, width: 2), // لون الحواف عند التركيز
      borderRadius: BorderRadius.circular(12), // حواف مدورة
    ),
  ),
),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColors.blueColor),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // لو عايزة حواف مدوّرة
      ),
    ),
  ),
                onPressed: verifyOtp,

                child: const Text("Verify",style: TextStyle(color: Colors.white),),
              ),
            ),
            SizedBox(height: 16,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColors.blueColor),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // لو عايزة حواف مدوّرة
      ),
    ),
  ),
                 onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
                 },

                child: const Text("Back",style: TextStyle(color: Colors.white),),
              ),
            )

          ],
        ),
      ),
    );
  }
}