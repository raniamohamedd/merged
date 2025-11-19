import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/auth/view/login_view.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

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
  
  
  
  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent! Check your email.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              onPressed: resetPassword,

              // },
              child: Text(
                widget.text,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Need help? Visit our"),
              GestureDetector(
                onTap: widget.onPressedtext,
                child: Text(
                  " help center",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
