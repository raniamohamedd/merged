import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/reset_screen.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';

class ForgotpasswordButton extends StatefulWidget {
  
  final String text;
  final String email;
  // final VoidCallback onPressedButton;
  final VoidCallback onPressedtext;

  const ForgotpasswordButton({
    super.key,
    required this.text, required this.onPressedtext, required this.email,
   
  });

  @override
  State<ForgotpasswordButton> createState() => _ForgotpasswordButtonState();
}

class _ForgotpasswordButtonState extends State<ForgotpasswordButton> {
  
      final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    bool loading = false;

  Future<void> handleforget() async {
  if (!formKey.currentState!.validate()) return;

 

  setState(() => loading = true);

  try {
    final response = await ApiService.forgetpassword(
 
      email: emailController.text.trim(),
  
    );

    // 👇 ده هيطبع الريسبونس من السيرفر
    print("forget Response:");
    print(response);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetScreen(email: emailController.text.trim(),
          // email: emailController.text.trim(),
        ),
      ),
    );

  } catch (e) {

    // 👇 ده هيطبع الايرور
    print("forget Error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  setState(() => loading = false);
} 
  
  
 
  
  
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                foregroundColor: AppColors.whiteColor,

                padding: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              onPressed: (){},

              // },
              child: Text(
                widget.text,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(height: 20),
          ],
      ),
    );
  }
}
