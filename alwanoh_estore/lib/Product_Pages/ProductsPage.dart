import 'dart:async';
import 'dart:async'; // Required for StreamController
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'ProductDetailsPage.dart';
import '../Thems/styles.dart';
import '../Serves/UserProvider.dart';

class ProductsPage extends StatefulWidget {
  final String category;
  final String filterType;

  ProductsPage({ required this.filterType, required this.category});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late String userId;
  late String? selectedDocument;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userId = context.watch<UserProvider>().userId!;
    selectedDocument = context.watch<UserProvider>().selectedDocument;

    if (selectedDocument == null) {
      return const Center(child: Text('No document selected', style: TextStyle(color: Styles.customColor)));
    }

    // Determine the product stream based on the filter type
    final productStream = _getProductStream();

    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Styles.customColor,
      ),
      body:StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getProductStream(),  // This now returns a Stream<List<Map<String, dynamic>>>
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching products'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final products = snapshot.data!;
          return _buildProductGrid(products);  // Pass the merged list to your grid builder
        },
      )


    );
  }

  /// Get the product stream based on the filter type
  /// Get the product stream based on the filter type


 // Required for StreamController




  Stream<List<Map<String, dynamic>>> _getProductStream() {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('Product').doc(selectedDocument);

    // If category is 'all' or empty, merge streams from both "Oil" and "Honey" categories
    if (widget.category.isEmpty || widget.category == 'all') {
      final StreamController<List<Map<String, dynamic>>> controller =
      StreamController<List<Map<String, dynamic>>>.broadcast();

      // Fetch from Oil category
      final oilStream = collectionRef.collection('Oil').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'id': doc.id, ...data}; // Add product ID to the map
        }).toList();
      });

      // Fetch from Honey category
      final honeyStream = collectionRef.collection('Honey').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'id': doc.id, ...data}; // Add product ID to the map
        }).toList();
      });

      // Use StreamZip to merge the oil and honey streams
      StreamZip([oilStream, honeyStream]).listen((mergedData) {
        final mergedList = [...mergedData[0], ...mergedData[1]];  // Merge both lists into one
        controller.add(mergedList);  // Add the merged data to the stream
      });

      return controller.stream;  // Return the combined stream of products
    }

    // If a specific category is selected, return products from that category
    final categoryRef = collectionRef.collection(widget.category);

    switch (widget.filterType) {
      case 'all':
        return categoryRef.snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {'id': doc.id, ...data};
          }).toList();
        });

      case 'isNew':
        return categoryRef.where('isNew', isEqualTo: true).snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {'id': doc.id, ...data};
          }).toList();
        });

      case 'discount':
        return categoryRef.where('discount', isGreaterThan: 0).snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {'id': doc.id, ...data};
          }).toList();
        });

      default:
        return categoryRef.snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {'id': doc.id, ...data};
          }).toList();
        }); // Fallback to all products in the specified category
    }
  }










  /// Get the title based on the filter type
  String _getTitle() {
    switch (widget.filterType) {
      case 'isNew':
        return 'New Products';
      case 'discount':
        return 'Discounted Products';
      case 'category':
        return '${widget.category} Products';
      case 'all':
      default:
        return 'All Products';
    }
  }

  /// Build the product grid
  Widget _buildProductGrid(List<Map<String, dynamic>> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1024 ? 6 : (constraints.maxWidth > 800 ? 6 : 2);
        double childAspectRatio = constraints.maxWidth > 1024 ? 0.80 : (constraints.maxWidth > 800 ? 0.80 : 0.65);

        return GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  /// Build the product card
  Widget _buildProductCard(Map<String, dynamic> product) {
    final List<String> imageUrls = [
      product['image1'] as String? ?? '',
      product['image2'] as String? ?? '',
      product['image3'] as String? ?? '',
      product['image4'] as String? ?? '',
    ].where((url) => url.isNotEmpty).toList();

    final name = product['name'] as String? ?? 'No Name';
    final price = product['price'] != null ? double.tryParse(product['price'].toString()) : null;
    final discountedPrice = product['discountedPrice'] != null ? double.tryParse(product['discountedPrice'].toString()) : null;
    final isNew = product['isNew'] as bool? ?? false;
    final discount = product['discount'] != null ? product['discount'].toString() : '';
    final PageController pageController = PageController();
    bool isFavorite = false;
    final rating = product['rating'];
    final parsedRating = (rating is int) ? rating : int.tryParse(rating?.toString() ?? '') ?? 0;


    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: Styles.customColor,
            width: 2.0,
          ),
        ),
        color: Colors.black,
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
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Styles.customColor.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 100,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (discount.isNotEmpty)
                          Positioned(
                            bottom: 30.0,
                            right: 18.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                '$discount% Off',
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
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
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
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'قسم المنتج',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: Styles.customColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Styles.customColor,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.0)),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      discountedPrice != null
                          ? '\$${discountedPrice.toStringAsFixed(2)}'
                          : '\$${price?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15 + 8, // Slightly larger for price
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8.0,
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
  }
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
