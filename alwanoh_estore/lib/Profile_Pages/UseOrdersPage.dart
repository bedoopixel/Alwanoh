import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl for number formatting
import 'package:provider/provider.dart';
import '../Cart/OrderStatePage.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';
import 'OrdersManagementPage.dart'; // Import your Styles class

class UseOrdersPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders',style: TextStyle(
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
          color:themeProvider.themeMode == ThemeMode.dark
              ? Styles.darkBackground // Dark mode background
              : Styles.lightBackground,// Set color with 90% opacity
          image: DecorationImage(
            image: AssetImage('assets/back.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _fetchUserOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No orders found.'));
            }

            // Extracting orders data for further processing
            var order_management = snapshot.data!.docs;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: order_management.length,
                    itemBuilder: (context, index) {
                      var order = order_management[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Map<String, dynamic>?>( // Fetch address
                              future: _fetchAddressById(order['address_id']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Text('Error fetching address: ${snapshot.error}');
                                }
                                if (!snapshot.hasData || snapshot.data == null) {
                                  return Text('Address not found.');
                                }

                                var address = snapshot.data!;
                                return Container(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  padding: EdgeInsets.all(20), // Adjusted padding
                                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Same margin
                                  decoration: BoxDecoration(
                                      color:themeProvider.themeMode == ThemeMode.dark
                                          ? Styles.darkBackground // Dark mode background
                                          : Styles.lightBackground, // Use secondaryColor for the background
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                    border: Border.all(
                                      color: Styles.customColor, // Border color
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Type: ${address['type']}', style: TextStyle(fontWeight: FontWeight.w500, color: Styles.customColor)),
                                      Text('Description: ${address['description']}', style: TextStyle(fontWeight: FontWeight.w500, color: Styles.customColor)),
                                      Text('Phone: ${address['phone_number']}', style: TextStyle(fontWeight: FontWeight.w500, color: Styles.customColor)),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            ..._buildCartItemsWidgets(order['cart_items'],context),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Add the cost display widget below the ListView
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: Styles.customColor),
                      _buildCostDisplay(order_management), // Pass orders to the cost display
                      SizedBox(height: 16), // Add some space before the button
                      Center(
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Styles.customColor, width: 2), // Set border color and width
                              borderRadius: BorderRadius.circular(30), // Ensure rounded corners
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  // Iterate through the orders to save each one
                                  for (var order in order_management) {
                                    DocumentReference orderRef = order.reference; // Get the reference to the order
                                    await _saveOrderToFirestore(orderRef, user.uid, order_management);
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OrdersManagementPage()),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not authenticated')));
                                }
                              },
                              child: Text('Order',
                                  style: TextStyle(color:themeProvider.themeMode == ThemeMode.dark
                                      ? Styles.lightBackground // Dark mode background
                                      : Styles.darkBackground,)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:themeProvider.themeMode == ThemeMode.dark
                                    ? Styles.darkBackground // Dark mode background
                                    : Styles.lightBackground,
                                minimumSize: Size(200, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCostDisplay(List<QueryDocumentSnapshot> orders) {
    double totalCost = 0.0;
    double deliveryCost = 1000.0;

    // Calculate the total cost from all orders
    for (var order in orders) {
      totalCost += _calculateTotalCost(order['cart_items']);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          'Total Cost: ${_formatCurrency(totalCost)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Styles.customColor),
        ),
        SizedBox(height: 5),
        Text(
          'Delivery Cost: ${_formatCurrency(deliveryCost)}', // Display delivery cost
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Styles.customColor),
        ),
        SizedBox(height: 5),
        Divider(color: Styles.customColor),
        Text(
          'Final Total: ${_formatCurrency(totalCost + deliveryCost)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Styles.customColor),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _fetchUserOrders() async* {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      yield* Stream.empty();
      return;
    }

    String userId = user.uid;
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('order_management')
        .snapshots();
  }

  List<Widget> _buildCartItemsWidgets(List<dynamic> cartItems, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return cartItems.map<Widget>((item) {
      return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: themeProvider.themeMode == ThemeMode.dark
              ? Styles.darkBackground // Dark mode background
              : Styles.lightBackground, // Light mode background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Styles.customColor, // Border color from Styles
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item['image'] != null && item['image'].isNotEmpty
                  ? Image.network(
                item['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 50,
                height: 50,
                color: Colors.grey,
                child: Icon(Icons.image, color: Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Unknown Item',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Colors.white // Dark mode text color
                          : Styles.customColor, // Light mode text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${item['price'].toString()}',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Colors.white70 // Dark mode price color
                          : Styles.customColor.withOpacity(0.8), // Light mode price color
                    ),
                  ),
                  Text(
                    'Qty: ${item['quantity'].toString()}',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Colors.white70 // Dark mode quantity color
                          : Styles.customColor.withOpacity(0.8), // Light mode quantity color
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }


  Future<Map<String, dynamic>?> _fetchAddressById(String addressId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final addressSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('address')
          .doc(addressId)
          .get();

      if (addressSnapshot.exists) {
        return addressSnapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching address: $e');
      return null;
    }
  }

  double _calculateTotalCost(List<dynamic> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      total += (item['price'] ?? 0);
    }
    return total;
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.simpleCurrency(decimalDigits: 0);
    return format.format(amount);
  }

  Future<void> _saveOrderToFirestore(
      DocumentReference orderRef,
      String userId,
      List<QueryDocumentSnapshot> orders,) async {
    double totalCost = 0.0;
    double deliveryCost = 1000.0;

    // Calculate total cost
    for (var order in orders) {
      totalCost += _calculateTotalCost(order['cart_items']);
    }

    // Flatten cart items (avoiding nested arrays)
    List<Map<String, dynamic>> allCartItems = [];
    String? addressId; // To store the address ID
    for (var order in orders) {
      List<dynamic> cartItems = order['cart_items'];
      addressId = order['address_id']; // Fetch the address_id from the order
      cartItems.forEach((item) {
        allCartItems.add(Map<String, dynamic>.from(item));
      });
    }

    // Create an order object with relevant fields, including address_id
    Map<String, dynamic> orderData = {
      'cart_items': allCartItems,
      'total_cost': totalCost,
      'delivery_cost': deliveryCost,
      'final_total': totalCost + deliveryCost,
      'timestamp': Timestamp.now(),
      'status': 'Done', // Set the order status
      'address_id': addressId, // Save the address_id
    };

    // Save order in Firestore under 'users/{userId}/order_management'
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('user_order')
        .add(orderData);

    // Delete the order from the original orders collection
    await orderRef.delete(); // Delete the order after successful save

    // Delete all documents from the user's cart collection
    await _clearUserCart(userId);
  }


  Future<void> _clearUserCart(String userId) async {
    var cartCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('cart');
    var cartSnapshot = await cartCollection.get();

    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
