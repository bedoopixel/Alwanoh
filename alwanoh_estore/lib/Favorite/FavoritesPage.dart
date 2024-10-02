import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Product_Pages/ProductDetailsPage.dart';
import '../Serves/UserProvider.dart';
import '../Thems/styles.dart';


class FavoritePage extends StatefulWidget {
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    final userId = context.watch<UserProvider>().userId;

    final favoritesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots();


    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header with a Row
          Container(
            decoration: BoxDecoration(  borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
              color: Styles.customColor, ),
            width: 200,

            padding: const EdgeInsets.only(top: 40,bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                const Text(
                  'Favorites',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Rest of the body content (StreamBuilder)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: favoritesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No favorites yet.'));
                }

                final favoriteDocs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: favoriteDocs.length,
                  itemBuilder: (context, index) {
                    final product = favoriteDocs[index].data() as Map<String, dynamic>;

                    return ProductCard(product: product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

  }
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late PageController _pageController;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    isFavorite = true; // Assuming it's initially a favorite
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final userId = context.read<UserProvider>().userId;
    final productId = widget.product['id'] as String;

    if (isFavorite) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .set(widget.product);
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final List<String> imageUrls = [
      product['image1'] as String?,
      product['image2'] as String?,
      product['image3'] as String?,
      product['image4'] as String?,
    ].whereType<String>().toList();

    final name = product['name'] as String? ?? 'No Name';
    final price = product['price'] != null ? double.tryParse(product['price'].toString()) : null;
    final discountedPrice = product['discountedPrice'] != null ? double.tryParse(product['discountedPrice'].toString()) : null;
    final rating = product['rating'];
    final parsedRating = (rating is int) ? rating : int.tryParse(rating?.toString() ?? '') ?? 0;
    final type = product['type'] as String? ?? 'Unknown';
    final isNew = product['isNew'] as bool? ?? false;
    final discount = product['discount'] != null ? product['discount'].toString() : null;

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
                          controller: _pageController,
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
                        if (discount != null)
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
                        animation: _pageController,
                        builder: (context, child) {
                          final currentPage = _pageController.hasClients ? _pageController.page ?? 0 : 0;
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
                      const SizedBox(height: 4.0),
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
                        discountedPrice != null
                            ? '  ${discountedPrice.toStringAsFixed(0)}\ريال  '
                            : '  ${price?.toStringAsFixed(0) ?? 'N/A'}\ريال  ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10.0,
              right: 10.0,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
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
          ],
        ),
      ),
    );
  }
}

