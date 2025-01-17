import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Cart/CartPage.dart';
import '../Favorite/FavoritesPage.dart';
import '../Thems/styles.dart';
import 'Main_Screens/HomePage.dart';
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
}















