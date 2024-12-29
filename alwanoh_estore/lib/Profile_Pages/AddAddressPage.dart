import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Thems/styles.dart';
import 'LocationPickerPage.dart';

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedType;
  LatLng? _selectedLocation;

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
          child: SingleChildScrollView(
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
                        _selectedType = type;
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
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final LatLng? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPickerPage(
                          initialLocation: _selectedLocation, // Pass the existing location if available
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedLocation = result;
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Styles.customColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedLocation != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation!,
                          zoom: 14.0,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('selected-location'),
                            position: _selectedLocation!,
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      ),
                    )
                        : Center(
                      child: Text(
                        'Pick Location',
                        style: TextStyle(color: Styles.customColor),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedType != null &&
                          _selectedLocation != null) {
                        _saveAddress();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all fields and select a location.')),
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
      ),
    );
  }

  void _saveAddress() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in. Please log in to save an address.')),
      );
      return;
    }

    String userId = user.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('address')
        .add({
      'type': _selectedType,
      'description': _descriptionController.text,
      'phone_number': _phoneController.text,
      'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
    });

    _descriptionController.clear();
    _phoneController.clear();
    setState(() {
      _selectedType = null;
      _selectedLocation = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Address saved successfully!')));
    Navigator.pop(context);
  }
}
