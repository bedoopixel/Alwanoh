import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Serves/UserProvider.dart';
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
    if (_selectedQuantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a quantity before adding to cart.')),
      );
      return;
    }

    // Get the current user ID from Firebase Authentication
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    // Access the selected country from the UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? selectedCountry = userProvider.selectedDocument;

    if (selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a country first.')),
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
        'country': selectedCountry, // Include the selected country
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp for tracking
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $quantity of $name to cart for $selectedCountry')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
      );
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
    final parsedRating = (rating is int) ? rating : int.tryParse(rating?.toString() ?? '') ?? 0;
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
                ),
                child: Column( // Removed Expanded here to prevent conflict with SingleChildScrollView
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: widget.secondaryColor),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          name,
                          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: widget.secondaryColor),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(onPressed: (){}, icon: Icon(Icons.favorite_border,color:widget.secondaryColor ,))
                      ],
                    ),
                    // Display images with border radius and border color
                    Container(
                      height: 250.0,
                      child: Stack(
                        children: [
                          // Image with border and rounded corners
                          Container(
                            decoration: BoxDecoration(
                              color: Styles.customColor50,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                color: Colors.grey, // Set the border color
                                width: 2.0, // Set the border width
                              ),
                            ),
                            child:   PageView.builder(
                              controller: _pageController,
                              itemCount: imageUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Container(
                                    child: Image.network(
                                      imageUrls[index],
                                      fit: BoxFit.contain,
                                      width: double.infinity, // Make the image take the full width of the container
                                    ),
                                  ),
                                );
                              },
                            ),

                          ),
                          // Back Icon
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
                          // Favorite Icon
                        ],
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                parsedRating > 0 ? Icons.star_rounded : Icons.star_border_rounded,
                                color: Styles.customColor,
                                size: 20,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '$parsedRating.5',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  color: Styles.customColor,
                                ),
                              ),
                            ],
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                parsedRating > 0 ? Icons.star_rounded : Icons.star_border_rounded,
                                color: Styles.customColor,
                                size: 20,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '$parsedRating.5',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  color: Styles.customColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 15.0),
                  Text(
                    ':الوصف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  Text(
                    description,
                    textAlign: TextAlign.right, // Aligns the text to the right
                    style: TextStyle(
                      fontSize: 16.0,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                  () {
                                // Ensure we are not null and handle the quantities map and activeQuantity safely
                                if (product['quantities'] != null && product['activeQuantity'] != null) {
                                  final activeQuantity = product['activeQuantity'].toString(); // Ensure activeQuantity is a String
                                  final quantities = product['quantities'] as Map<dynamic, dynamic>; // Handle dynamic keys and values

                                  // Check if the quantities map contains the activeQuantity key
                                  if (quantities.containsKey(activeQuantity)) {
                                    final activePrice = quantities[activeQuantity]; // Get the price for activeQuantity
                                    if (activePrice is num) {
                                      return '${activePrice.toStringAsFixed(0)}\YER'; // Return the price as a string with fixed decimals
                                    }
                                  }
                                }
                                // Fallback to discounted price or regular price
                                return discountedPrice != null
                                    ? '${discountedPrice.toStringAsFixed(0)}\YER'
                                    : '${price?.toStringAsFixed(0) ?? '0'}\YER';
                              }(),
                              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: widget.customColor),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.0),

                      ],
                    ],
                  ),
                  SizedBox(height: 8.0),

                  SizedBox(height: 8.0),
                  // Display quantities as a list
                  if (quantityEntries.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        ' :الكمية',
                        style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold, color: widget.secondaryColor),
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
                              child:Container(
                                height: 40,
                                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: ChoiceChip(
                                    label: Text(
                                      '${entry.key}', // Use the entry.key value
                                      style: TextStyle(
                                        color: _selectedQuantity == entry.key ? Colors.white : Colors.white, // White text for both states
                                      ),
                                    ),
                                    selected: _selectedQuantity == entry.key, // Check if this chip is selected
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedQuantity = selected ? entry.key : null; // Update the selected value
                                      });
                                    },
                                    backgroundColor: Styles.customColor, // Red background for unselected state
                                    selectedColor: Styles.customColor, // Green background for selected state
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Match the container's border radius
                                      side: BorderSide(color: Styles.customColor), // Remove the default border
                                    ),

                                    padding: EdgeInsets.symmetric(horizontal: 12.0), // Add padding to center the text
                                    labelPadding: EdgeInsets.zero, // Remove extra padding around the label
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target size
                                  ),
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
        padding: const EdgeInsets.only(left: 50, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 8.0), // Space between price and button
            FloatingActionButton.extended(
              backgroundColor: widget.customColor,
              onPressed: _addToCart, // Call the add to cart function
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              label: Text('Add to Cart', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      )
          : FloatingActionButton.extended(
        backgroundColor: widget.customColor,
        onPressed: () {
          // If no quantity is selected, show an alert
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a quantity before adding to cart.')),
          );
        },
        icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
        label: Text('Add to Cart', style: TextStyle(color: Colors.black)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,


      // Position the FAB at the bottom center
    );
  }
}
