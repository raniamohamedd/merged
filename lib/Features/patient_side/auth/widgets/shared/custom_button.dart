import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text ;
  final VoidCallback onPressed ;
  

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                    onPressed:onPressed,

                    // },
                    child: Text(text , style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),),
                  ),
                );
  }
}