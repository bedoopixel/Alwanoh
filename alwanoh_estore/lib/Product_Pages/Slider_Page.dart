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
  late PageController _pageController;
  late int _currentIndex;
  List<QueryDocumentSnapshot> _displayProducts = [];
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    _currentIndex = 0;
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_displayProducts.isNotEmpty) {
        int nextIndex = (_currentIndex + 1) % _displayProducts.length;
        _pageController.animateToPage(
          nextIndex,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
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
      return _buildErrorMessage('No document selected');
    }

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _fetchNewProducts(selectedDocument),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final newProducts = snapshot.data!;
        if (newProducts.isEmpty) {
          return _buildErrorMessage('No new products available');
        }

        _displayProducts = newProducts;

        return Column(
          children: [
            _buildPageView(),
            SizedBox(height: 10.0),
            _buildPageIndicator(),
          ],
        );
      },
    );
  }

  Stream<List<QueryDocumentSnapshot>> _fetchNewProducts(String selectedDocument) async* {
    final honeySnapshot = FirebaseFirestore.instance
        .collection('Product')
        .doc(selectedDocument)
        .collection('Honey')
        .where('isNew', isEqualTo: true)
        .snapshots();

    yield* honeySnapshot.asyncMap((honeyDocs) async {
      final honeyProducts = honeyDocs.docs;
      final oilSnapshot = await FirebaseFirestore.instance
          .collection('Product')
          .doc(selectedDocument)
          .collection('Oil')
          .where('isNew', isEqualTo: true)
          .get();
      final oilProducts = oilSnapshot.docs;
      return [...honeyProducts, ...oilProducts];
    });
  }

  Widget _buildPageView() {
    return SizedBox(
      height: _getCarouselHeight(),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _displayProducts.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index; // تحديث الفهرس الحالي بشكل صحيح
          });
        },
        itemBuilder: (context, index) {
          final product = _displayProducts[index].data() as Map<String, dynamic>;
          final imageUrl = product['image1'] as String? ?? 'https://via.placeholder.com/150';

          return GestureDetector(
            onTap: () {
              // Add navigation logic here
            },
            child: _buildProductCard(imageUrl),
          );
        },
      ),
    );
  }

  double _getCarouselHeight() {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 660.0;
    if (width >= 992) return 500.0;
    if (width >= 600) return 350.0;
    return 200.0;
  }

  Widget _buildProductCard(String imageUrl) {
    return Container(
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
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Styles.customColor),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: _displayProducts.length,
      effect: ExpandingDotsEffect(
        activeDotColor: Styles.customColor,
        dotColor: Styles.customColor50,
        dotHeight: 8,
        dotWidth: 8,
        spacing: 4,
      ),
    );
  }
}
