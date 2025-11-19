import 'package:flutter/material.dart';

class AppFonts {
  // العناوين الكبيرة
  static const TextStyle titleBold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleRegular = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  // النصوص العادية
  static const TextStyle bodyBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  //     sized icon
  static const double BigIcon = 30;

  // sized box size
  static const double sizeBoxMedium = 15;

  //media query

  // mazen sized

  //  العناوين (Titles)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 40, // العناوين الرئيسية
    fontWeight: FontWeight.bold,
  );

  // static const TextStyle titleMedium = TextStyle(
  //   fontSize: 26, // عنوان فرعي
  //   fontWeight: FontWeight.w600,
  // );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 22, // عنوان صغير أو عنصر داخل صفحة
    fontWeight: FontWeight.w500,
  );

  //  النصوص
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, // نص واضح للقراءة
    fontWeight: FontWeight.w600,
  );

  // static const TextStyle bodyMedium = TextStyle(
  //   fontSize: 14, // النص الأساسي
  //   fontWeight: FontWeight.normal,
  // );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, // نصوص ثانوية أو وصفية
    fontWeight: FontWeight.normal,
  );

  //  النصوص الصغيرة جدًا (مثلاً ملاحظات أو حقوق)
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  //  حجم الأيقونات
  static const double iconLarge = 32;
  static const double iconMedium = 24;
  static const double iconSmall = 18;

  //  المسافات القياسية (SizedBox)
  static const double spaceLarge = 26;
  static const double spaceMedium = 18;
  static const double spaceSmall = 12;
}

class AppSizes {
  static double textFieldSize = 18;
  static double buttonReduisSize = 18;
}
