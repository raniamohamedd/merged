import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/reset_screen.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/core/services/api_service.dart';
import 'package:flutter_application_2/shared/widgets/error_dialog.dart';

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
  showErrorDialog(context, message: e.toString());

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(.10),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Oops!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Something went wrong.\nPlease try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF247CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
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
