import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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


class HomePages extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePages> {
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
      backgroundColor: Colors.black,
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
    return BottomAppBar(
      child: Center(
        child: Container(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rounded container with oval overlap
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 250,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFD4AC78),
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
                  Positioned(
                    right: -30,
                    top: 0,
                    child: ClipOval(
                      child: Container(
                        width: 50,
                        height: 56,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              // Home icon with rounded circle
              Transform.translate(
                offset: Offset(-15, 0),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFD4AC78),
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
      color: Colors.transparent,
    );
  }
}


// Rest of your HomePageContent code...
