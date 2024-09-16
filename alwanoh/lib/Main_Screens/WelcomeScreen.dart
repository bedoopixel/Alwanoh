import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; // Import provider

import '../Login/loginScreen.dart';
import '../Serves/Auth.dart';
import '../Signin/regScreen.dart';
import '../Thems/styles.dart';
import '../Serves/UserProvider.dart'; // Import UserProvider
import 'HomePage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FirebaseAuthServiec _auth = FirebaseAuthServiec();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 200.0),
              child: Image(
                image: AssetImage(
                  'assets/p1.png',
                ),
                fit: BoxFit.contain,
                width: 250,
                height: 250,
              ),
            ),
            const SizedBox(height: 100),
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 30,
                color: Styles.customColor,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              },
              child: Container(
                height: 53,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Styles.customColor),
                ),
                child: Center(
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Styles.customColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
              },
              child: Container(
                height: 53,
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Styles.customColor),
                ),
                child: Center(
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Styles.customColor,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Login with Social Media',
              style: TextStyle(
                fontSize: 17,
                color: Styles.customColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google),
                  color: Styles.customColor,
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebookF),
                  color: Styles.customColor,
                  onPressed: () {
                    // Add Facebook login logic here
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.apple),
                  color: Styles.customColor,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ));
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _signInWithGoogle() async {
    User? user = await _auth.signInWithGoogle();
    if (user != null) {
      // Fetch user document to get selectedDocument
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      String selectedDocument = 'YE'; // Default value

      if (!userDoc.exists) {
        // Create a new document for the user
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName,
          'document': selectedDocument, // Default to 'YE' or any other default value
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("New user document created.")));
      } else {
        // Fetch existing document value
        selectedDocument = userDoc.get('document') ?? 'YE'; // Default to 'YE' if null
      }

      // Update the UserProvider with the selectedDocument
      Provider.of<UserProvider>(context, listen: false).updateSelectedDocument(selectedDocument);

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign in failed")));
    }
  }
}
