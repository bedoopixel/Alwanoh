import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Home_Page.dart';

class AdminSignInPage extends StatefulWidget {
  @override
  _AdminSignInPageState createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends State<AdminSignInPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _errorMessage = '';

  Future<void> _signIn() async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Query the Firestore collection to find a matching admin
      QuerySnapshot snapshot = await _firestore
          .collection('admin')
          .where('id', isEqualTo: id)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHomePage()));
      } else {
        setState(() {
          _errorMessage = 'Invalid ID or Password';
        });
      }
    } catch (e) {
      print('Error: $e'); // Log the error to console for debugging
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set primary color as background
      appBar: AppBar(
        title: Text('Admin Sign In'),
        backgroundColor: Colors.black, // Primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ID Input Field
            TextField(
              controller: _idController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'ID',
                labelStyle: TextStyle(color: Color(0xFF88683E)), // Secondary color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF88683E)), // Border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF88683E)), // Focused border
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Password Input Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFF88683E)), // Secondary color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF88683E)), // Border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF88683E)), // Focused border
                ),
              ),
            ),
            SizedBox(height: 24.0),
            // Sign In Button
            ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF88683E), // Secondary color
                onPrimary: Colors.black, // Text color
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                'Sign In',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16.0),
            // Error Message Display
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
