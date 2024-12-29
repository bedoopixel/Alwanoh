import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../Thems/styles.dart';
import '../Cart/Products/ProductDetailsPage.dart';

class ProductCardPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final String? userId;

  const ProductCardPage({
    Key? key,
    required this.product,
    this.userId,
  }) : super(key: key);

  @override
  _ProductCardPageState createState() => _ProductCardPageState();
}

class _ProductCardPageState extends State<ProductCardPage> {
  late bool isFavorite;
  late PageController pageController;
  String get name => widget.product['name'] ?? '';
  String? get discount => widget.product['discount'];
  bool get isNew => widget.product['isNew'] ?? false;
  double? get price => widget.product['price'];
  double? get discountedPrice => widget.product['discountedPrice'];
  List<String> get imageUrls => List<String>.from(widget.product['images'] ?? []);
  double get parsedRating => widget.product['rating'] ?? 0.0;

  @override
  void initState() {
    super.initState();
    isFavorite = false;
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<bool> _isProductFavorite(String userId, String productId) async {
    // Implement your favorite check logic here
    return false;
  }

  Future<void> _addToFavorites(String userId, String productId, Map<String, dynamic> product) async {
    // Implement your add to favorites logic here
  }

  Future<void> _removeFromFavorites(String userId, String productId) async {
    // Implement your remove from favorites logic here
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: widget.userId != null
          ? _isProductFavorite(widget.userId!, widget.product['id'] as String)
          : Future.value(false),
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
                    builder: (context) => ProductDetailsPage(product: widget.product),
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
                                if (discount != null && discount!.isNotEmpty)
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
                                          dotColor: Styles.customColor.withOpacity(0.5),
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
                              Row(
                                children: [
                                  Icon(
                                    parsedRating > 0 ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: Styles.customColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 3),
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
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15.0)),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              discountedPrice != null
                                  ? '\$${discountedPrice!.toStringAsFixed(2)}'
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
                            await _addToFavorites(widget.userId!, widget.product['id'] as String, widget.product);
                          } else {
                            await _removeFromFavorites(widget.userId!, widget.product['id'] as String);
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
  }
}
