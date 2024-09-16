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
    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Check if the screen is 1920x1080 or larger
    bool isLargeScreen = screenWidth >= 1920 && screenHeight >= 1080;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        String selectedDocument = userProvider.selectedDocument ?? '';

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              _buildSearchBar(),
              _buildSectionsHeader(),
              isLargeScreen
                  ? _buildLargeScreenCategoryRow()
                  : _buildCategoryRow(),
              _buildNewProductsSection(),
              _buildProductGrid(context, isLargeScreen),
              // _buildLSearchBar(context,isLargeScreen),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check screen size for responsiveness
        bool isLargeScreen = constraints.maxWidth >= 1920 && constraints.maxHeight >= 1080;

        return Container(
          color: Colors.black,
          padding: EdgeInsets.all(isLargeScreen ? 32.0 : 16.0), // Larger padding for bigger screens
          child: Padding(
            padding: EdgeInsets.only(top: isLargeScreen ? 50 : 30), // Adjusted padding for larger screens
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/p1.png',
                      width: isLargeScreen ? 200 : 125, // Adjust image size
                      height: isLargeScreen ? 100 : 75, // Adjust image size
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: isLargeScreen ? 50 : 30), // Adjust padding
                      child: Text(
                        'ALWANOH FOR YEMENI HONEY',
                        style: TextStyle(
                          color: Styles.customColor,
                          fontSize: isLargeScreen ? 24.0 : 16.0, // Adjust text size
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
                    radius: isLargeScreen ? 30 : 20, // Adjust icon size
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                      size: isLargeScreen ? 32 : 24, // Adjust icon size
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth >= 1920 && constraints.maxHeight >= 1080;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32.0 : 16.0), // Adjust padding
          child: TextField(
            onChanged: (query) {
              // Handle search query changes if needed
            },
            style: TextStyle(color: Styles.customColor, fontSize: isLargeScreen ? 20.0 : 14.0), // Adjust font size
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white54, fontSize: isLargeScreen ? 18.0 : 14.0), // Adjust hint text size
              prefixIcon: Icon(Icons.search, color: Styles.customColor, size: isLargeScreen ? 32.0 : 24.0), // Adjust icon size
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
      },
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

  // For large screens (1920x1080 or larger)
  Widget _buildLCustomAppBar(BuildContext context) {
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

  Widget _buildLSearchBar(BuildContext context, bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
  Widget _buildLargeScreenCategoryRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryContainer('Honey', 'assets/honey.png'),
          _buildCategoryContainer('Oil', 'assets/oil.png'),
          _buildCategoryContainer('Nets', 'assets/nets.png'),
          _buildCategoryContainer('More', 'assets/more.png'),
          _buildCategoryContainer('Accessories', 'assets/accessories.png'),
          _buildCategoryContainer('Tools', 'assets/tools.png'),
        ],
      ),
    );
  }

  Widget _buildNewProductsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: NewProductsPage(),
    );
  }

  Widget _buildProductGrid(BuildContext context, bool isLargeScreen) {
    return SizedBox(
      height: isLargeScreen
          ? MediaQuery.of(context).size.height * 0.6
          : MediaQuery.of(context).size.height * 0.4,
      child: ProductGridPage(),
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
}

