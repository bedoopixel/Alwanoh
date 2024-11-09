import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../Cart/CartPage.dart';
import '../Favorite/FavoritesPage.dart';
import '../Product_Pages/Product_Card.dart';
import '../Product_Pages/ProductsPage.dart';
import '../Product_Pages/Slider_Page.dart';
import '../Profile_Pages/PersonalScreenWidget.dart';
import '../Serves/UserProvider.dart';
import '../Thems/styles.dart';
import 'CustomWidget.dart';
import 'Main_Screens/HomePage.dart';


class HomesPages extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomesPages> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),
    FavoritePage(),
    CartPage(),
    PersonalScreenWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BottomAppBar(
        color: Colors.transparent,
        // Set to transparent for a floating effect
        elevation: 0, // Remove shadow
        child: Center(

          child: Container(

            height: 60,
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
                        color: Color(0xFF88683E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(27.5),
                          bottomLeft: Radius.circular(27.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.person),
                            onPressed: () => onItemTapped(3),
                            color: Colors.black,
                          ),
                          IconButton(
                            icon: Icon(Icons.favorite),
                            onPressed: () => onItemTapped(1),
                            color: Colors.black,
                          ),
                          IconButton(
                            icon: Icon(Icons.shopping_cart),
                            onPressed: () => onItemTapped(2),
                            color: Colors.black,
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
                            color: Color(0xFF88683E),
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
                      color: Color(0xFF88683E),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () => onItemTapped(0),
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}