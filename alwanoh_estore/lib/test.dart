// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:provider/provider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
//
// import '../../../Serves/UserProvider.dart';
// import '../../../Thems/styles.dart';
// import '../test/details.dart';
//
// class ProductSlider extends StatefulWidget {
//   final String filter;
//
//   ProductSlider({required this.filter});
//
//   @override
//   _ProductSlider createState() => _ProductSlider();
// }
//
// class _ProductSlider extends State<ProductSlider> {
//   late PageController _pageController;
//   late int _currentIndex;
//   List<QueryDocumentSnapshot> _displayProducts = [];
//   Timer? _autoScrollTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(viewportFraction: 1);
//     _currentIndex = 0;
//     _startAutoScroll();
//   }
//
//   void _startAutoScroll() {
//     _autoScrollTimer?.cancel();
//     _autoScrollTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
//       if (_displayProducts.isNotEmpty) {
//         int nextIndex = (_currentIndex + 1) % _displayProducts.length;
//         _pageController.animateToPage(
//           nextIndex,
//           duration: Duration(milliseconds: 400),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _autoScrollTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final selectedDocument = context.watch<UserProvider>().selectedDocument;
//
//     if (selectedDocument == null) {
//       return _buildErrorMessage('No document selected');
//     }
//
//     return StreamBuilder<List<QueryDocumentSnapshot>>(
//       stream: _fetchNewProducts(selectedDocument),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }
//
//         final newProducts = snapshot.data!;
//         if (newProducts.isEmpty) {
//           return _buildErrorMessage('No new products available');
//         }
//
//         _displayProducts = newProducts;
//
//         return SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               _buildTodayOfferBanner(),
//               const SizedBox(height: 15),
//               _buildPageIndicator(),
//               const SizedBox(height: 20),
//               _buildSectionHeader('Most Popular', 'View More'),
//               const SizedBox(height: 20),
//               _buildProductGrid(),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Stream<List<QueryDocumentSnapshot>> _fetchNewProducts(String selectedDocument) async* {
//     final honeySnapshot = FirebaseFirestore.instance
//         .collection('Product')
//         .doc(selectedDocument)
//         .collection('Honey')
//         .where(widget.filter, isEqualTo: true)
//         .snapshots();
//
//     yield* honeySnapshot.asyncMap((honeyDocs) async {
//       final honeyProducts = honeyDocs.docs;
//       final oilSnapshot = await FirebaseFirestore.instance
//           .collection('Product')
//           .doc(selectedDocument)
//           .collection('Oil')
//           .where(widget.filter, isEqualTo: true)
//           .get();
//       final oilProducts = oilSnapshot.docs;
//       return [...honeyProducts, ...oilProducts];
//     });
//   }
//
//   Widget _buildTodayOfferBanner() {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.95,
//       height: 130,
//       decoration: const BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.all(
//           Radius.circular(20),
//         ),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned(
//             right: -30,
//             child: Image.asset(
//               "images/products/product0.png",
//               height: 120,
//             ),
//           ),
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.all(
//                 Radius.circular(20),
//               ),
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xff212121).withOpacity(1),
//                   const Color(0xff212121).withOpacity(0.8),
//                   const Color(0xff212121).withOpacity(0.7),
//                   const Color(0xff212121).withOpacity(0.5),
//                   const Color(0xff212121).withOpacity(0.0),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             left: 10,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   "TODAY ONLY",
//                   style: TextStyle(
//                     fontSize: 13,
//                     height: 1.3,
//                     color: Colors.white54,
//                   ),
//                 ),
//                 Text(
//                   "80% OFF\nWITH CODE:",
//                   style: TextStyle(
//                     fontSize: 22,
//                     height: 1.3,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: GestureDetector(
//               onTap: () {},
//               child: Container(
//                 width: 120,
//                 height: 30,
//                 alignment: Alignment.center,
//                 decoration: const BoxDecoration(
//                   color: Styles.customColor,
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(36),
//                   ),
//                 ),
//                 child: const Text(
//                   "GCOMMERC",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPageIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(
//         3,
//             (index) => GestureDetector(
//           onTap: () {},
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 2.5),
//             width: 30,
//             height: 5,
//             color: _currentIndex != index
//                 ? Colors.white54
//                 : const Color(0xff494949),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, String actionText) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width * 0.95,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           Text(
//             actionText,
//             style: const TextStyle(
//               fontSize: 18,
//               color: Styles.customColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProductGrid() {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width * 0.95,
//       child: StaggeredGrid.count(
//         crossAxisCount: 2,
//         mainAxisSpacing: 4,
//         crossAxisSpacing: 4,
//         children: _displayProducts.map((product) => _buildProductCard(product)).toList(),
//       ),
//     );
//   }
//
//   Widget _buildProductCard(QueryDocumentSnapshot productDoc) {
//     final product = productDoc.data() as Map<String, dynamic>;
//     final imageUrl = product['image1'] ?? 'https://via.placeholder.com/150';
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           CupertinoPageRoute(
//             builder: (_) => DetailsPage(
//               data: product,
//               hero: product['name'] ?? '',
//             ),
//           ),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//               child: Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: 180,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product['name'] ?? '',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     "${product['price']} £",
//                     style: const TextStyle(
//                       color: Styles.customColor,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorMessage(String message) {
//     return Center(
//       child: Text(
//         message,
//         style: const TextStyle(color: Styles.customColor),
//       ),
//     );
//   }
// }
//
