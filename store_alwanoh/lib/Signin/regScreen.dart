import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseAuthServiec _auth = FirebaseAuthServiec(); // _auth initialized here

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordlcontroller = TextEditingController();

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordlcontroller.dispose();
    super.dispose();
  }

  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          SizedBox(height: 0),
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
                      TextFormField(
                        controller: emailcontroller,
                        style: TextStyle(color: Styles.customColor),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email', style: TextStyle(color: Styles.customColor)),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(color: Styles.customColor),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Styles.customColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Styles.customColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Styles.customColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        style: TextStyle(color: Styles.customColor),
                        controller: passwordlcontroller,
                        cursorColor: Styles.customColor,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password', style: TextStyle(color: Styles.customColor)),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Styles.customColor),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Styles.customColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Styles.customColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Styles.customColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      GestureDetector(
                        onTap: _sginin,
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
                      ),
                      const SizedBox(height: 25.0),
                      Row(
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
                                  builder: (e) => const SignUpScreen(),
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

  // Sign-in method with provider changes
  void _sginin() async {
    String email = emailcontroller.text;
    String password = passwordlcontroller.text;

    if (_formSignInKey.currentState!.validate()) {
      User? user = await _auth.sginINWithEmailAndPAssword(email, password);
      if (user != null) {
        // Fetch user document to get selectedDocument
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign in failed")));
      }
    }
  }
}
