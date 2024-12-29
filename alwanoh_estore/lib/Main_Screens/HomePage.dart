import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../Cart/CartPage.dart';
import '../Favorite/FavoritesPage.dart';
import '../Products/Final_Products.dart';
import '../Products/Product_Slider.dart';
import '../Products/Products_All.dart';
import '../Products/Products_Main.dart';
import '../Products/all_products.dart';
import '../Profile_Pages/PersonalScreenWidget.dart';
import '../SearchPage.dart';
import '../Thems/styles.dart';


class HomePage extends StatefulWidget {

  String? _imageUrl; // Allow null values initially

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    _requestPermissions();
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(message.notification?.title ?? ''),
          content: Text(message.notification?.body ?? ''),
        ),
      );
    });

    // Handle notification clicks (when app is in background or terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.data}');
      _handleNotificationClick(message);
    });

    // Get the device token (for sending notifications)
    _getDeviceToken();
    _imageUrl = widget._imageUrl ?? ''; // Initialize with an empty string if null
    if (_imageUrl == '') {
      _loadImage(); // Load image only if it's not passed
    }
  }
  Future<void> _requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions.');
    } else {
      print('User declined or has not accepted notification permissions.');
    }
  }

  Future<void> _getDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('Device token: $token');
    // Save this token to your server for sending notifications.
  }

  void _handleNotificationClick(RemoteMessage message) {
    // Handle navigation based on the notification data
    if (message.data['screen'] != null) {
      Navigator.pushNamed(context, message.data['screen']);
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
            padding: const EdgeInsets.only(top: 100.0), // Add padding to prevent overlap with the fixed app bar
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Wrap(

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
                                onPressed: () => showCartBottomSheet(context),

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


              ],
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



class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex; // Track the selected index
  final Function(int) onItemTapped; // Callback for item tap

  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20), // Adds space on left and right
        child: BottomAppBar(
          color: Colors.transparent, // Set to transparent for a floating effect
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
                          color: Color(0xff9c774c),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(27.5),
                            bottomLeft: Radius.circular(27.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Person icon
                            IconButton(
                              icon: Icon(
                                Icons.search,
                                color: selectedIndex == 3 ? Colors.black : Colors.white, // Change color based on selection
                              ),
                              onPressed: () {
                                onItemTapped(0); // Pass index to callback
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(),
                                  ),
                                );
                              },
                            ),
                            // Favorite icon
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: selectedIndex == 1 ? Colors.black : Colors.white, // Change color based on selection
                              ),
                              onPressed: () {
                                onItemTapped(1); // Pass index to callback
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoritePage(),
                                  ),
                                );
                              },
                            ),
                            // Shopping cart icon
                            IconButton(
                              icon: Icon(
                                Icons.shopping_cart,
                                color: selectedIndex == 2 ? Colors.black : Colors.white, // Change color based on selection
                              ),

                                onPressed: () => showCartBottomSheet(context),

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
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 90 90" preserveAspectRatio="xMidYMid meet" style="width: 100%; height: auto;">
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
                              color: Color(0xff9c774c),
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
                        color: Color(0xff9c774c),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.home,
                          color: selectedIndex == 0 ? Colors.black : Colors.white, // Change color based on selection
                        ),
                        onPressed: () {
                          onItemTapped(3); // Pass index to callback
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
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

  void showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(),
    );
  }
}









