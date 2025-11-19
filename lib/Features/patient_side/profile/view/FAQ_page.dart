import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/profile/widgets/shared/custom_appbar.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqList = [
      {
        'question': "What should I expect during a doctor's appointment?",
        'answer':
            "During a doctor's appointment, you can expect to discuss your medical history, symptoms, and any medications or treatments you are taking.",
      },
      {
        'question': "How do I make an appointment with a doctor?",
        'answer':
            "You can make an appointment through our app by selecting your doctor and choosing an available time slot.",
      },
      {
        'question': "What should I bring to my doctor's appointment?",
        'answer':
            "You should bring your ID, any medical reports, and a list of medications you are currently taking.",
      },
      {
        'question': "How early should I arrive for my doctor's appointment?",
        'answer':
            "It’s best to arrive at least 10–15 minutes before your scheduled time.",
      },
      {
        'question': "Can I cancel or reschedule my appointment?",
        'answer':
            "Yes, you can cancel or reschedule from the 'My Appointments' section in the app.",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "FAQ", textColor: Colors.black),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: faqList.length,
          itemBuilder: (context, index) {
            return buildFaqItem(
              faqList[index]['question']!,
              faqList[index]['answer']!,
            );
          },
        ),
      ),
    );
  }
}

Widget buildFaqItem(String question, String answer) {
  return Column(
    children: [
      Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),

        child: ExpansionTile(
          iconColor: Colors.blue,
          tilePadding: EdgeInsets.zero,

          title: Padding(
            padding: const EdgeInsets.only(
              right: 25,
              left: 6,
              bottom: 8.0,
              top: 8.0,
            ),
            child: Text(
              question,
              style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
            ),
          ),

          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                answer,
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      const Divider(thickness: 1, height: 1),
       SizedBox(height: 10),
    ],
  );
}
