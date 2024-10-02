import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Thems/styles.dart'; // Import your Styles class

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedType;

  final List<String> addressTypes = ['Home', 'Office', 'Apartment', 'Else'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: Text('Add Address'),
        backgroundColor: Styles.customColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Address Type:', style: TextStyle(fontSize: 16, color: Styles.customColor)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: addressTypes.map((type) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = type; // Set selected type
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: _selectedType == type ? Styles.customColor : Colors.transparent,
                      border: Border.all(color: Styles.customColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: _selectedType == type ? Colors.white : Styles.customColor,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              SizedBox(height: 20),
              TextFormField(
                style: TextStyle(color: Styles.customColor),
                cursorColor: Styles.customColor,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Styles.customColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.customColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Styles.customColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                style: TextStyle(color: Styles.customColor),
                cursorColor: Styles.customColor,
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Styles.customColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.customColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Styles.customColor),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(

                  onPressed: () {
                    if (_formKey.currentState!.validate() && _selectedType != null) {
                      _saveAddress();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all fields.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Styles.customColor),
                    ),
                  ),
                  child: Text('Save Address', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    final User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user == null) {
      // Optionally show an error message or redirect to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in. Please log in to save an address.')),
      );
      return; // Exit the function if the user is not logged in
    }

    String userId = user.uid; // Get the actual user ID from your auth provider


    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('address') // Create a cart collection under each user
        .add({
      'type': _selectedType,
      'description': _descriptionController.text,
      'phone_number': _phoneController.text,
    });

    // Clear form fields after saving
    _descriptionController.clear();
    _phoneController.clear();
    setState(() {
      _selectedType = null;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Address saved successfully!')));

    // Optionally, navigate back or to another page
    Navigator.pop(context);
  }

}
