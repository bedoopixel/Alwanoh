import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Favorite/FavoritesPage.dart';
import '../Product_Pages/Product_Card.dart';
import '../Product_Pages/Slider_Page.dart';
import '../Profile_Pages/PersonalScreenWidget.dart';
import '../Serves/UserProvider.dart';
import '../Thems/styles.dart';
 // Ensure this path is correct

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
              _buildCustomAppBar(context), // Pass context here
              _buildSearchBar(),
              _buildSectionsHeader(),
              _buildCategoryRow(),
              _buildNewProductsSection(),
              _buildProductGrid(context), // Pass context here
            ],
          ),
        );
      },
    );
  }

  // Refactor the methods to receive the context

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/p1.png',
                  width: 125,
                  height: 75,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    'ALWANOH FOR YEMENI HONEY',
                    style: TextStyle(
                      color: Styles.customColor,
                      fontSize: 16.0,
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
                radius: 20,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Styles.customColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Styles.customColor, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Styles.customColor, width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionsHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Sections',
            style: TextStyle(
              color: Styles.customColor,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryContainer('Honey', 'assets/honey.png'),
          _buildCategoryContainer('Oil', 'assets/oil.png'),
          _buildCategoryContainer('Nets', 'assets/nets.png'),
          _buildCategoryContainer('More', 'assets/more.png'),
        ],
      ),
    );
  }

  Widget _buildCategoryContainer(String label, String assetPath) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Styles.customColor,
          ),
          child: Center(
            child: ClipOval(
              child: Image.asset(
                assetPath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
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

  Widget _buildNewProductsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: NewProductsPage(),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: ProductGridPage(),
    );
  }
}
