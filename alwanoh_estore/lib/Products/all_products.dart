import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../Serves/UserProvider.dart';
import '../../Thems/styles.dart';
import '../Thems/ThemeProvider.dart';
import 'ProductDetailsPage.dart';


class AllProducts extends StatefulWidget {
  final String searchQuery;
  final List<Map<String, dynamic>> products;

  AllProducts({required this.products, required this.searchQuery, });
  @override
  _AllProducts createState() => _AllProducts();
}

class _AllProducts extends State<AllProducts> {
  @override
  Widget build(BuildContext context) {
    final selectedDocument = context.watch<UserProvider>().selectedDocument;
    final userId = context.watch<UserProvider>().userId;
    var searchQuery = widget.searchQuery.toLowerCase();
    final themeProvider = Provider.of<ThemeProvider>(context);


    if (selectedDocument == null) {
      return Center(child: Text('No document selected', style: TextStyle(color: Styles.customColor)));
    }

    final oilStream = FirebaseFirestore.instance
        .collection('Product')
        .doc(selectedDocument)
        .collection('Oil')
        .snapshots();

    final honeyStream = FirebaseFirestore.instance
        .collection('Product')
        .doc(selectedDocument)
        .collection('Honey')
        .snapshots();

    return Scaffold(

      backgroundColor:themeProvider.themeMode == ThemeMode.dark
          ? Styles.darkBackground // Dark mode background
          : Styles.lightBackground,
      appBar: AppBar(
        title: Text("All",
          style: const TextStyle(
              fontSize: 25,
              fontFamily: 'Tall',
              color: Styles.customColor
          ),
        ),  // Use the title passed to the constructor
        centerTitle: true,  // This will center the title
        backgroundColor: Colors.transparent,
        elevation: 4.0,
        leading: IconButton(  // Add an icon in the leading position
          icon: Icon(Icons.arrow_back_ios_new_rounded,color: Styles.customColor,),  // Example: Back arrow icon
          onPressed: () {
            Navigator.pop(context);  // Pop the current page from the navigation stack
          },
        ),
      ),
      body: StreamBuilder(
        stream: oilStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> oilSnapshot) {
          if (!oilSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder(
            stream: honeyStream,
            builder: (context, AsyncSnapshot<QuerySnapshot> honeySnapshot) {
              if (!honeySnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final oilDocs = oilSnapshot.data!.docs.toList();
              final honeyDocs = honeySnapshot.data!.docs.toList();
              final filteredOilDocs = oilDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
                if (data != null) {
                  final name = (data['name'] ?? '').toLowerCase();
                  final type = (data['type'] ?? '').toLowerCase();
                  final description = (data['description'] ?? '').toLowerCase();
                  // Check if the search query matches any of the fields (name, type, or description)
                  return name.contains(searchQuery) || type.contains(searchQuery) || description.contains(searchQuery);
                }
                return false;
              }).toList();
              final filteredHoneyDocs = honeyDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
                if (data != null) {
                  final name = (data['name'] ?? '').toLowerCase();
                  final type = (data['type'] ?? '').toLowerCase();
                  final description = (data['description'] ?? '').toLowerCase();
                  // Check if the search query matches any of the fields (name, type, or description)
                  return name.contains(searchQuery) || type.contains(searchQuery) || description.contains(searchQuery);
                }
                return false;
              }).toList();

              final allProducts = [
                ...filteredOilDocs.map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                  'type': 'Oil',
                }),
                ...filteredHoneyDocs.map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                  'type': 'Honey',
                }),
              ];
              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1200 ? 8 : (constraints.maxWidth > 767 ? 5 : 2);
                  double childAspectRatio = constraints.maxWidth > 1024 ? 0.50 : (constraints.maxWidth > 767 ? 0.90 : 0.70);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 15.0,
                      childAspectRatio: childAspectRatio, crossAxisCount: crossAxisCount,
                    ),
                    itemCount: allProducts.length > 32 ? 16 : allProducts.length,
                    itemBuilder: (context, index) {
                      final product = allProducts[index];
                      final List<String> imageUrls = [
                        product['image1'] as String? ?? '',
                        product['image2'] as String? ?? '',
                        product['image3'] as String? ?? '',
                        product['image4'] as String? ?? '',
                      ].where((url) => url.isNotEmpty).toList();
                      final name = product['name'] as String? ?? 'No Name';
                      final price = product['price'] != null ? double.tryParse(product['price'].toString()) : null;
                      final discountedPrice = product['discountedPrice'] != null ? double.tryParse(product['discountedPrice'].toString()) : null;
                      final rating = product['rating'];
                      final parsedRating = (rating is int) ? rating : int.tryParse(rating?.toString() ?? '') ?? 0;
                      final type = product['type'] as String? ?? 'Unknown';
                      final isNew = product['isNew'] as bool? ?? false;
                      final quantities = product['quantities'] as Map<String, dynamic>? ?? {};
                      final quantityTexts = quantities.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
                      final discount = product['discount'] != null
                          ? (product['discount'] is num ? (product['discount'] as num).toString() : product['discount'].toString())
                          : '';
                      final PageController pageController = PageController();
                      bool isFavorite = false;
                      return FutureBuilder<bool>(
                        future: userId != null ? _isProductFavorite(userId, product['id'] as String) : Future.value(false),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          isFavorite = snapshot.data ?? false;
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              double fontSize = constraints.maxWidth > 1024 ? 14.0 : 12.0;
                              double imageHeight = constraints.maxWidth > 1024 ? 50 : 50;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(product: product),
                                    ),
                                  );
                                },
                                child:  Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  color:themeProvider.themeMode == ThemeMode.dark
                                      ? Styles.darkcardBackground // Dark mode background
                                      : Styles.lightBackground,
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                                              child: Stack(
                                                children: [
                                                  PageView.builder(
                                                    controller: pageController,
                                                    itemCount: imageUrls.length,
                                                    itemBuilder: (context, imageIndex) {
                                                      final imageUrl = imageUrls[imageIndex];
                                                      return Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Container(
                                                          height: imageHeight,
                                                          decoration: BoxDecoration(
                                                            color: Styles.customColor.withOpacity(0.5),
                                                            borderRadius: BorderRadius.circular(20.0),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(20.0),
                                                            child: Opacity(
                                                              opacity: 0.7,
                                                              child: Image.network(
                                                                imageUrl,
                                                                fit: BoxFit.cover,
                                                                width: double.infinity,
                                                                height: imageHeight,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  if (discount.isNotEmpty)
                                                    Positioned(
                                                      bottom: 20.0,
                                                      right: 18.0,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius: BorderRadius.circular(12.0),
                                                        ),
                                                        child: Text(
                                                          '$discount% ',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (isNew)
                                                    Positioned(
                                                      top: 14.0,
                                                      left: 16.0,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius: BorderRadius.circular(12.0),
                                                        ),
                                                        child: const Text(
                                                          'New',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  Positioned(
                                                    bottom: 15.0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(0.2),
                                                        child: SmoothPageIndicator(
                                                          controller: pageController,
                                                          count: imageUrls.length,
                                                          effect: ExpandingDotsEffect(
                                                            activeDotColor: Styles.customColor,
                                                            dotColor: Styles.customColor50,
                                                            dotHeight: 5,
                                                            dotWidth: 5,
                                                            spacing: 2.5,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                                SizedBox(height: 5,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      type,
                                                      style: TextStyle(
                                                        color:themeProvider.themeMode == ThemeMode.dark
                                                            ? Styles.lightBackground // Dark mode background
                                                            : Styles.darkBackground,
                                                        fontSize: fontSize +2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,

                                                  children: [
                                                    Text(
                                                      name,
                                                      style: TextStyle(
                                                        color:themeProvider.themeMode == ThemeMode.dark
                                                            ? Styles.lightBackground // Dark mode background
                                                            : Styles.darkBackground,
                                                        fontSize: fontSize +2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5,),
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
                                                              return '${activePrice.toStringAsFixed(0)}\$'; // Return the price as a string with fixed decimals
                                                            }
                                                          }
                                                        }
                                                        // Fallback to discounted price or regular price
                                                        return discountedPrice != null
                                                            ? '${discountedPrice.toStringAsFixed(0)}\$'
                                                            : '${price?.toStringAsFixed(0) ?? '0.00'}\$';
                                                      }(),
                                                      style: TextStyle(
                                                        color: themeProvider.themeMode == ThemeMode.dark
                                                            ? Styles.lightBackground // Dark mode background
                                                            : Styles.darkBackground,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: fontSize + 4, // Slightly larger for price
                                                      ),
                                                    ),
                                                  ],
                                                ),




                                                SizedBox(height: 5,),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 2.0,
                                        right: 8.0,
                                        child: IconButton(
                                          icon: Icon(
                                            isFavorite ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              isFavorite = !isFavorite;
                                            });
                                            if (isFavorite) {
                                              await _addToFavorites(userId!, product['id'] as String,product);
                                            } else {
                                              await _removeFromFavorites(userId!, product['id'] as String);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _isProductFavorite(String userId, String productId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .get();
    return doc.exists;
  }

  Future<void> _addToFavorites(String userId, String productId, Map<String, dynamic> product) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .set(product); // Store the product data
  }


  Future<void> _removeFromFavorites(String userId, String productId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .delete();
  }
}
