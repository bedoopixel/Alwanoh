import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../Login/loginScreen.dart';
import '../Serves/Auth.dart';
import '../Signin/regScreen.dart';
import '../Thems/styles.dart';
import '../Serves/UserProvider.dart';
import 'HomePage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FirebaseAuthServiec _auth = FirebaseAuthServiec();
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  Future<void> _loadImage() async {
    try {
      // Get the download URL for the image from Firebase Storage
      String downloadURL = await FirebaseStorage.instance
          .refFromURL('gs://alwanoh-store.appspot.com/Home/p1.png')
          .getDownloadURL();

      setState(() {
        imageUrl = downloadURL; // Set the fetched URL to imageUrl
      });
    } catch (e) {
      print('Error fetching image from Firebase Storage: $e');
    }
  }


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
                         Padding(
        padding: const EdgeInsets.only(top: 75.0),
        child: imageUrl == null
            ? const CircularProgressIndicator() // Show a loader until the image is fetched
            : Image.network(
          imageUrl!,
          fit: BoxFit.contain,
          width: 200,
          height: 200,
        ),
                         ),
             SizedBox(height: 50),
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
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Styles.customColor),
                ),
                child: Center(
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Styles.customColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
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
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Styles.customColor),
                ),
                child: Center(
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Styles.customColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _signInAsGuest,
              child: Container(
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Styles.customColor),
                ),
                child: Center(
                  child: Text(
                    'LOGIN AS GUEST',
                    style: TextStyle(
                      fontSize: 15,
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
                    // Add Apple login logic here
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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      String selectedDocument = 'YE';

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName,
          'document': selectedDocument,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("New user document created.")));
      } else {
        selectedDocument = userDoc.get('document') ?? 'YE';
      }

      Provider.of<UserProvider>(context, listen: false).updateSelectedDocument(selectedDocument);

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

  void _signInAsGuest() async {
    // Sign out any currently logged-in user
    await FirebaseAuth.instance.signOut();

    // Generate a unique identifier for guest users
    String guestUserId = DateTime.now().millisecondsSinceEpoch.toString();
    String selectedDocument = 'YE'; // Default document for guests

    // Clear existing user data in UserProvider
    Provider.of<UserProvider>(context, listen: false).clearUserData();

    // Update the UserProvider with the default document
    Provider.of<UserProvider>(context, listen: false).updateSelectedDocument(selectedDocument);

    // Optionally save guest data to Firestore if needed
    // await FirebaseFirestore.instance.collection('guests').doc(guestUserId).set({
    //   'document': selectedDocument,
    //   // Additional guest data can go here
    // });

    // Navigate to HomePage directly without authentication
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }



}
