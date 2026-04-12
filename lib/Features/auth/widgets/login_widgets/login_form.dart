import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/widgets/shared/custom_textfeild.dart';

class LoginForm extends StatelessWidget {
  final String enemail;
  final String enpass;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final GlobalKey<FormState> formKey;
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController
    , required this.formKey, required this.enemail, required this.enpass,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key : formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        
        children: [
      
          CustomTextField(
            label: enemail,
            icon: Icons.email_outlined,
            controller: emailController,
            
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              }
              return null;
            },
      
          ),
      
          const SizedBox(height: 16),
          
          CustomTextField(
            label:enpass,
            icon: Icons.lock_outline,
            controller: passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.length < 8) {
                return "Password must be at least 8 characters";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
