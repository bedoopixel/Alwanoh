import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSubadminPage extends StatefulWidget {
  @override
  _AddSubadminPageState createState() => _AddSubadminPageState();
}

class _AddSubadminPageState extends State<AddSubadminPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addSubadmin() async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();
    String country = _countryController.text.trim();
    String city = _cityController.text.trim();
    String phone = _phoneController.text.trim();

    try {
      await _firestore.collection('subadmin').add({
        'id': id,
        'password': password,
        'country': country,
        'city': city,
        'phone': phone,
      });
      // Clear text fields
      _idController.clear();
      _passwordController.clear();
      _countryController.clear();
      _cityController.clear();
      _phoneController.clear();
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subadmin added successfully!')));
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add subadmin.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Primary color as background
      appBar: AppBar(
        title: Text('Add Subadmin'),
        backgroundColor: Colors.black, // Primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField(
                controller: _idController,
                label: 'ID',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _countryController,
                label: 'Country',
                icon: Icons.public,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _addSubadmin,
                child: Text('Add Subadmin'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF88683E), // Secondary color for button background
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Color(0xFF333333),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}
