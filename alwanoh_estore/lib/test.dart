// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// // Add other necessary imports here...
//
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   // Other members remain the same...
//
//   final GoogleSignIn _googleSignIn = GoogleSignIn(); // Google Sign-In instance
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 7,
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(25.0, 80.0, 25.0, 20.0),
//               decoration: const BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(0.0),
//                   topRight: Radius.circular(0.0),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formSignupKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Get Started',
//                         style: TextStyle(
//                           fontSize: 30.0,
//                           fontWeight: FontWeight.w900,
//                           color: Styles.customColor,
//                         ),
//                       ),
//                       const SizedBox(height: 40.0),
//
//                       // Existing widgets...
//
//                       // Sign Up Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Styles.customColor,
//                           ),
//                           onPressed: _signup,
//                           child: Text('Sign up', style: TextStyle(color: Colors.black)),
//                         ),
//                       ),
//                       const SizedBox(height: 30.0),
//
//                       // Google Sign-In Button
//                       GestureDetector(
//                         onTap: _signInWithGoogle,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 15.0),
//                           decoration: BoxDecoration(
//                             color: Styles.customColor,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           width: double.infinity,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const FaIcon(FontAwesomeIcons.google, color: Colors.white),
//                               const SizedBox(width: 10.0),
//                               Text('Sign in with Google', style: TextStyle(color: Colors.white)),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 30.0),
//
//                       // Already have an account...
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text('Already have an account?', style: TextStyle(color: Styles.customColor)),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (e) => const SignInScreen(),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               'Sign in',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Styles.customColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20.0),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Other methods remain the same...
//
//   // Google Sign-In method
//   Future<void> _signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return; // The user canceled the sign-in
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       // Create a new credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       // Sign in to Firebase with the Google credentials
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//       User? user = userCredential.user;
//
//       // Store user data in Firestore
//       if (user != null) {
//         await _storeUserData(user.uid, user.displayName ?? '', user.email ?? '', '', null);
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google account created successfully")));
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HomePage(),
//           ),
//         );
//       }
//     } catch (e) {
//       print("Google sign-in failed: $e");
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google sign-in failed")));
//     }
//   }
//
//   // Store user data in Firestore
//   Future<void> _storeUserData(String uid, String name, String email, String phoneNumber, String? imageUrl) async {
//     CollectionReference users = FirebaseFirestore.instance.collection('users');
//
//     await users.doc(uid).set({
//       'name': name,
//       'email': email,
//       'phoneNumber': phoneNumber,
//       'document': _selectedDocument, // Store selected document
//       'imageUrl': imageUrl,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }
// }
