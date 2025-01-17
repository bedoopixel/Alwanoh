import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Main_Screens/HomePage.dart';
import '../Main_Screens/home.dart';
import '../Thems/styles.dart'; // Ensure this path is correct

class CompleteProfilePage extends StatefulWidget {
  final String fullName;
  final String email;
  final String? imageUrl;

  const CompleteProfilePage({
    Key? key,
    required this.fullName,
    required this.email,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;

  TextEditingController phoneController = TextEditingController();
  String? selectedDocument;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _uploadProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Do nothing if form is invalid
    }

    User? user = _auth.currentUser;
    if (user != null) {
      String? uploadedImageUrl = widget.imageUrl;

      if (_imageFile != null) {
        // Upload the new image
        try {
          final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
          UploadTask uploadTask = storageRef.putFile(File(_imageFile!.path));
          TaskSnapshot taskSnapshot = await uploadTask;
          uploadedImageUrl = await taskSnapshot.ref.getDownloadURL();
        } catch (e) {
          print('Error uploading image: $e');
        }
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': widget.fullName,
        'email': widget.email,
        'imageUrl': uploadedImageUrl,
        'phoneNumber': phoneController.text,
        'document': selectedDocument,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile completed successfully")),
      );

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
                  'Complete Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 48), // Placeholder for spacing
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : widget.imageUrl != null
                        ? NetworkImage(widget.imageUrl!) as ImageProvider
                        : const AssetImage('assets/default_profile.png'),
                    radius: 60,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: widget.fullName,
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Enter your phone number',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedDocument,
              onChanged: (value) {
                setState(() {
                  selectedDocument = value;
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text('Yemen', style: TextStyle(color: Colors.white)),
                  value: 'YE',
                ),
                DropdownMenuItem(
                  child: Text('Saudi Arabia', style: TextStyle(color: Colors.white)),
                  value: 'KSA',
                ),
                DropdownMenuItem(
                  child: Text('United Arab Emirates', style: TextStyle(color: Colors.white)),
                  value: 'UAE',
                ),
                DropdownMenuItem(
                  child: Text('Bahrain', style: TextStyle(color: Colors.white)),
                  value: 'BH',
                ),
              ],
              decoration: InputDecoration(
                labelText: 'Document',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              dropdownColor: Colors.black,
              validator: (value) {
                if (value == null) {
                  return 'Please select a document';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _uploadProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
