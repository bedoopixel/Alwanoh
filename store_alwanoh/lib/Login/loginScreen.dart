import 'dart:io'; // For handling files
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../Main_Screens/HomePage.dart';
import '../Serves/Auth.dart';
import '../Signin/regScreen.dart';
import '../Thems/custom_scaffold.dart';
import '../Thems/styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuthServiec _auth = FirebaseAuthServiec();

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String _selectedDocument = 'YE'; // Default document

  XFile? _imageFile; // To store the selected image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

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
                        style: TextStyle(color: Styles.customColor,),
                      ),
                      const SizedBox(height: 25.0),

                      // Full Name TextFormField
                      TextFormField(
                        style: TextStyle(color: Styles.customColor,),
                        controller: namecontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: Text('Full Name', style: TextStyle(color: Styles.customColor,)),
                          hintText: 'Enter Full Name',
                          hintStyle: TextStyle(color: Styles.customColor,),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Email TextFormField
                      TextFormField(
                        style: TextStyle(color: Styles.customColor,),
                        controller: emailcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: Text('Email', style: TextStyle(color: Styles.customColor,)),
                          hintText: 'Enter Email',
                          hintStyle: TextStyle(color: Styles.customColor,),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Password TextFormField
                      TextFormField(
                        style: TextStyle(color: Styles.customColor,),
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
                          label: Text('Password', style: TextStyle(color: Styles.customColor,)),
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(color: Styles.customColor,),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
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
                          label: Text('Select Document', style: TextStyle(color: Styles.customColor,)),
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Phone Number TextFormField
                      TextFormField(
                        style: TextStyle(color: Styles.customColor,),
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
                          label: Text('Phone Number', style: TextStyle(color: Styles.customColor,)),
                          hintText: 'Enter Phone Number',
                          hintStyle: TextStyle(color: Styles.customColor,),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Styles.customColor,),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Styles.customColor,),
                          onPressed: _signup,
                          child: Text('Sign up', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?', style: TextStyle(color: Styles.customColor,)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Styles.customColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0,),

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


  // Image Picker function
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = pickedFile;
    });
  }

  // Sign Up function with image upload
  void _signup() async {
    String email = emailcontroller.text;
    String password = passwordcontroller.text;
    String name = namecontroller.text;
    String phoneNumber = phoneController.text;

    if (_formSignupKey.currentState!.validate() && _imageFile != null) {
      User? user = await _auth.sginupWithEmailAndPAssword(email, password);
      if (user != null) {
        String? imageUrl = await _uploadImage(user.uid);
        await _storeUserData(user.uid, name, email, phoneNumber, imageUrl);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User created successfully")));
      } else {
        print("Sign up failed");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields and select an image")));
    }
  }

  // Image upload function
  Future<String?> _uploadImage(String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images').child('$uid.jpg');
      UploadTask uploadTask = storageRef.putFile(File(_imageFile!.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Storing user data in Firestore with image URL
  Future<void> _storeUserData(String uid, String name, String email, String phoneNumber, String? imageUrl) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    await users.doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'document': _selectedDocument, // Store selected document
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

}
