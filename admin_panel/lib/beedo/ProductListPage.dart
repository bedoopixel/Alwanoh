import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductBViewPage extends StatefulWidget {
  @override
  _ProductBViewPageState createState() => _ProductBViewPageState();
}

class _ProductBViewPageState extends State<ProductBViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Product').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Handle missing fields by providing default values
        return {
          'name': data['name'] ?? 'No name',
          'price': data['price'] ?? 'No price',
          'description': data['description'] ?? 'No description',
          'imageUrls': data.containsKey('imageUrls') ? data['imageUrls'] as List<dynamic>? ?? [] : [],
          'rating': data['rating'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available.'));
          }

          var products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              var productName = product['name'] ?? 'No name';
              var productPrice = product['price'] ?? 'No price';
              var productDescription = product['description'] ?? 'No description';
              var productImages = product['imageUrls'] as List<dynamic>? ?? [];
              var productRating = product['rating'];

              return Card(
                color: Color(0xFF333333),
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(productName, style: TextStyle(color: Colors.white, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text('Price: $productPrice', style: TextStyle(color: Colors.white)),
                      SizedBox(height: 8),
                      Text(productDescription, style: TextStyle(color: Colors.white)),
                      SizedBox(height: 8),
                      if (productRating != null)
                        Text('Rating: ${productRating.toString()}', style: TextStyle(color: Colors.white)),
                      SizedBox(height: 8),
                      if (productImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: productImages.length,
                            itemBuilder: (context, imageIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(
                                  productImages[imageIndex] as String,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
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
      ),
    );
  }
}
