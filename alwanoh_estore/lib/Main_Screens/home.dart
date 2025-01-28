import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Cart/CartPage.dart';
import '../Products/Final_Products.dart';
import '../Products/Product_Slider.dart';
import '../Products/Products_All.dart';
import '../Products/Products_Main.dart';
import '../Products/all_products.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';
import '../test/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String? _imageUrl;
  String _searchQuery = "";
  List<Map<String, dynamic>> _products = [];
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarDividerColor: Color(0xff212121),
      systemNavigationBarColor: Color(0xff212121),
      statusBarColor: defaultBackgroundColor,
    ));
    super.initState();
  }

  int currentIndexBottomBar = 0;
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
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? Styles.seconderyColor // Dark mode background
          : defaultBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 60),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false, // Removes the back arrow
          title: Row(
            children: [
              Image.asset(
                'assets/app_icon.png', // Path to your internal image
                width: 60, // Adjust the width of the icon as needed
                height: 60, // Adjust the height of the icon as needed
              ),
              SizedBox(width: 10),
              Container(
                width: MediaQuery.of(context).size.width <= 600 ? 190.0 : null,
                child: Text(
                  'ALWANOH FOR \nYEMENI HONEY',
                  style: TextStyle(
                    color: Styles.customColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SizedBox(
        width: w,
        height: h,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 20,),
              ProductSlider(filter: 'isNew',),
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
                            builder: (context) => ProductsMain(searchQuery: _searchQuery, products: _products, filter: 'isNew', title: 'New',),

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
                child: ProductsAll(searchQuery: _searchQuery, products: _products, filter: 'isNew',),
              ),
              ProductSlider(filter: 'isOnOffer',),
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
                            builder: (context) => ProductsMain(searchQuery: _searchQuery, products: _products, filter: 'isOnOffer', title: 'Offers',),

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
                child: ProductsAll(searchQuery: _searchQuery, products: _products, filter: 'isOnOffer',),
              ),
              ProductSlider(filter: 'isOnOffer',),
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
                            builder: (context) => AllProducts(searchQuery: _searchQuery, products: _products,  ),

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
              FinalProducts(searchQuery: _searchQuery, products: _products, ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1, // Adjust the height as needed
              ),
            ],
          ),
        ),
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

  void showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(),
    );
  }


}
