import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../Thems/styles.dart';
import '../Serves/UserProvider.dart';

class NewProductsPage extends StatefulWidget {
  @override
  _NewProductsPageState createState() => _NewProductsPageState();
}

class _NewProductsPageState extends State<NewProductsPage> {
  PageController _pageController = PageController(viewportFraction: 1);
  int _currentIndex = 0;
  List<QueryDocumentSnapshot> _displayProducts = [];
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    startAutoScroll(); // Start the auto-scrolling timer
  }

  void startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      int nextIndex = (_currentIndex + 1) % (_displayProducts.length + 2);
      _pageController.animateToPage(
        nextIndex,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDocument = context.watch<UserProvider>().selectedDocument;

    if (selectedDocument == null) {
      return Center(
        child: Text(
          'No document selected',
          style: TextStyle(color: Styles.customColor),
        ),
      );
    }

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: FirebaseFirestore.instance
          .collection('Product')
          .doc(selectedDocument)
          .collection('Honey')
          .where('isNew', isEqualTo: true)
          .snapshots()
          .asyncMap((honeySnapshot) async {
        final honeyProducts = honeySnapshot.docs;

        final oilSnapshot = await FirebaseFirestore.instance
            .collection('Product')
            .doc(selectedDocument)
            .collection('Oil')
            .where('isNew', isEqualTo: true)
            .get();

        final oilProducts = oilSnapshot.docs;

        return [...honeyProducts, ...oilProducts];
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final newProducts = snapshot.data!;

        if (newProducts.isEmpty) {
          return Center(
            child: Text(
              'No new products available',
              style: TextStyle(color: Styles.customColor),
            ),
          );
        }

        // Prepare display products
        _displayProducts = newProducts;

        // Wrap display products with two copies of the first and last item
        List<QueryDocumentSnapshot> carouselProducts = [
          _displayProducts.last, // Last item
          ..._displayProducts,
          _displayProducts.first, // First item
        ];

        return Column(
          children: [
            SizedBox(
              height: 200.0,
              child: PageView.builder(
                controller: _pageController,
                itemCount: carouselProducts.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index; // Update current index on page change
                  });

                  // Reset the index when reaching the end of the list
                  if (index == 0) {
                    _pageController.jumpToPage(_displayProducts.length);
                  } else if (index == carouselProducts.length - 1) {
                    _pageController.jumpToPage(1);
                  }
                },
                itemBuilder: (context, index) {
                  final product = carouselProducts[index].data() as Map<String, dynamic>;
                  final imageUrl = product['image1'] as String?;

                  return GestureDetector(
                    onTap: () {
                      // Add navigation logic here
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Card(
                        color: Colors.black,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                            color: Styles.customColor,
                            width: 2.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            imageUrl ?? 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10.0),
            // Page indicator

          ],
        );
      },
    );
  }
}
