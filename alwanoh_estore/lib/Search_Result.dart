import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'Products/ProductDetailsPage.dart';
import 'Serves/UserProvider.dart';
import 'Thems/ThemeProvider.dart';
import 'Thems/styles.dart';

class SearchResult extends StatefulWidget {
  final String searchQuery;

  const SearchResult({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _SearchResult createState() => _SearchResult();
}

class _SearchResult extends State<SearchResult> {
  get imageHeight => null;

  @override
  @override
  Widget build(BuildContext context) {
    final selectedDocument = context.watch<UserProvider>().selectedDocument;
    final userId = context.watch<UserProvider>().userId;
    final searchQuery = widget.searchQuery.toLowerCase().trim();

    if (selectedDocument == null) {
      return const Center(
        child: Text(
          'No document selected',
          style: TextStyle(color: Styles.customColor),
        ),
      );
    }

    if (searchQuery.isEmpty) {
      return const Center(
        child: Text(
          'Enter a search query to display results.',
          style: TextStyle(color: Styles.customColor),
        ),
      );
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

            final filteredProducts = _getFilteredProducts(
              oilSnapshot.data!.docs,
              honeySnapshot.data!.docs,
              searchQuery,
            );

            if (filteredProducts.isEmpty) {
              return const Center(
                child: Text(
                  'No products match your search query.',
                  style: TextStyle(color: Styles.customColor),
                ),
              );
            }

            return _buildProductGrid(filteredProducts, userId);
          },
        );
      },
    );
  }



  List<Map<String, dynamic>> _getFilteredProducts(
      List<QueryDocumentSnapshot> oilDocs,
      List<QueryDocumentSnapshot> honeyDocs,
      String searchQuery,
      ) {
    List<Map<String, dynamic>> filterDocs(
        List<QueryDocumentSnapshot> docs, String collectionName) {
      return docs
          .where((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final name = (data['name'] ?? '').toLowerCase();
        final description = (data['description'] ?? '').toLowerCase();

        // Include the collection name in the search logic
        return name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            collectionName.toLowerCase().contains(searchQuery);
      })
          .map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
        'type': collectionName,
      })
          .toList();
    }

    final filteredOilDocs = filterDocs(oilDocs, 'Oil');
    final filteredHoneyDocs = filterDocs(honeyDocs, 'Honey');

    return [...filteredOilDocs, ...filteredHoneyDocs];
  }


  Widget _buildProductGrid(List<Map<String, dynamic>> products,
      String? userId) {
    return LayoutBuilder(
      
      builder: (context, constraints) {
        double imageHeight = constraints.maxWidth > 1024 ? 50 : 50;
        final crossAxisCount = constraints.maxWidth > 1200
            ? 8
            : (constraints.maxWidth > 767 ? 5 : 2);

        final childAspectRatio = constraints.maxWidth > 1024
            ? 0.50
            : (constraints.maxWidth > 767 ? 0.90 : 0.70);

        return GridView.builder(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 15.0,
            childAspectRatio: childAspectRatio,
            crossAxisCount: crossAxisCount,
          ),
          itemCount: products.length > 32 ? 16 : products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product, userId);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, String? userId) {
    final pageController = PageController();
    final imageUrls = [
      product['image1'] as String? ?? '',
      product['image2'] as String? ?? '',
      product['image3'] as String? ?? '',
      product['image4'] as String? ?? '',
    ].where((url) => url.isNotEmpty).toList();

    final name = product['name'] as String? ?? 'No Name';
    final price = product['price'] != null
        ? double.tryParse(product['price'].toString())
        : null;
    final discountedPrice = product['discountedPrice'] != null
        ? double.tryParse(product['discountedPrice'].toString())
        : null;
    final rating = product['rating'] is int
        ? product['rating'] as int
        : int.tryParse(product['rating']?.toString() ?? '') ?? 0;
    final parsedRating = (rating is int) ? rating : int.tryParse(rating?.toString() ?? '') ?? 0;
    final discount = product['discount']?.toString() ?? '';
    final isNew = product['isNew'] as bool? ?? false;
    final type = product['type'] as String? ?? 'Unknown';
    final themeProvider = Provider.of<ThemeProvider>(context);


    return FutureBuilder<bool>(
      future: userId != null
          ? _isProductFavorite(userId, product['id'])
          : Future.value(false),
      builder: (context, snapshot,) {
        var isFavorite = snapshot.data ?? false;
        return GestureDetector(
          onTap: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(product: product),
                ),
              ),
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
                                  fontSize:  16,
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
                                  fontSize:  16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,

                            children: [
                              Text(
                                discountedPrice != null
                                    ? '${discountedPrice.toStringAsFixed(0)}\$'
                                    : '${price?.toStringAsFixed(0) ?? '0.00'}\$',
                                style: TextStyle(
                                  color:themeProvider.themeMode == ThemeMode.dark
                                      ? Styles.lightBackground // Dark mode background
                                      : Styles.darkBackground,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20 , // Slightly larger for price
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

  Future<void> _addToFavorites(String userId, String productId,
      Map<String, dynamic> product) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .set(product);
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