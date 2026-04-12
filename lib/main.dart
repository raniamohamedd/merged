import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/splash&onboarding/splash.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_application_2/core/routing/navigators/navigation_screen_doc.dart';
import 'package:flutter_application_2/core/routing/navigators/navigator_patient.dart';
import 'package:flutter_application_2/core/services/notification_services.dart';
import 'package:flutter_application_2/shared/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  await NotificationService.init(navKey: appNavigatorKey);

  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  String role = prefs.getString("role") ?? "";

  if (isLoggedIn) {
    UserSession.accessToken = prefs.getString("accessToken") ?? "";
    UserSession.refreshToken = prefs.getString("refreshToken") ?? "";
  }

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    role: role,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String role;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    Widget startScreen;

    if (!isLoggedIn) {
      startScreen = SplashScreen();
    } else if (role == "doctor") {
      startScreen = NavigationnScreendoc();
    } else {
      startScreen = NavigationnScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      home: startScreen,
    );
  }
}