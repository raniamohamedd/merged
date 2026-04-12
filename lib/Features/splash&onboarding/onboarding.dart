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
  bool isArabic = false;
  late List<Map<String, dynamic>> _pages;

  @override
  void initState() {
    super.initState();
    _pages = pages;
  }

  void _toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
      _pages = isArabic ? arabicPages : pages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              // child: Row(
              //   children: [
              //   //   Spacer(),
        
              //   //   // 
              //   //   SizedBox(width: 10),
              //   //   TextButton(
              //   //     onPressed: () {
              //   //       Navigator.pushReplacement(
              //   //         context,
              //   //         MaterialPageRoute(
              //   //           builder: (_) => LoginScreen(),
              //   //         ),
              //   //       );
              //   //     },
              //   //     child: Text(
              //   //       isArabic ? "تخطي" : "Skip",
              //   //       style: TextStyle(
              //   //         color: AppColors.blackColor,
              //   //         fontWeight: FontWeight.bold,
              //   //       ),
              //   //     ),
              //   //   ),
              //   // ],
              // ),
            ),
        
            // الصفحات
            Expanded(
              child: PageView.builder(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (index) {
                            final baseColor = page['color'] as Color;
        
                            Color dotColor;
                            if (_currentPage == index) {
                              dotColor =
                                  baseColor; // اللون الأساسي للنقطة الحالية
                            } else if (_currentPage > index) {
                              dotColor = baseColor.withOpacity(
                                0.4,
                              ); // أفتح شويه للنقط السابقة
                            } else {
                              dotColor = Colors.grey[400]!; // رمادي للباقي
                            }
        
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
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
        
                        Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26, // ظل خفيف جدًا
                                offset: Offset(0, 20), // لتحت بس
                                blurRadius: 16, // ظل ناعم
                                spreadRadius: 0,
                              ),
                            ],
                            shape: BoxShape.circle, // لو اللوجو دايرة
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
                          page["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page["subtitle"]!,
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
        
            // الأزرار السفلية
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر Back
                  if (hasPressedNext && _currentPage > 0)
                   ElevatedButton(
          onPressed: _currentPage == 0
              ? null
              : () {
        _controller.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: pages[_currentPage]['color'] as Color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
              side: BorderSide(
                color: pages[_currentPage]['color'] as Color,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10, // ← العرض (قللي الرقم لتصغير العرض)
              vertical: 20,   // ↑ الطول (زودي الرقم لتكبير الطول)
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // ← دي بتخلي الزرار ياخد عرض المحتوى فقط
            children: [
              const Icon(CupertinoIcons.back, size: 18),
              const SizedBox(width: 6),
              Text(isArabic ? "رجوع" : "Previous"),
            ],
          ),
        ) else
                    const SizedBox(width: 80),
        
                  // زر Next / Start
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
            backgroundColor: pages[_currentPage]['color'] as Color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 40, // ← العرض (قللي الرقم لتصغير العرض)
              vertical: 20,   // ↑ الطول (زودي الرقم لتكبير الطول)
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // يخلي الزرار على قد النص فقط
            children: [
              Text(
                _currentPage == _pages.length - 1
          ? (isArabic ? "ابدأ" : "Get Started")
          : (isArabic ? "التالي" : "Next"),
                style: TextStyle(
        color: AppColors.whiteColor,
        fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
            ],
          ),
        )  ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
