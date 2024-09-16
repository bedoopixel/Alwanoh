import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import CarouselSlider
import '../Thems/styles.dart';

class HomePagee extends StatefulWidget {
  final String selectedDocument;

  HomePagee({Key? key, required this.selectedDocument}) : super(key: key);

  @override
  _HomePageeState createState() => _HomePageeState();
}

class _HomePageeState extends State<HomePagee> {
  String searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      print("Search query updated: $searchQuery"); // Debugging line
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Styles.customColor, // Border color
            width: 0.0, // Border width
          ),
        ),
        child: Column(
          children: [
            // Custom Row replacing the AppBar
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text next to the image
                    Row(
                      children: [
                        Image.asset(
                          'assets/p1.png', // Ensure this image is available in your assets folder
                          width: 125,
                          height: 75,
                        ),
                        // Add spacing between the image and text
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: Text(
                            'ALWANOH FOR YEMENI HONEY',
                            style: TextStyle(
                              color: Styles.customColor, // Custom color for the text
                              fontSize: 16.0, // Adjust size as needed
                              fontWeight: FontWeight.bold, // Bold text
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Person Icon with GestureDetector
                    GestureDetector(
                      onTap: () {
                        // Navigate to personal screen
                      },
                      child: CircleAvatar(
                        backgroundColor: Styles.customColor, // Border color
                        radius: 20, // Radius of the circle
                        child: Icon(
                          Icons.person, // Person icon
                          color: Colors.black, // Icon color
                          size: 24, // Icon size
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: _onSearchChanged,
                style: TextStyle(color: Styles.customColor),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Styles.customColor),
                  filled: true,
                  fillColor: Colors.grey[900],
                  // Adding border with customColor
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Styles.customColor, width: 2.0), // Border with customColor
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Styles.customColor, width: 2.0), // Border when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Styles.customColor, width: 2.0), // Border when focused
                  ),
                ),
              ),
            ),
            // New Row with Containers
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCategoryContainer('Honey', 'assets/honey.png'),
                  buildCategoryContainer('Oil', 'assets/oil.png'),
                  buildCategoryContainer('Nets', 'assets/nets.png'),
                  buildCategoryContainer('More', 'assets/more.png'),
                ],
              ),
            ),
            // Swiper Container for New Products
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              height: 200, // Height of the swiper container
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Product')
                    .doc(widget.selectedDocument)
                    .collection('Oil')
                    .where('isNew', isEqualTo: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> oilSnapshot) {
                  if (!oilSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Product')
                        .doc(widget.selectedDocument)
                        .collection('Honey')
                        .where('isNew', isEqualTo: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> honeySnapshot) {
                      if (!honeySnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      // Combine oil and honey documents
                      final oilDocs = oilSnapshot.data!.docs;
                      final honeyDocs = honeySnapshot.data!.docs;

                      // Combine both collections
                      final newProducts = oilDocs
                          .map((doc) => doc.data() as Map<String, dynamic>)
                          .toList()
                        ..addAll(honeyDocs.map((doc) => doc.data() as Map<String, dynamic>));

                      // Get first image URLs
                      final imageUrls = newProducts
                          .map((product) => product['image1'] as String?)
                          .whereType<String>()
                          .toList();

                      // Debugging: Print image URLs
                      print("Swiper image URLs: $imageUrls");

                      return CarouselSlider(
                        options: CarouselOptions(
                          height: 200.0,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          viewportFraction: 1.0,
                        ),
                        items: imageUrls.map((imageUrl) {
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0), // Apply border radius to the container
                              child: Container(
                                color: Styles.customColor, // Background color of the container
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0), // Apply border radius to the image
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
            // Remaining part of the HomePagee content
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Product')
                    .doc(widget.selectedDocument)
                    .collection('Oil')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> oilSnapshot) {
                  if (!oilSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Product')
                        .doc(widget.selectedDocument)
                        .collection('Honey')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> honeySnapshot) {
                      if (!honeySnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      // Combine oil and honey documents
                      final oilDocs = oilSnapshot.data!.docs;
                      final honeyDocs = honeySnapshot.data!.docs;

                      // Combine both collections and filter based on search query
                      final allProducts = oilDocs
                          .map((doc) => {...doc.data() as Map<String, dynamic>, 'type': 'Oil'})
                          .toList()
                        ..addAll(honeyDocs.map((doc) => {...doc.data() as Map<String, dynamic>, 'type': 'Honey'}));

                      // Debugging: Print product names and search query
                      print("All products: ${allProducts.map((e) => e['name']).toList()}");
                      print("Search query in filter: $searchQuery");

                      final filteredProducts = allProducts.where((product) {
                        final name = product['name'].toString().toLowerCase();
                        final description = product['description'].toString().toLowerCase();
                        return name.contains(searchQuery) || description.contains(searchQuery);
                      }).toList();

                      // Debugging: Print filtered product names
                      print("Filtered products: ${filteredProducts.map((e) => e['name']).toList()}");

                      return GridView.builder(
                        padding: const EdgeInsets.all(10.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 0.55,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final List<String> imageUrls = [
                            product['image1'] as String?,
                            product['image2'] as String?,
                            product['image3'] as String?,
                            product['image4'] as String?,
                          ].whereType<String>().toList();

                          return Card(
                            color: Colors.black,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrls.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      imageUrls[0], // Display the first image in the list
                                      fit: BoxFit.cover,
                                      height: 150.0,
                                      width: double.infinity,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? '',
                                        style: TextStyle(
                                          color: Styles.customColor, // Custom color for the title
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        product['description'] ?? '',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Container(
                                        color: Styles.customColor, // Background color for the price container
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                        child: Text(
                                          '\$${product['price'] ?? ''}', // Price text
                                          style: const TextStyle(
                                            color: Colors.white, // Text color inside the container
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build category container
  Widget buildCategoryContainer(String label, String assetPath) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Styles.customColor, // Custom color for the circle
          ),
          child: Center(
            child: Image.asset(
              assetPath,
              width: 24,
              height: 24,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Styles.customColor),
        ),
      ],
    );
  }
}
