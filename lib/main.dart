import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_application_2/Features/patient_side/splash&onboarding/splash.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:flutter_application_2/services/notification_services.dart';
import 'package:flutter_application_2/firebase_options.dart';
import 'package:flutter_application_2/shared/widgets/navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize downloader
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();
  await NotificationService.showTestNotification();

  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  if (isLoggedIn) {
    UserSession.accessToken = prefs.getString("accessToken") ?? "";
    UserSession.refreshToken = prefs.getString("refreshToken") ?? "";
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? NavigationnScreen() : SplashScreen(),
    );
  }
}