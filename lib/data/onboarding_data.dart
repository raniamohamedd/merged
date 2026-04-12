import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/icons.dart';
final List<Map<String, dynamic>> pages = [
  {
    "title": "Connect with Healthcare Professionals",
    "subtitle":
'Find and connect with verified doctors and healthcare providers in your area',   
 "icon": HealthcareIcons.stethoscope,
 'color':Color(0xFF1877F2)
  },
  {
    "title": "Never Miss Your Medications",
    "subtitle": "Set up smart reminders for your medications and track your daily adherence",
    "icon":HealthcareIcons.notifications,
     'color':Colors.green

  },
  {
    "title": "Track Your Health Progress",
    "subtitle": "Monitor your vital signs, view detailed reports, and share them with your doctor",
    "icon": HealthcareIcons.reports,
     'color':Colors.purple

  },
    {
    "title": "AI-Powered Health Assistant",
    "subtitle": "Get instant answers to your health questions with our intelligent chatbot",
    "icon": HealthcareIcons.chat,
     'color':Colors.orange

  },
];

final List<Map<String, dynamic>> arabicPages = [
  {
    "title":'تواصل مع المتخصصين في الرعاية الصحية',
    "subtitle":'ابحث وتواصل مع الأطباء ومقدمي الرعاية الصحية الموثقين في منطقتك'
    ,    "icon": HealthcareIcons.stethoscope,
     'color':Color(0xFF1877F2)

  },
  {
    "title": 'لن تفوتك أدويتك أبداً',
    "subtitle": 'قم بإعداد تذكيرات ذكية لأدويتك وتتبع التزامك اليومي',
    "icon":HealthcareIcons.notifications,
     'color':Colors.green

  },
  {
    "title": "تتبع تقدمك الصحي",
    "subtitle": 'راقب علاماتك الحيوية، اطلع على التقارير التفصيلية، وشاركها مع طبيبك',
        "icon": HealthcareIcons.reports,
         'color':Colors.purple

  },
    {
    "title": 'مساعد صحي مدعوم بالذكاء الاصطناعي',
    "subtitle":'احصل على إجابات فورية لأسئلتك الصحية مع روبوت الدردشة الذكي',   
         "icon": HealthcareIcons.chat,
          'color':Colors.orange

  },
];