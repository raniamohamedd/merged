import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/colors.dart';
import 'package:flutter_application_2/data/onboarding_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Trans extends StatefulWidget {
  const Trans({super.key});

  @override
  State<Trans> createState() => _TransState();
}

class _TransState extends State<Trans> {
    final PageController _controller = PageController();
  int _currentPage = 0;
  bool hasPressedNext = false;
  bool isArabic = false;
  late List<Map<String, dynamic>> _pages;
    void _toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
      _pages = isArabic ? arabicPages : pages;
    });
  }
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
                      onPressed: _toggleLanguage,
                      icon: Icon(FontAwesomeIcons.language, size: 12),
                      label: Text(
                        isArabic ? "English" : "العربية",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.hovered)) {
                                return const Color.fromARGB(
                                  255,
                                  175,
                                  215,
                                  248,
                                ); // 🔵 الخلفية لما الماوس ييجي فوق
                              }
                              return Colors.transparent; // الخلفية العادية
                            }),
                        foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                          states,
                        ) {
                          if (states.contains(WidgetState.hovered)) {
                            return AppColors
                                .blueColor; // 🔵 لون النص والأيقونة لما الماوس فوق
                          }
                          return AppColors.blackColor; // اللون العادي
                        }),
                        side: WidgetStateProperty.all(
                          const BorderSide(color: Colors.black, width: 0.1),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    );
  }
}