import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Favorite/FavoritesPage.dart';
import '../Product_Pages/Product_Card.dart';
import '../Product_Pages/Slider_Page.dart';
import '../Profile_Pages/PersonalScreenWidget.dart';
import '../Serves/UserProvider.dart';
import '../Thems/styles.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),
    FavoritePage(),
    Placeholder(), // Placeholder بدلًا من CartPage حتى يتم تنفيذه لاحقاً
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
    // الحصول على حجم الشاشة
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // تحديد إذا كانت الشاشة كبيرة
    bool isLargeScreen = screenWidth >= 1920 && screenHeight >= 1080;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        String selectedDocument = userProvider.selectedDocument ?? '';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomAppBarWithSearchBar(context),
              _buildSectionsHeader(),
              isLargeScreen
                  ? _buildLargeScreenCategoryRow()
                  : _buildCategoryRow(),
              _buildNewProductsSection(),
              _buildProductGrid(context, isLargeScreen),
            ],
          ),
        );
      },
    );
  }



  // عناصر إضافية بدون تغيير
  Widget _buildCustomAppBarWithSearchBar(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    double fontSize = screenWidth > 600 ? 14.0 : 16.0; // حجم الخط بناءً على حجم الشاشة
    double iconSize = screenWidth > 600 ? 20.0 : 24.0; // حجم الأيقونة بناءً على حجم الشاشة
    EdgeInsets padding = screenWidth > 600
        ? EdgeInsets.symmetric(horizontal: 32.0) // تباعد أكبر للشاشات الكبيرة
        : EdgeInsets.symmetric(horizontal: 16.0); // تباعد أصغر للشاشات الصغيرة

    // التحكم في عرض شريط البحث
    double searchBarWidth = screenWidth > 1024 ? screenWidth * 0.2 : screenWidth * 0.9;
    double searchBarH = screenH > 1024 ? screenH * 0.2 : screenH * 0.9;
    double containerWidth = screenWidth > 1024 ? screenWidth * 0.75 : screenWidth;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // شريط التطبيق (AppBar)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                width: containerWidth,
                
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 200.0),
                          child: Image(
                            image: AssetImage(
                              'assets/p1.png',
                            ),
                            fit: BoxFit.contain,
                            width: 250,
                            height: 250,
                          ),
                        ),
                        Text(
                          'ALWANOH  YEMENI HONEY',
                          style: TextStyle(
                            color: Styles.customColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10), // مسافة بين الشعار والنص

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
              SizedBox(width: 10,),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: searchBarWidth, // تحديد العرض بناءً على حجم الشاشة
                  maxHeight: 45,
                ),
                child: TextField(
                  onChanged: (query) {
                    // التعامل مع إدخال البحث
                  },
                  style: TextStyle(color: Styles.customColor, fontSize: fontSize),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white54, fontSize: fontSize),
                    prefixIcon: Icon(Icons.search, color: Styles.customColor, size: iconSize),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Styles.customColor,),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Styles.customColor,),
                      borderRadius: BorderRadius.circular(10),
                ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Styles.customColor,),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

            ],
          ),
          // مسافة بين شريط التطبيق وشريط البحث
          // شريط البحث المتجاوب
        ],
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
