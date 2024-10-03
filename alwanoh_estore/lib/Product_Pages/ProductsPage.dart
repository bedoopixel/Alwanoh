import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'ProductDetailsPage.dart';
import '../Thems/styles.dart';
import '../Serves/UserProvider.dart';

class ProductsPage extends StatefulWidget {
  final String category;

  ProductsPage({required this.category});

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

    final productStream = FirebaseFirestore.instance
        .collection('Product')
        .doc(selectedDocument)
        .collection(widget.category) // Use the selected category
        .snapshots();

    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: Text('${widget.category} Products'),
        backgroundColor: Styles.customColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productDocs = snapshot.data!.docs;

          if (productDocs.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final filteredProducts = productDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              ...data,
              'id': doc.id,
              'type': widget.category, // Set type to the selected category
            };
          }).toList();

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
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
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
                          double imageHeight = constraints.maxWidth > 1024 ? 250 : 180;

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
                                                      height: imageHeight,
                                                      decoration: BoxDecoration(
                                                        color: Styles.customColor.withOpacity(0.5),
                                                        borderRadius: BorderRadius.circular(15.0),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(15.0),
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
                                                  bottom: 18.0,
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
                                                  top: 22.0,
                                                  left: 8.0,
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
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(imageUrls.length, (dotIndex) {
                                            return AnimatedBuilder(
                                              animation: pageController,
                                              builder: (context, child) {
                                                final currentPage = pageController.hasClients ? pageController.page ?? 0 : 0;
                                                final isActive = currentPage.round() == dotIndex;
                                                return Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                                  width: isActive ? 24.0 : 8.0,
                                                  height: isActive ? 12.0 : 8.0,
                                                  decoration: BoxDecoration(
                                                    color: isActive ? Styles.customColor : Colors.white30,
                                                    shape: BoxShape.circle,
                                                  ),
                                                );
                                              },
                                            );
                                          }),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < parsedRating ? Icons.star : Icons.star_border,
                                              color: Styles.customColor,
                                              size: fontSize,
                                            );
                                          }),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontSize,
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
                                              fontSize: fontSize + 4, // Slightly larger for price
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
