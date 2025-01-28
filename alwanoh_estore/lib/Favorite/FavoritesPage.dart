import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../Cart/CartPage.dart';
import '../Products/ProductDetailsPage.dart';
import '../Serves/UserProvider.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';
import '../test/constants.dart';


class FavoritePage extends StatefulWidget {
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  int currentIndexBottomBar = 3;
  int currentIndexSwiperHome = 3;

  final iconList = <IconData>[
    Icons.home_outlined,
    Icons.search,
    Icons.person_outline,
    Icons.favorite_border_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final userId = context.watch<UserProvider>().userId;

    final favoritesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots();


    return Scaffold(
      backgroundColor:themeProvider.themeMode == ThemeMode.dark
    ? Styles.darkBackground // Dark mode background
      : Styles.lightBackground,
      body: Column(
        children: [
          SizedBox(height: 60,),
          // Header with a Row
          // Rest of the body content (StreamBuilder)
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 8
                  : (constraints.maxWidth > 767 ? 5 : 2);

              final childAspectRatio = constraints.maxWidth > 1024
                  ? 0.50
                  : (constraints.maxWidth > 767 ? 0.90 : 0.70);
              return Expanded(
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
                      itemCount: favoriteDocs.length,
                      itemBuilder: (context, index) {
                        final product = favoriteDocs[index].data() as Map<String, dynamic>;

                        return ProductCard(product: product);
                      },
                    );
                  },
                ),
              );
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Styles.customColor,
        onPressed: () => showCartBottomSheet(context),
        child: const Icon(
          Icons.shopping_cart_outlined,
          size: 24,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        height: 80,
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = !isActive ? Colors.white54 : Colors.white;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Icon(
                iconList[index],
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  index == 0
                      ? "Home"
                      : index == 1
                      ? "Search"
                      : index == 2
                      ? "Account"
                      : "Favorite",
                  maxLines: 1,
                  style: TextStyle(color: color),
                ),
              )
            ],
          );
        },
        backgroundColor: Styles.customColor,
        activeIndex: currentIndexBottomBar,
        splashColor: customColor,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.softEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) {
          setState(() => currentIndexBottomBar = index);

          // Navigation logic based on the selected tab index
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home'); // Navigate to Home
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/cart'); // Navigate to Cart
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/account'); // Navigate to Account
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings'); // Navigate to Settings
              break;
          }
        },
      ),
    );

  }
}
void showCartBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CartBottomSheet(),
  );
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late PageController _pageController;
  get imageHeight => null;
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final pageController = PageController();
    

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
    final discount = product['discount']?.toString() ?? '';

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
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
          child: Card(
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
                  top: 20.0,
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
    );
  }
}

