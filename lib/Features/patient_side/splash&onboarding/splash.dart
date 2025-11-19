import 'package:flutter/material.dart';
import 'package:flutter_application_2/core2/constants/icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_application_2/core2/constants/colors.dart';
import 'package:flutter_application_2/Features/patient_side/splash&onboarding/onboarding.dart';
import 'dart:math' as math;


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _rotationAnimation = Tween<double>(begin: -math.pi, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3), 
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
               Color.fromARGB(255, 22, 68, 194),
               Color(0xFF3B82F6),
              Color.fromARGB(255, 22, 68, 194),
            ],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 15),

            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: child,
                  ),
                );
              },
              child: 
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  HealthcareLogo(logo: HealthcareIcons.stethoscope, width: 6, color: AppColors.baby_blue, isGradient: false,),
                   Positioned(
                    top: -2,
                    right: -2,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.baby_blue,
                      child: Icon(
                        HealthcareIcons.heart,
                        color: AppColors.whiteColor,
                        size: 14,
                      ),
                    ),
                  ),
                   Positioned(
                    bottom: -1,
                    left: -1,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.baby_blue,
                      child: Icon(
                        HealthcareIcons.activity,
                        color:AppColors.whiteColor,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  children:  [
                    Text(
                      "Smart Healthcare",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Your Health, Our Priority",
                      style: TextStyle(
                        fontSize: 16,
                        color:AppColors.whiteColor,
                      ),
                    ),
                    SizedBox(height: 30),
                    SpinKitThreeBounce(
                      color: AppColors.whiteColor,
                      size: 25.0,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Loading...',
                      style: TextStyle(color: AppColors.whiteColor),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 12),
             Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Powered by Advanced Healthcare Technology",
                style: TextStyle(
                  fontSize: 12,
                  color:AppColors.whiteColor,
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class HealthcareLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final IconData logo;
  final double width; 
  final Color color;
  final bool isGradient; 
  final List<Color>? gradientColors;

  const HealthcareLogo({
    super.key,
    this.size = 110,
    this.iconSize = 36,
    required this.logo,
    this.width = 15, 
    required this.color,
   required this.isGradient ,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final innerSize = size - (width * 2); 

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isGradient
                ? SweepGradient(
                    colors: gradientColors ??
                        [
                          color,
                          color,
                         color.withOpacity(.5),
                          color,
                        ],
                    startAngle: 0.0,
                    endAngle: 3.14 * 2,
                  )
                : null,
            border: isGradient
                ? null
                : Border.all(
                    color: color,
                    width: width,
                  ),
          ),
        ),

        Container(
          width: innerSize,
          height: innerSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            logo,
            size: iconSize,
            color: color,
          ),
        ),
      ],
    );
  }
}