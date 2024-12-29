import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Cart/CartPage.dart';
import '../Favorite/FavoritesPage.dart';
import '../Thems/styles.dart';
import 'Main_Screens/HomePage.dart';
import 'Search_Result.dart';


class SearchPage extends StatefulWidget {

  String? _imageUrl; // Allow null values initially

  @override
  _SearchPage createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  int _selectedIndex = 0;
  String _searchQuery = ""; // User's search query
  List<Map<String, dynamic>> _products = []; // Full list of products

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation or actions based on the selected index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Column(
                        children: [
                          // Pass the searchQuery and filter logic to DiscountSlider
                          SearchResult(
                            searchQuery: _searchQuery,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Fixed custom app bar with search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCustomAppBarWithSearchBar(context),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildCustomAppBarWithSearchBar(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width > 600 ? 14.0 : 16.0;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 45),
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query; // Update the search query
                  });
                },
                style: TextStyle(color: Styles.customColor, fontSize: fontSize),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Styles.customColor),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.customColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.customColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Styles.customColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex; // Track the selected index
  final Function(int) onItemTapped; // Callback for item tap

  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20), // Adds space on left and right
        child: BottomAppBar(
          color: Colors.transparent, // Set to transparent for a floating effect
          elevation: 0, // Remove shadow
          child: Center(
            child: Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height * 0.09,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stack with rounded container and oval overlap
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 250,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xff9c774c),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(27.5),
                            bottomLeft: Radius.circular(27.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Person icon
                            IconButton(
                              icon: Icon(
                                Icons.search,
                                color: selectedIndex == 3 ? Colors.black : Colors.black, // Change color based on selection
                              ),
                              onPressed: () {
                                onItemTapped(0); // Pass index to callback
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(),
                                  ),
                                );
                              },
                            ),
                            // Favorite icon
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: selectedIndex == 1 ? Colors.black : Colors.white, // Change color based on selection
                              ),
                              onPressed: () {
                                onItemTapped(1); // Pass index to callback
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoritePage(),
                                  ),
                                );
                              },
                            ),
                            // Shopping cart icon
                            IconButton(
                              icon: Icon(
                                Icons.shopping_cart,
                                color: selectedIndex == 2 ? Colors.black : Colors.white, // Change color based on selection
                              ),

                              onPressed: () => showCartBottomSheet(context),

                            ),
                          ],
                        ),
                      ),

                      // Positioned oval with SVG icon
                      Positioned(
                        right: -37,
                        top: -17.95,
                        child: ClipOval(
                          child: Container(
                            width: 63,
                            height: 99,
                            child: SvgPicture.string(
                              '''
                              <svg xmlns="http://www.w3.org/2000/svg" width="85" height="85" viewBox="0 0 90 90">
                                <defs>
                                  <style>
                                    .cls-1 {
                                      fill: #88683e;
                                      fill-rule: evenodd;
                                    }
                                  </style>
                                </defs>
                                <path class="cls-1" d="M40.107,40.12A39.976,39.976,0,0,0,80.12,80H0V0H80V0.12A40,40,0,0,0,40.107,40.12Z"/>
                              </svg>
                              ''',
                              width: 90,
                              height: 90,
                              color: Color(0xff9c774c),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Home icon with rounded circle
                  Transform.translate(
                    offset: Offset(5, 0),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xff9c774c),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.home,
                          color: selectedIndex == 3 ? Colors.black : Colors.white, // Change color based on selection
                        ),
                        onPressed: () {
                          onItemTapped(3); // Pass index to callback
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(),
    );
  }
}









