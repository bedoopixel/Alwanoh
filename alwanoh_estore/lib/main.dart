import 'package:alwanoh_estore/payments/Tab_payments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Favorite/FavoritesPage.dart';
import 'Main_Screens/HomePage.dart';
import 'Main_Screens/WelcomeScreen.dart';
import 'Login/loginScreen.dart';
import 'Main_Screens/home.dart';
import 'Profile_Pages/PersonalScreenWidget.dart';
import 'SearchPage.dart';
import 'Serves/UserProvider.dart';
import 'Thems/ThemeProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBZDjvmG3vtQ4AEM4a2_eSS7uiDV7Sytxo",
      appId: "1:688690750237:android:8bac02cd231d9ebfbd37f4",
      messagingSenderId: "688690750237",
      projectId: "alwanoh-store",
      storageBucket: "alwanoh-store.appspot.com",
    ),
  );

  // Initialize App Check (optional, for extra security)
  await FirebaseAppCheck.instance.activate();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setThemeMode(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alwanoh Store',
      theme: ThemeData.light(), // Light mode theme
      darkTheme: ThemeData.dark(), // Dark mode theme
      themeMode: themeProvider.themeMode, // Set the theme mode
      home: const AuthHandler(),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthHandler(),
        '/home': (context) => Home(),
        '/cart': (context) => SearchPage(),
        '/account': (context) => PersonalScreenWidget(),
        '/settings': (context) => FavoritePage(),
      },

    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading spinner while waiting for the stream
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is signed in, fetch their Firestore document
          final user = snapshot.data;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                // Show loading spinner while waiting for Firestore data
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (docSnapshot.hasError) {
                // Handle Firestore error
                return const Scaffold(
                  body: Center(child: Text("Error loading user data")),
                );
              } else if (docSnapshot.hasData) {
                final userDoc = docSnapshot.data!;
                if (userDoc.exists) {
                  // Fetch and update selected document
                  final selectedDocument = userDoc.get('document') ?? 'YE'; // Default to 'YE' if null
                  Provider.of<UserProvider>(context, listen: false).updateSelectedDocument(selectedDocument);

                  return Home(); // Navigate to the HomePage
                } else {
                  // User document does not exist
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not found in Firestore")),
                  );
                  return const WelcomeScreen();
                }
              } else {
                return const WelcomeScreen();
              }
            },
          );
        } else {
          // User is not signed in
          return const WelcomeScreen();
        }
      },
    );

  }
}
