import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../Thems/styles.dart';
import '../Serves/UserProvider.dart'; // Ensure this path is correct

class NewProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to changes in the UserProvider
    final selectedDocument = context.watch<UserProvider>().selectedDocument;

    if (selectedDocument == null) {
      return Center(child: Text('No document selected', style: TextStyle(color: Styles.customColor)));
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Product')
          .doc(selectedDocument)
          .collection('Honey') // Query both 'Honey' and 'Oil' collections
          .where('isNew', isEqualTo: true) // Filtering new products
          .snapshots()
          .asyncMap((snapshot) async {
        final honeyProducts = snapshot.docs;

        // Query 'Oil' collection
        final oilSnapshot = await FirebaseFirestore.instance
            .collection('Product')
            .doc(selectedDocument)
            .collection('Oil')
            .where('isNew', isEqualTo: true)
            .get();

        final oilProducts = oilSnapshot.docs;

        // Combine both lists of products
        final combinedProducts = [...honeyProducts, ...oilProducts];
        return combinedProducts;
      }),
      builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final newProducts = snapshot.data!;

        if (newProducts.isEmpty) {
          return Center(child: Text('No new products available', style: TextStyle(color: Styles.customColor)));
        }

        return CarouselSlider.builder(
          itemCount: newProducts.length,
          itemBuilder: (context, index, realIndex) {
            final product = newProducts[index].data() as Map<String, dynamic>;
            final imageUrl = product['image1'] as String?;

            return GestureDetector(
              onTap: () {
                // Navigate to product details
              },
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
                    imageUrl ?? 'https://via.placeholder.com/150', // Fallback image if URL is null
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            aspectRatio: 16/9,
            autoPlayCurve: Curves.fastOutSlowIn,
            autoPlayAnimationDuration: Duration(milliseconds: 800),
          ),
        );
      },
    );
  }
}
