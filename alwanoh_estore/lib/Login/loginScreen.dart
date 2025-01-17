import 'dart:io'; // For handling files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign In

import '../Main_Screens/HomePage.dart';
import '../Main_Screens/home.dart';
import '../Profile_Pages/EditProfilePage.dart';
import '../Serves/Auth.dart';
import '../Signin/regScreen.dart';
import '../Thems/custom_scaffold.dart';
import '../Thems/styles.dart';
import 'CompleteProfilePage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuthServiec _auth = FirebaseAuthServiec();
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Initialize Google Sign-In

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String _selectedDocument = 'YE'; // Default document

  XFile? _imageFile; // To store the selected image
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  bool _isLoading = false; // For loading indicator

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    namecontroller.dispose();
    phoneController.dispose();
    super.dispose();
  }

  final _formSignupKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
        Expanded(
        flex: 7,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(0.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formSignupKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w900,
                  color: Styles.customColor,
                ),
              ),
              const SizedBox(height: 40.0),

              // Image picker button and preview
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                      : AssetImage('assets/default_profile.png') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Tap to select an image',
                style: TextStyle(color: Styles.customColor),
              ),
              const SizedBox(height: 25.0),

              // Full Name TextFormField
              TextFormField(
                style: TextStyle(color: Styles.customColor),
                controller: namecontroller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Full name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Text('Full Name', style: TextStyle(color: Styles.customColor)),
                  hintText: 'Enter Full Name',
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
              ),
              const SizedBox(height: 25.0),

              // Email TextFormField
              TextFormField(
                style: TextStyle(color: Styles.customColor),
                controller: emailcontroller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Text('Email', style: TextStyle(color: Styles.customColor)),
                  hintText: 'Enter Email',
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
              ),
              const SizedBox(height: 25.0),

              // Password TextFormField
              TextFormField(
                style: TextStyle(color: Styles.customColor),
                controller: passwordcontroller,
                obscureText: true,
                obscuringCharacter: '*',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Text('Password', style: TextStyle(color: Styles.customColor)),
                  hintText: 'Enter Password',
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
              ),
              const SizedBox(height: 25.0),

              // Document Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDocument,
                onChanged: (newValue) {
                  setState(() {
                    _selectedDocument = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem(child: Text('Yemen'), value: 'YE'),
                  DropdownMenuItem(child: Text('Saudi Arabia (KSA)'), value: 'KSA'),
                  DropdownMenuItem(child: Text('United Arab Emirates (UEA)'), value: 'UEA'),
                  DropdownMenuItem(child: Text('Bahrain (BH)'), value: 'BH'),
                ],
                decoration: InputDecoration(
                  label: Text('Select Document', style: TextStyle(color: Styles.customColor)),
                  filled: true,
                  fillColor: Colors.black,
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
              ),
              const SizedBox(height: 25.0),

              // Phone Number TextFormField
              TextFormField(
                style: TextStyle(color: Styles.customColor),
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Phone Number';
                  }
                  if (value.length != 9) {
                    return 'Phone number must be 9 digits';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: Text('Phone Number', style: TextStyle(color: Styles.customColor)),
                  hintText: 'Enter Phone Number',
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
              ),
              const SizedBox(height: 25.0),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Styles.customColor),
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text('Sign up', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 15.0),

              // Navigate to Sign In Screen
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                },
                child: Text(
                    'Already have an account? Sign In',

                style: TextStyle(color: Styles.customColor),
              ),
            ),

            // Google Sign-In Button
            const SizedBox(height: 25.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const FaIcon(FontAwesomeIcons.google, color: Colors.black),
                onPressed: _isLoading ? null : _signInnWithGoogle,
                label: Text(
                  'Sign in with Google',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
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

  // Method to handle image selection
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  // Sign Up method
// Sign Up method with email verification logic
  Future<void> _signup() async {
    if (_formSignupKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: emailcontroller.text.trim(),
            password: passwordcontroller.text.trim());

        // Send email verification
        if (userCredential.user != null && !userCredential.user!.emailVerified) {
          await userCredential.user!.sendEmailVerification();

          // Show verification dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Email Verification Required'),
              content: Text(
                  'A verification email has been sent to your email. Please verify your email and click "Continue" once verified.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _checkEmailVerified(userCredential.user!);
                  },
                  child: Text('Continue'),
                ),
              ],
            ),
          );
        }

        // Save user details to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'fullName': namecontroller.text.trim(),
          'email': emailcontroller.text.trim(),
          'phone': phoneController.text.trim(),
          'document': _selectedDocument,
          'imageUrl': '', // Assume image is optional or default
          'createdAt': FieldValue.serverTimestamp(),
        });

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error occurred')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// Method to check if the email is verified
  Future<void> _checkEmailVerified(User user) async {
    // Periodically check if the email is verified
    bool emailVerified = false;
    while (!emailVerified) {
      await user.reload(); // Reload user to check the verification status
      user = FirebaseAuth.instance.currentUser!;
      emailVerified = user.emailVerified;

      if (!emailVerified) {
        await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds before checking again
      }
    }

    // If email is verified, navigate to the HomePage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Home()),
    );
  }



  // Google Sign-In method
  Future<void> _signInnWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // If the user cancels the sign-in process
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if user is new and save details to Firestore
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': googleUser.displayName,
          'email': googleUser.email,
          'imageUrl': googleUser.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Navigate to HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) =>  CompleteProfilePage(  fullName: googleUser.displayName ?? '',
          email: googleUser.email,
          imageUrl: googleUser.photoUrl,)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
