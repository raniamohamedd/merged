import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/splash&onboarding/splash.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:flutter_application_2/services/notification_services.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

await NotificationService.init();

// تجربة الإشعار فور التشغيل
await NotificationService.showTestNotification();

runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
home: SplashScreen(),
);
}
}
