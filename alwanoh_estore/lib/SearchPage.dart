import 'package:alwanoh_estore/test/constants.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Thems/styles.dart';
import 'Cart/CartPage.dart';
import 'Search_Result.dart';
import 'Thems/ThemeProvider.dart';


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
  int currentIndexBottomBar = 1;
  int currentIndexSwiperHome = 0;

  final iconList = <IconData>[
    Icons.home_outlined,
    Icons.search,
    Icons.person_outline,
    Icons.favorite_border_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBody: true,
      backgroundColor:themeProvider.themeMode == ThemeMode.dark
    ? Styles.darkBackground // Dark mode background
      : Styles.lightBackground,
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

  Widget _buildCustomAppBarWithSearchBar(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width > 600 ? 14.0 : 16.0;
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                  hintStyle: TextStyle(color: themeProvider.themeMode == ThemeMode.dark
                  ? Styles.lightBackground // Dark mode background
                    : Styles.darkBackground,),
                  prefixIcon: Icon(Icons.search, color: Styles.customColor),
                  filled: true,
                  fillColor:themeProvider.themeMode == ThemeMode.dark
                      ? Styles.darkBackground // Dark mode background
                      : Styles.lightBackground,
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
  void showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(),
    );
  }
}















