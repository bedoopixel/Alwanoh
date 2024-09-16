import 'package:admin_panel/regScreen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Admin_Auth/SignInScreen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyBZDjvmG3vtQ4AEM4a2_eSS7uiDV7Sytxo", appId: "1:688690750237:android:8bac02cd231d9ebfbd37f4", messagingSenderId: "688690750237", projectId: "alwanoh-store",storageBucket: "alwanoh-store.appspot.com"),
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),// For web only
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home:  SignInScreen(),
    );
  }
}

