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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),
    FavoritePage(),
    CartPage(), // Placeholder for CartPage to be implemented later
    PersonalScreenWidget(), // New screen for the person icon
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
        type: BottomNavigationBarType.fixed, // Ensure the background color is applied
        backgroundColor: Colors.black,  // This sets the background to black
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

    );
  }
}


class HomePageContent extends StatefulWidget {
  final String? imageUrl; // Make imageUrl a final parameter

  HomePageContent({Key? key, this.imageUrl}) : super(key: key);


  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late String? _imageUrl; // Local variable to hold imageUrl

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageUrl; // Initialize with the passed imageUrl
    if (_imageUrl == null) {
      _loadImage(); // Load image only if it's not passed
    }
  }

  Future<void> _loadImage() async {
    try {
      String downloadURL = await FirebaseStorage.instance
          .refFromURL('gs://alwanoh-store.appspot.com/Home/p1.png')
          .getDownloadURL();
      print('Image URL: $downloadURL');
      setState(() {
        _imageUrl = downloadURL; // Update local imageUrl
      });
    } catch (e) {
      print('Error fetching image from Firebase Storage: $e');
    }
  }

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

  Widget _buildCustomAppBarWithSearchBar(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    double fontSize = screenWidth > 600 ? 14.0 : 16.0; // حجم الخط بناءً على حجم الشاشة
    double iconSize = screenWidth > 600 ? 24.0 : 20.0; // حجم الأيقونة بناءً على حجم الشاشة
    EdgeInsets padding = screenWidth > 600
        ? EdgeInsets.symmetric(horizontal: 32.0) // تباعد أكبر للشاشات الكبيرة
        : EdgeInsets.symmetric(horizontal: 16.0); // تباعد أصغر للشاشات الصغيرة

    // التحكم في عرض شريط البحث
    double searchBarWidth = screenWidth > 1024 ? screenWidth * 0.2 : screenWidth * 0.95;
    double containerWidth = screenWidth > 1024 ? screenWidth * 0.75 : screenWidth;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Wrap(

            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                width: containerWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _imageUrl == null
                            ? CircularProgressIndicator()
                            : Image.network(
                          _imageUrl!,
                          fit: BoxFit.contain,
                          width: 75,
                          height: 75,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Text('Error loading image', style: TextStyle(color: Colors.red));
                          },
                        ),

                        SizedBox(width: 10),
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

              Padding(
                padding: const EdgeInsets.only(top: 15,left: 15),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: searchBarWidth,
                    maxHeight: 45,
                  ),
                  child: TextField(
                    onChanged: (query) {
                      // التعامل مع إدخال البحث
                    },
                    style: TextStyle(color: Styles.customColor, fontSize: fontSize),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.white54, ),
                      prefixIcon: Icon(Icons.search, color: Styles.customColor, size: iconSize),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Styles.customColor),
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
              ),
            ],
          ),
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
          _buildCategoryContainer('Honey', 'assets/honey.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'Honey'),
              ),
            );
          }),
          _buildCategoryContainer('Oil', 'assets/oil.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'Oil'),
              ),
            );
          }),
          _buildCategoryContainer('Nets', 'assets/nets.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'Nets'),
              ),
            );
          }),
          _buildCategoryContainer('More', 'assets/more.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'More'),
              ),
            );
          }),
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

          _buildCategoryContainer('Honey', 'assets/honey.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'Honey'),
              ),
            );
          }),
          _buildCategoryContainer('Oil', 'assets/oil.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'Oil'),
              ),
            );
          }),
          _buildCategoryContainer('Nets', 'assets/nets.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'Nets'),
              ),
            );
          }),
          _buildCategoryContainer('More', 'assets/more.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'More'),
              ),
            );
          }),
          _buildCategoryContainer('Accessories', 'assets/accessories.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'Accessories'),
              ),
            );
          }),
          _buildCategoryContainer('Tools', 'assets/tools.png', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(category: 'Tools'),
              ),
            );
          }),
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

  Widget _buildCategoryContainer(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 50,
            height: 50,
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(color: Styles.customColor, fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
