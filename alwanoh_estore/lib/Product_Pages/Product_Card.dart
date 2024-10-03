import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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

            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 8 : (constraints.maxWidth > 767 ? 5 : 2);
                double childAspectRatio = constraints.maxWidth > 1024 ? 0.65 : (constraints.maxWidth > 767 ? 0.65 : 0.65);


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
                                                fontSize: fontSize + 8, // Slightly larger for price
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
        );
      },
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
