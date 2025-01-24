import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String? _selectedSize;
  bool _isFavorite = false; // Track favorite state

  Future<void> _addToCart() async {
    if (_selectedSize != null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final String userId = user.uid;
      final productId = widget.product['id'];
      final size = _selectedSize;
      final price = widget.product['price'];
      final name = widget.product['name'];

      final List<String> imageUrls = [
        widget.product['image1'] as String?,
        widget.product['image2'] as String?,
        widget.product['image3'] as String?,
        widget.product['image4'] as String?,
      ].whereType<String>().toList();
      final String? firstImageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .add({
          'productId': productId,
          'name': name,
          'size': size,
          'price': price,
          'image': firstImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added size $size to cart')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to cart: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final product = widget.product;
    final String name = product['name'] ?? 'No Name';
    final String description = product['description'] ?? 'No Description';
    final List<String> imageUrls = [
      product['image1'] as String?,
      product['image2'] as String?,
      product['image3'] as String?,
      product['image4'] as String?,
    ].whereType<String>().toList();
    final double? price = product['price'] != null ? double.tryParse(product['price'].toString()) : null;
    final int rating = (product['rating'] is int) ? product['rating'] : int.tryParse(product['rating']?.toString() ?? '') ?? 0;

    return Scaffold(
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? Styles.darkBackground
          : Styles.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  // Image with border and rounded corners
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.grey, // Set the border color
                        width: 2.0, // Set the border width
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        imageUrls.isNotEmpty ? imageUrls.first : 'https://via.placeholder.com/400',
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Back Icon
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Go back to the previous screen
                      },
                    ),
                  ),
                  // Favorite Icon
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite; // Toggle favorite state
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '$rating (15 reviews)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By-Nike Official',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'DESCRIPTION:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'SIZE:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: ['39', '40', '41', '42', '43'].map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: _selectedSize == size,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSize = selected ? size : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                  // New Design: Price and ADD TO CART Button
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Text(
                          '${price?.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _selectedSize != null ? _addToCart : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                                ? Colors.blue.shade800
                                : Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            textStyle: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          child: Text('ADD TO CART'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}