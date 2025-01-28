import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps package
import 'package:provider/provider.dart';
import '../Cart/PaymentMethodPage.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';
import 'AddAddressPage.dart';
import 'UseOrdersPage.dart'; // Import your Styles class

class SelectAddressPage extends StatefulWidget {
  final List<dynamic> cartItems; // Accepting cart items
  final String selectedDeliveryMethod; // Accepting selected delivery method

  SelectAddressPage({
    Key? key,
    required this.cartItems,
    required this.selectedDeliveryMethod,
  }) : super(key: key);
  @override
  _SelectAddressPageState createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  String? _selectedAddressId;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Delivery Address',style: TextStyle(
          color:themeProvider.themeMode == ThemeMode.dark
              ? Styles.darkBackground // Dark mode background
              : Styles.lightBackground,
        ),),
        backgroundColor:themeProvider.themeMode == ThemeMode.dark
            ? Styles.customColor // Dark mode background
            : Styles.customColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: themeProvider.themeMode == ThemeMode.dark
              ? Styles.darkBackground
              : Styles.lightBackground,
          image: DecorationImage(
            image: AssetImage('assets/back.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchUserAddresses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No addresses found.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var address = snapshot.data!.docs[index];
                      GeoPoint? location = address['location'] as GeoPoint?;
                      LatLng? latLng =
                      location != null ? LatLng(location.latitude, location.longitude) : null;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAddressId = address.id;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _selectedAddressId == address.id
                                ? Styles.seconderyColor.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Styles.customColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: ListTile(
                                  title: Text(
                                    '${address['type']}',
                                    style: TextStyle(
                                      color: themeProvider.themeMode == ThemeMode.dark
                                          ? Styles.lightBackground
                                          : Styles.darkBackground,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5),
                                      Text(
                                        'Description: ${address['description']}',
                                        style: TextStyle(
                                          color: themeProvider.themeMode == ThemeMode.dark
                                              ? Styles.lightBackground
                                              : Styles.darkBackground,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Phone: ${address['phone_number']}',
                                        style: TextStyle(
                                          color: themeProvider.themeMode == ThemeMode.dark
                                              ? Styles.lightBackground
                                              : Styles.darkBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: latLng != null
                                    ? Container(
                                  width: 70,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Styles.customColor),
                                  ),
                                  child: ClipOval(
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: latLng,
                                        zoom: 14.0,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: MarkerId('address-$index'),
                                          position: latLng,
                                        ),
                                      },
                                      zoomControlsEnabled: false,
                                      scrollGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                    ),
                                  ),
                                )
                                    : Center(
                                  child: Text(
                                    'Location not available',
                                    style: TextStyle(color: Styles.primaryColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // ElevatedButton at the bottom
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_selectedAddressId != null) {
                    await _saveOrder(); // Save the order with the selected address
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select an address before saving the order.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.customColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 12.0),
                ),
                label: Text(
                  'Save Order',
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Styles.darkBackground
                        : Styles.lightBackground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),


        floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddAddressPage()),
          );
        },
        backgroundColor: Styles.customColor,
        child: Icon(Icons.add, color:themeProvider.themeMode == ThemeMode.dark
            ? Styles.darkBackground // Dark mode background
            : Styles.lightBackground,),
      ),
    );
  }

  Stream<QuerySnapshot> _fetchUserAddresses() async* {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      yield* Stream.empty(); // Return an empty stream if user is not logged in
      return; // Exit the function
    }

    String userId = user.uid; // Get the actual user ID from your auth provider
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('address') // Fetch addresses from the specific user's addresses
        .snapshots();
  }

  Future<void> _saveOrder() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in. Unable to save order.')),
      );
      return; // Exit the function
    }

    String userId = user.uid;

    if (_selectedAddressId == null || widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an address and add items to the cart.')),
      );
      return; // Exit the function
    }

    var orderData = {
      'user_id': userId,
      'address_id': _selectedAddressId,
      'cart_items': widget.cartItems.map((item) {
        if (item is Map<String, dynamic>) {
          return item; // Return if already a map
        } else if (item is DocumentSnapshot) {
          return item.data() as Map<String, dynamic>; // Convert Firestore document to map
        }
        throw Exception('Invalid item type: ${item.runtimeType}'); // Raise an error for invalid types
      }).toList(),
      'delivery_method': widget.selectedDeliveryMethod,
      'order_state': 'Ready',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('order_management')
          .add(orderData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order saved successfully!')),
      );

      // Navigate to UseOrdersPage after saving the order, replacing the current screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentMethodPage(cartItems:widget.cartItems,)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
    }
  }

}
