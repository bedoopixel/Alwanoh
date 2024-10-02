import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Login/loginScreen.dart';
import '../Main_Screens/HomePage.dart';
import '../Serves/Auth.dart';
import '../Serves/UserProvider.dart';
import '../Thems/custom_scaffold.dart';
import '../Thems/styles.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuthServiec _auth = FirebaseAuthServiec();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formSignInKey = GlobalKey<FormState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 80.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0.0),
                  topRight: Radius.circular(0.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Styles.customColor,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      _buildTextFormField(
                        controller: emailController,
                        label: 'Email',
                        hint: 'Enter Email',
                        isObscure: false,
                      ),
                      const SizedBox(height: 25.0),
                      _buildTextFormField(
                        controller: passwordController,
                        label: 'Password',
                        hint: 'Enter Password',
                        isObscure: true,
                      ),
                      const SizedBox(height: 25.0),
                      _buildSignInButton(),
                      const SizedBox(height: 15.0),
                      _buildGoogleSignInButton(),
                      const SizedBox(height: 25.0),
                      _buildSignUpPrompt(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build text form field
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isObscure,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Styles.customColor),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        label: Text(label, style: TextStyle(color: Styles.customColor)),
        hintText: hint,
        hintStyle: TextStyle(color: Styles.customColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Styles.customColor),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Styles.customColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Styles.customColor),
        ),
      ),
      obscureText: isObscure,
      obscuringCharacter: '*',
    );
  }

  // Sign-in button
  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _signIn,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: Styles.customColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            "Sign in",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Google Sign-In button
  Widget _buildGoogleSignInButton() {
    return  Row(
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
    );
  }

  // Sign-up prompt
  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account? ',
          style: TextStyle(color: Styles.customColor),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpScreen(),
              ),
            );
          },
          child: Text(
            'Sign up',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Styles.customColor,
            ),
          ),
        ),
      ],
    );
  }

  // Sign-in method with email and password
  void _signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (_formSignInKey.currentState!.validate()) {
      User? user = await _auth.sginupWithEmailAndPAssword(email, password); // Use the correct method for signing in
      if (user != null) {
        // Check if email is verified
        if (user.emailVerified) {
          // Fetch user document to get selectedDocument
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            String selectedDocument = userDoc.get('document') ?? 'YE'; // Default to 'YE' if null

            // Update the selectedDocument in the provider
            Provider.of<UserProvider>(context, listen: false).updateSelectedDocument(selectedDocument);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign in successful")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not found in Firestore")));
          }
        } else {
          // Email is not verified, ask the user to verify their email
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please verify your email before signing in."),
            ),
          );

          // Optionally, send a new verification email
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("A new verification email has been sent to ${user.email}."),
            ),
          );

          // Optionally, sign the user out
          await _auth.signOut();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign in failed")));
      }
    }
  }


  // Method to sign in with Google
// Method to sign in with Google
  void _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      print("Google User: $googleUser"); // Log Google user info

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Google Auth: $googleAuth"); // Log authentication info

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      print("Firebase User: ${user?.toString()}"); // Log Firebase user info

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        print("User Document: ${userDoc.data()}"); // Log Firestore document data

        if (userDoc.exists) {
          String selectedDocument = userDoc.get('document') ?? 'YE'; // Default to 'YE' if null

          // Update provider
          Provider.of<UserProvider>(context, listen: false).updateSelectedDocument(selectedDocument);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google sign in successful")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not found in Firestore")));
        }
      }
    } catch (e) {
      print("Error during Google sign in: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google sign in failed: ${e.toString()}")));
    }
  }



}
