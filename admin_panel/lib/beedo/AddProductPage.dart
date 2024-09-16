import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AddBProductPage extends StatefulWidget {
  @override
  _AddBProductPageState createState() => _AddBProductPageState();
}

class _AddBProductPageState extends State<AddBProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Oil';
  String _selectedDocument = 'Yemen'; // Default to Yemen
  String _selectedUnit = 'mil';
  File? _image;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addProduct() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image.')));
      return;
    }

    String name = _nameController.text.trim();
    String price = _priceController.text.trim();
    String description = _descriptionController.text.trim();
    String category = _selectedCategory;
    String unit = _selectedUnit;

    try {
      // Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('product_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Add product details to Firestore under the selected document and category
      await _firestore
          .collection('Product')
          .doc(_selectedDocument)
          .collection(_selectedCategory)
          .add({
        'name': name,
        'price': price,
        'description': description,
        'unit': unit,
        'imageUrl': imageUrl,
      });

      // Clear text fields and image
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _image = null;
        _selectedCategory = 'Oil';
        _selectedDocument = 'Yemen';
        _selectedUnit = 'mil';
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully!')));
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add product.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown for selecting document
            DropdownButtonFormField<String>(
              value: _selectedDocument,
              onChanged: (value) {
                setState(() {
                  _selectedDocument = value!;
                });
              },
              items: ['Yemen', 'KSA', 'UEA', 'BH'].map((document) {
                return DropdownMenuItem(
                  value: document,
                  child: Text(document, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select Document',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            // Dropdown for selecting category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              items: ['Oil', 'Honey'].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: TextStyle(color: Colors.white),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
              },
              items: ['mil', 'kilo'].map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Unit',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                color: Color(0xFF333333),
                child: _image == null
                    ? Center(child: Text('Tap to select image', style: TextStyle(color: Colors.white)))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Add Product'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF88683E),
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
