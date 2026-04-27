import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/auth/screens/login_view.dart';
import 'package:flutter_application_2/Features/splash&onboarding/splash.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/data/onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool hasPressedNext = false;

  late List<Map<String, dynamic>> _pages;

  @override
  void initState() {
    super.initState();
    _pages = pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppColors.whiteColor,
      body: Column(
        
        children: [
          // 🔥 Skip Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 35,
            ),
            child: Row(
              children: [
                const Spacer(),
                if (_currentPage != _pages.length - 1)
            OutlinedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  },
  style: OutlinedButton.styleFrom(
    side: BorderSide(
      color: _pages[_currentPage]['color'] as Color,
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // مربع شويه
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  ),
  child: Text(
    "Skip",
    style: TextStyle(
      color: _pages[_currentPage]['color'] as Color,
      fontWeight: FontWeight.w600,
    ),
  ),
),  ],
            ),
          ),

          // 🔥 Pages
          Expanded(
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: _controller,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final baseColor = page['color'] as Color;

                          Color dotColor;
                          if (_currentPage == index) {
                            dotColor = baseColor;
                          } else if (_currentPage > index) {
                            dotColor = baseColor.withOpacity(0.4);
                          } else {
                            dotColor = Colors.grey[400]!;
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 30 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // Logo
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 20),
                              blurRadius: 16,
                            ),
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: HealthcareLogo(
                          logo: page['icon'] as IconData,
                          size: 140,
                          iconSize: 55,
                          width: 10,
                          color: page['color'] as Color,
                          isGradient: true,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Text(
                        page["title"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        page["subtitle"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 🔥 Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                if (hasPressedNext && _currentPage > 0)
                  ElevatedButton(
                    onPressed: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                          _pages[_currentPage]['color'] as Color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                        side: BorderSide(
                          color: _pages[_currentPage]['color'] as Color,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.back, size: 18),
                        SizedBox(width: 6),
                        Text("Previous"),
                      ],
                    ),
                  )
                else
                  const SizedBox(width: 80),

                // Next / Get Started
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      hasPressedNext = true;
                    });

                    if (_currentPage < _pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _pages[_currentPage]['color'] as Color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1
                            ? "Get Started"
                            : "Next",
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}