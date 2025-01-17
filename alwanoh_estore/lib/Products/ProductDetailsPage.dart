import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Color primaryColor = Colors.black;
  final Color secondaryColor = Color(0xFF88683E);
  final Color customColor = Color(0xFF88683E); // Define your custom color

  ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late PageController _pageController;
  String? _selectedQuantity;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  Future<void> _addToCart() async {
    if (_selectedQuantity != null) {
      // Get the current user ID from Firebase Authentication
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Extract necessary data for Firestore
      final String userId = user.uid;
      final productId = widget.product['id'];
      final quantity = _selectedQuantity;
      final price = widget.product['quantities'][quantity];
      final name = widget.product['name'];

      // Select the first image
      final List<String> imageUrls = [
        widget.product['image1'] as String?,
        widget.product['image2'] as String?,
        widget.product['image3'] as String?,
        widget.product['image4'] as String?,
      ].whereType<String>().toList();
      final String? firstImageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;

      // Add product to the Firestore collection for the specific user
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart') // Create a cart collection under each user
            .add({
          'productId': productId,
          'name': name,
          'quantity': quantity,
          'price': price,
          'image': firstImageUrl, // Add the first image to the cart document
          'timestamp': FieldValue.serverTimestamp(), // Add timestamp for tracking
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $quantity to cart')),
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

    // Extract product details
    final product = widget.product;
    final String name = product['name'] ?? 'No Name';
    final String type = product['type'] ?? 'Unknown';
    final String description = product['description'] ?? 'No Description';
    final List<String> imageUrls = [
      product['image1'] as String?,
      product['image2'] as String?,
      product['image3'] as String?,
      product['image4'] as String?,
    ].whereType<String>().toList();
    final double? price = product['price'] != null ? double.tryParse(product['price'].toString()) : null;
    final double? discountedPrice = product['discountedPrice'] != null ? double.tryParse(product['discountedPrice'].toString()) : null;
    final int rating = (product['rating'] is int) ? product['rating'] : int.tryParse(product['rating']?.toString() ?? '') ?? 0;
    final String unit = product['unit'] ?? 'N/A';
    final String? discount = product['discount']?.toString();
    final Map<String, dynamic>? quantities = product['quantities'] as Map<String, dynamic>?;

    // Format quantities into a list
    List<MapEntry<String, dynamic>> quantityEntries = [];
    if (quantities != null) {
      quantityEntries = quantities.entries.toList();
    }

    // Get the price for the selected quantity
    double? selectedQuantityPrice = _selectedQuantity != null && quantities != null
        ? double.tryParse(quantities[_selectedQuantity]?.toString() ?? '')
        : null;

    return Scaffold(
      backgroundColor:themeProvider.themeMode == ThemeMode.dark
          ? Styles.darkBackground // Dark mode background
          : Styles.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: widget.customColor, // Set the border color
                    width: 2.0, // Set the border width
                  ),
                ),
                child: Column( // Removed Expanded here to prevent conflict with SingleChildScrollView
                  children: [
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, color: widget.secondaryColor),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: widget.secondaryColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 48), // Placeholder for alignment
                        ],
                      ),
                    ),
                    // Display images with border radius and border color
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        height: 250.0,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: imageUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    child: Image.network(
                                      imageUrls[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity, // Make the image take the full width of the container
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 5.0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: SmoothPageIndicator(
                                  controller: _pageController,
                                  count: imageUrls.length,
                                  effect: WormEffect(
                                    dotHeight: 8.0,
                                    dotWidth: 8.0,
                                    spacing: 16.0,
                                    radius: 12.0,
                                    dotColor: Colors.grey,
                                    activeDotColor: widget.customColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 15.0),
                  if (discount != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 5, left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.customColor, // Set the border color
                                width: 2.0, // Set the border width
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$discount% ',
                                  style: TextStyle(fontSize: 14.0, color: widget.customColor),
                                ),
                                Icon(Icons.local_offer_outlined, color: widget.customColor, size: 15),
                              ],
                            ),
                          ),
                          Text(
                            type,
                            style: TextStyle(fontSize: 20.0, color: widget.customColor, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  if (discount == null)
                    Padding(
                      padding: const EdgeInsets.only(right: 5, left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            type,
                            style: TextStyle(fontSize: 20.0, color: widget.secondaryColor, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 15.0),
                  Text(
                    description,
                    textAlign: TextAlign.right, // Aligns the text to the right
                    style: TextStyle(
                      fontSize: 18.0,
                      color: widget.secondaryColor,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Display price and discounted price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_selectedQuantity != null) ...[
                        Text(
                          '${quantities![_selectedQuantity]} YER',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: widget.customColor),
                        ),
                      ] else ...[
                        Text(
                          ' ${price?.toStringAsFixed(0) ?? 'N/A'} YER',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          '${discountedPrice?.toStringAsFixed(0)} YER',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: widget.customColor),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    ' ${'★' * rating}${'☆' * (5 - rating)}',
                    style: TextStyle(fontSize: 14.0, color: widget.customColor),
                  ),
                  SizedBox(height: 8.0),
                  // Display quantities as a list
                  if (quantityEntries.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        'Select Quantity:',
                        style: TextStyle(fontSize: 16.0, color: widget.secondaryColor),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    SizedBox(
                      height: 60.0, // Adjust the height as needed
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: quantityEntries.map((entry) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedQuantity = entry.key;
                                });
                              },
                              child: Container(
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                padding: const EdgeInsets.all(9.0),
                                decoration: BoxDecoration(
                                  color: _selectedQuantity == entry.key ? widget.customColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: widget.customColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '${entry.key}مل ',
                                  style: TextStyle(
                                    color: _selectedQuantity == entry.key ? Colors.white : widget.customColor,
                                  ),
                                  textDirection: TextDirection.rtl, // For RTL layout
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for Add to Cart
      floatingActionButton: _selectedQuantity != null
          ? Padding(
        padding: const EdgeInsets.only(left:30 , right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            SizedBox(height: 8.0), // Space between price and button
            FloatingActionButton.extended(
              backgroundColor: widget.customColor,
              onPressed: _addToCart, // Call the add to cart function
              icon: Icon(Icons.shopping_cart,color: Colors.black,),
              label: Text('Add to Cart',style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      )
          : FloatingActionButton.extended(
        backgroundColor: widget.customColor,
        onPressed: null, // Disable if no quantity is selected
        icon: Icon(Icons.shopping_cart_outlined,color: Colors.black,),
        label: Text('Add to Cart',style: TextStyle(color: Colors.black),),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Position the FAB at the bottom center
    );
  }
}
