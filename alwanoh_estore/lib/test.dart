import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'Cart/CartPage.dart';
import 'Favorite/FavoritesPage.dart';
import 'P_Sliders/O_slider.dart';
import 'P_Sliders/discount_slider.dart';
import 'P_Sliders/isNew_slider.dart';
import 'Product_Pages/Product_Card.dart';
import 'Product_Pages/ProductsPage.dart';
import 'Product_Pages/Slider_Page.dart';
import 'Profile_Pages/PersonalScreenWidget.dart';
import 'Thems/styles.dart';

class HomePages extends StatefulWidget {

  String? _imageUrl; // Allow null values initially

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePages> {
  int _selectedIndex = 0;
  late String? _imageUrl;
  String _searchQuery = "";
  List<Map<String, dynamic>> _products = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation or actions based on the selected index
  }
  @override
  void initState() {
    super.initState();
    _imageUrl = widget._imageUrl ?? ''; // Initialize with an empty string if null
    if (_imageUrl == '') {
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
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Scrollable content
          Padding(
            padding: const EdgeInsets.only(top: 150.0), // Add padding to prevent overlap with the fixed app bar
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    NewProductsPage(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('New', style: TextStyle(
                            color: Styles.customColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsPage(filterType: 'isNew', category: 'Oil'),

                                ),
                              );

                            },
                            child: Text('More >>', style: TextStyle(
                              color: Styles.customColor,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3, // Adjust the height as needed
                      child: ProductGridPage(searchQuery: _searchQuery, products: _products),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Offers', style: TextStyle(
                            color: Styles.customColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsPage( category: '', filterType: 'discount',),
                                ),
                              );
                            },
                            child: Text('More >>', style: TextStyle(
                              color: Styles.customColor,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3, // Adjust the height as needed
                      child: IsnewSlider(searchQuery: _searchQuery, products: _products),
                    ),
                    NewProductsPage(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('All', style: TextStyle(
                            color: Styles.customColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsPage(filterType: 'all', category: 'all'),

                                ),
                              );

                            },
                            child: Text('More >>', style: TextStyle(
                              color: Styles.customColor,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3, // Adjust the height as needed
                      child: DiscountSlider(searchQuery: _searchQuery, products: _products),
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
                        Container(
                          width: MediaQuery.of(context).size.width <= 600 ? 150.0 : null,
                          child: Text(
                            'ALWANOH FOR YEMENI HONEY',
                            style: TextStyle(
                              color: Styles.customColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (screenWidth >= 1200) ...[
                            SizedBox(width: 10),
                            // أيقونة المفضلة
                            IconButton(
                              icon: Icon(Icons.favorite, color: Styles.customColor, size: 40),
                              onPressed: () {
                                // انتقل إلى صفحة المفضلة
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoritePage(),
                                  ),
                                );
                              },
                            ),
                            // أيقونة السلة
                            IconButton(
                              icon: Icon(Icons.shopping_cart, color: Styles.customColor, size: 40),
                              onPressed: () {
                                // انتقل إلى صفحة السلة
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CartPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                          // أيقونة الملف الشخصي
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 5),
                            child: GestureDetector(
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
                                  size: 24, // تغيير الحجم إلى 24
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15,left: 5),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: searchBarWidth,
                    maxHeight: 45,
                  ),
                  child: TextField(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query; // Update the search query
                      });
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30), // Adds space on left and right
        child: BottomAppBar(
          color: Colors.transparent,
          // Set to transparent for a floating effect
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
      ),
    );
  }
}








