import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'ProductDetailsPage.dart';
import '../Thems/styles.dart';
import '../Serves/UserProvider.dart';

class ProductGridPage extends StatefulWidget {
  @override
  _ProductGridPageState createState() => _ProductGridPageState();
}

class _ProductGridPageState extends State<ProductGridPage> {
  @override
  Widget build(BuildContext context) {
    final selectedDocument = context.watch<UserProvider>().selectedDocument;
    final userId = context.watch<UserProvider>().userId;

    if (selectedDocument == null) {
      return const Center(child: Text('No document selected', style: TextStyle(color: Styles.customColor)));
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

    return StreamBuilder(
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

            final oilDocs = oilSnapshot.data!.docs;
            final honeyDocs = honeySnapshot.data!.docs;

            final allProducts = oilDocs
                .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
              'type': 'Oil',
            })
                .toList()
              ..addAll(honeyDocs.map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
                'type': 'Honey',
              }));

            final filteredProducts = allProducts;

            return GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.55,
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

                // Get quantities map
                final quantities = product['quantities'] as Map<String, dynamic>? ?? {};
                final quantityTexts = quantities.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');

                // Handle discount as either String or int
                final discount = product['discount'] != null
                    ? (product['discount'] is num ? (product['discount'] as num).toString() : product['discount'].toString())
                    : '';

                final PageController pageController = PageController();
                bool isFavorite = false; // Track if the product is favorited

                return FutureBuilder<bool>(
                  future: userId != null ? _isProductFavorite(userId, product['id'] as String) : Future.value(false),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    isFavorite = snapshot.data ?? false;

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
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                            width: isActive ? 12.0 : 8.0,
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
                                        size: 20.0,
                                      );
                                    }),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        type,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14.0,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Styles.customColor,
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15.0)),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ' ${discountedPrice?.toStringAsFixed(0) ?? price?.toStringAsFixed(0) ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 25.0,
                              left: 15.0,
                              child: isNew
                                  ? Container(
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
                              )
                                  : const SizedBox.shrink(),
                            ),
                            Positioned(
                              top: 10.0,
                              right: 10.0,
                              child: IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.white,
                                ),
                                onPressed: () async {
                                  if (userId != null) {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });

                                    if (isFavorite) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userId)
                                          .collection('favorites')
                                          .doc(product['id'] as String)
                                          .set(product);
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userId)
                                          .collection('favorites')
                                          .doc(product['id'] as String)
                                          .delete();
                                    }
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
  }

  Future<bool> _isProductFavorite(String userId, String productId) async {
    final favoriteDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .get();
    return favoriteDoc.exists;
  }

  void _toggleFavorite(String userId, String productId, bool isFavorite) {
    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId);

    if (isFavorite) {
      favoritesRef.set({'addedAt': FieldValue.serverTimestamp()});
    } else {
      favoritesRef.delete();
    }
  }
}
