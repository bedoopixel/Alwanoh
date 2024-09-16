import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Favorite/FavoritesPage.dart';
import '../Product_Pages/Product_Card.dart';
import '../Product_Pages/Slider_Page.dart';
import '../Profile_Pages/PersonalScreenWidget.dart';
import '../Serves/UserProvider.dart';
import '../Thems/styles.dart'; // Ensure this path is correct

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(), // The content of HomePage
    FavoritePage(), // Add your FavoritePage widget here
    // CartPage(), // Add your CartPage widget here
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Styles.customColor,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        String selectedDocument = userProvider.selectedDocument ?? '';

        return SingleChildScrollView(
          child: Column(
            children: [
              // Custom Row replacing the AppBar
              _buildCustomAppBar(context),
              _buildSearchBar(context),
              _buildSectionsHeader(),
              _buildCategoryRow(context),
              _buildNewProductsSection(),
              _buildProductGrid(context),
            ],
          ),
        );
      },
    );
  }

  // Make custom app bar responsive
  Widget _buildCustomAppBar(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.only(top: screenWidth * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/p1.png',
                  width: screenWidth * 0.35,
                  height: screenWidth * 0.21,
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  child: Text(
                    'ALWANOH FOR YEMENI HONEY',
                    style: TextStyle(
                      color: Styles.customColor,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalScreenWidget(),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Styles.customColor,
                radius: screenWidth * 0.06,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                  size: screenWidth * 0.06,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Make search bar responsive
  Widget _buildSearchBar(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: TextField(
        onChanged: (query) {
          // Handle search query changes if needed
        },
        style: TextStyle(color: Styles.customColor),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: Styles.customColor),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            borderSide: BorderSide(color: Styles.customColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            borderSide: BorderSide(color: Styles.customColor, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            borderSide: BorderSide(color: Styles.customColor, width: 2.0),
          ),
        ),
      ),
    );
  }

  // Sections header
  Widget _buildSectionsHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Sections',
        style: TextStyle(
          color: Styles.customColor,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Make category row responsive
  Widget _buildCategoryRow(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryContainer(context, 'Honey', 'assets/honey.png'),
          _buildCategoryContainer(context, 'Oil', 'assets/oil.png'),
          _buildCategoryContainer(context, 'Nets', 'assets/nets.png'),
          _buildCategoryContainer(context, 'More', 'assets/more.png'),
        ],
      ),
    );
  }

  // Make category container responsive
  Widget _buildCategoryContainer(BuildContext context, String label, String assetPath) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.15,
          height: screenWidth * 0.15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Styles.customColor,
          ),
          child: Center(
            child: ClipOval(
              child: Image.asset(
                assetPath,
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          label,
          style: TextStyle(color: Styles.customColor),
        ),
      ],
    );
  }

  // New products section
  Widget _buildNewProductsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: NewProductsPage(),
    );
  }

  // Make product grid responsive
  Widget _buildProductGrid(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.4,
      child: ProductGridPage(),
    );
  }
}
