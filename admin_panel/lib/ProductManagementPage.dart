import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProductManagementPage extends StatefulWidget {
  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String _selectedDocument = 'YE'; // Default to Yemen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Manage Products'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Product')
            .doc(_selectedDocument)
            .collection('Oil') // Change to handle all categories or multiple categories
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred!'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index].data() as Map<String, dynamic>;
              var productId = products[index].id;
              var imageUrl = product['imageUrl'] ?? '';
              var category = product['category'] ?? '';
              var name = product['name'] ?? 'N/A';
              var description = product['description'] ?? 'N/A';
              var price = product['price'] ?? 'N/A';
              var unit = product['unit'] ?? 'mil';

              return Card(
                color: Color(0xFF333333),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      SizedBox(height: 16),
                      Text('Name: $name', style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(height: 8),
                      Text('Description: $description', style: TextStyle(fontSize: 16, color: Colors.white)),
                      SizedBox(height: 8),
                      Text('Price: $price $unit', style: TextStyle(fontSize: 16, color: Colors.white)),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.yellow),
                            onPressed: () {
                              _showUpdateDialog(productId, product);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteProduct(productId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteProduct(String productId) async {
    try {
      // Delete the product from Firestore
      await _firestore
          .collection('Product')
          .doc(_selectedDocument)
          .collection('Oil') // Change to handle all categories or multiple categories
          .doc(productId)
          .delete();

      // Optionally, delete the image from Firebase Storage
      // final imageRef = _storage.refFromURL(product['imageUrl']);
      // await imageRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product deleted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product.')));
    }
  }

  void _showUpdateDialog(String productId, Map<String, dynamic> product) {
    final TextEditingController _nameController = TextEditingController(text: product['name']);
    final TextEditingController _priceController = TextEditingController(text: product['price'].toString());
    final TextEditingController _descriptionController = TextEditingController(text: product['description']);
    String _unit = product['unit'] ?? 'mil';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _unit,
                  onChanged: (value) {
                    setState(() {
                      _unit = value!;
                    });
                  },
                  items: ['mil', 'kilo'].map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Unit',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _firestore
                      .collection('Product')
                      .doc(_selectedDocument)
                      .collection('Oil') // Change to handle all categories or multiple categories
                      .doc(productId)
                      .update({
                    'name': _nameController.text,
                    'price': double.tryParse(_priceController.text) ?? 0,
                    'description': _descriptionController.text,
                    'unit': _unit,
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product updated successfully!')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update product.')));
                }
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
