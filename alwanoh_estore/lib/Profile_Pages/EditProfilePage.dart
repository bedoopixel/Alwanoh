import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Serves/UserProvider.dart'; // Ensure this path is correct
import '../Thems/styles.dart'; // Import your styles if needed

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        nameController.text = userDoc.get('name') ?? '';
        emailController.text = userDoc.get('email') ?? '';
        phoneController.text = userDoc.get('phoneNumber') ?? '';
        currentImageUrl = userDoc.get('imageUrl');
        String? document = userDoc.get('document');
        context.read<UserProvider>().updateSelectedDocument(document); // Update the provider
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      await _uploadImage(); // Upload the image after picking
    }
  }

  Future<void> _uploadImage() async {
    User? user = _auth.currentUser;
    if (user != null && _imageFile != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
        UploadTask uploadTask = storageRef.putFile(File(_imageFile!.path));
        TaskSnapshot taskSnapshot = await uploadTask;
        final imageUrl = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          currentImageUrl = imageUrl;
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'imageUrl': currentImageUrl,
        'document': context.read<UserProvider>().selectedDocument,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? selectedDocument = context.watch<UserProvider>().selectedDocument;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.only(top: 50),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_outlined, color: Styles.customColor,),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Styles.customColor,
                ),
              ),
              SizedBox(width: 48), // Placeholder for spacing
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: currentImageUrl != null
                      ? NetworkImage(currentImageUrl!)
                      : AssetImage('assets/default_profile.png') as ImageProvider,
                  radius: 60,
                ),
                Positioned(
                  bottom: 0,
                  right: 45,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt_outlined, color: Styles.customColor,),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          TextField(
            style: TextStyle(color: Styles.customColor,),
            controller: nameController,
            decoration: InputDecoration(
                label: const Text('Name',style: TextStyle(color: Styles.customColor,),),
                hintText: 'Enter Name',
                hintStyle: const TextStyle(
                  color: Styles.customColor,
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Styles.customColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Styles.customColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Styles.customColor,))
            ),
          ),
          SizedBox(height: 20),
          TextField(
            style: TextStyle(color: Styles.customColor,),
            controller: emailController,
            decoration: InputDecoration(
                label: const Text('Email',style: TextStyle(color: Styles.customColor,),),
                hintText: 'Enter Email',
                hintStyle: const TextStyle(
                  color: Styles.customColor,
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Styles.customColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Styles.customColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Styles.customColor,))
            ),
          ),
          SizedBox(height: 20),
          TextField(
            style: TextStyle(color: Styles.customColor,),
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                label: const Text('Phone Number',style: TextStyle(color: Styles.customColor,),),
                hintText: 'Enter Phone Number',
                hintStyle: const TextStyle(
                  color: Styles.customColor,
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Styles.customColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Styles.customColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Styles.customColor,))
            ),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            borderRadius: BorderRadius.circular(10),
            value: selectedDocument,
            onChanged: (newValue) {
              context.read<UserProvider>().updateSelectedDocument(newValue);
            },
            items: [
              DropdownMenuItem(child: Text('Yemen', style: TextStyle(color: Styles.customColor,),), value: 'YE'),
              DropdownMenuItem(child: Text('Saudi Arabia', style: TextStyle(color: Styles.customColor,),), value: 'KSA'),
              DropdownMenuItem(child: Text('United Arab Emirates', style: TextStyle(color: Styles.customColor,),), value: 'UAE'),
              DropdownMenuItem(child: Text('Bahrain', style: TextStyle(color: Styles.customColor,),), value: 'BH'),
            ],
            decoration: InputDecoration(
              label: Text('Document', style: TextStyle(color: Styles.customColor,)),
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
            dropdownColor: Colors.black,
          ),
          SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Styles.customColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
