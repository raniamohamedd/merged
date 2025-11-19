import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Features/patient_side/splash&onboarding/splash.dart';
import 'package:flutter_application_2/firebase_options.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
   );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      // initialRoute: "/",
      // routes: {
      
        // "/": (context) => NavigationnScreen()

        // },
    );
  }
}
