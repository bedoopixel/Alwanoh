import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Thems/styles.dart';
import 'UseOrdersPage.dart'; // Import your Styles class

class SelectAddressPage extends StatefulWidget {
  final List<dynamic> cartItems; // Accepting cart items
  final String selectedPaymentMethod; // Accepting selected payment method
  final String selectedDeliveryMethod; // Accepting selected delivery method

  SelectAddressPage({
    Key? key,
    required this.cartItems,
    required this.selectedPaymentMethod,
    required this.selectedDeliveryMethod,
  }) : super(key: key);
  @override
  _SelectAddressPageState createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  String? _selectedAddressId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Delivery Address'),
        backgroundColor: Styles.customColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9), // Set color with 90% opacity
          image: DecorationImage(
            image: AssetImage('assets/back.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
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
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAddressId = address.id; // Update selected address ID
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedAddressId == address.id
                          ? Styles.seconderyColor.withOpacity(0.2) // Highlight color when selected
                          : Styles.customColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Styles.customColor, // Border color
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text('${address['type']}', style: TextStyle(color: Styles.primaryColor)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${address['description']}', style: TextStyle(color: Styles.primaryColor)),
                          Text('Phone: ${address['phone_number']}', style: TextStyle(color: Styles.primaryColor)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_selectedAddressId != null) {
            await _saveOrder(); // Save the order with the selected address
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select an address before saving the order.')),
            );
          }
        },
        backgroundColor: Styles.customColor,
        child: Icon(Icons.save, color: Styles.primaryColor),
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

    // Create order data
    var orderData = {
      'user_id': userId,
      'address_id': _selectedAddressId,
      'cart_items': widget.cartItems.map((item) {
        if (item is Map<String, dynamic>) {
          return item; // Return if already a map
        } else if (item is DocumentSnapshot) {
          return item.data() as Map<String, dynamic>; // Convert Firestore document to map
        }
        // Handle other cases if necessary
        throw Exception('Invalid item type: ${item.runtimeType}'); // Raise an error for invalid types
      }).toList(),
      'payment_method': widget.selectedPaymentMethod,
      'delivery_method': widget.selectedDeliveryMethod,
      'order_state': 'Ready',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .add(orderData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order saved successfully!')),
      );

      // Optionally, navigate back or clear selection
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UseOrdersPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
    }
  }





}

class CartItem {
  final String id;
  final String name;
  final double price;

  CartItem({required this.id, required this.name, required this.price});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}

