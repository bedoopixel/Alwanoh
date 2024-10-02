import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Thems/styles.dart';
import 'PaymentMethodPage.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user ID
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cart', style: TextStyle(color: Colors.white)),
          backgroundColor: Styles.customColor,
        ),
        body: Center(
          child: Text('User not logged in', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      backgroundColor: Styles.primaryColor,
      body: Column(
        children: [
          Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(top: 30, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ' Cart',
                  style: TextStyle(color: Styles.customColor, fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('cart') // Fetch cart items from the specific user's cart
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
                  );
                }

                // List of cart items
                final cartItems = snapshot.data!.docs;

                // Calculate total price
                double totalPrice = cartItems.fold(0.0, (sum, item) {
                  final price = double.tryParse(item['price'].toString()) ?? 0.0; // Ensure price is parsed correctly
                  final quantity = double.tryParse(item['quantity'].toString()) ?? 1.0; // Ensure quantity is parsed correctly
                  return sum + (price  ); // Calculate total based on price and quantity
                });

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartItems[index];
                          final name = cartItem['name'];
                          final quantity = cartItem['quantity'];
                          final price = cartItem['price'];
                          final imageUrl = cartItem['image'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Dismissible(
                                key: Key(cartItem.id),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  color: Styles.customColor,
                                  child: Icon(Icons.delete, color: Colors.black),
                                ),
                                onDismissed: (direction) async {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('cart')
                                      .doc(cartItem.id)
                                      .delete();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$name removed from cart')),
                                  );
                                },
                                child: Card(
                                  color: Styles.seconderyColor,
                                  margin: EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Styles.customColor,
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                'الكمية: ${quantity.toString()}',
                                                style: TextStyle(fontSize: 14, color: Styles.customColor),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '$price YER',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Styles.customColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 25),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: imageUrl != null
                                              ? Image.network(
                                            imageUrl,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                          )
                                              : Icon(Icons.image_not_supported, size: 70),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(color: Colors.grey[700], thickness: 1),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: $totalPrice YER',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Styles.customColor),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Pass the cart items to PaymentMethodPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentMethodPage(cartItems: cartItems), // Pass the list of cart items
                                ),
                              );
                            },
                            child: Text('Buy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.customColor,
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
        ],
      ),
    );
  }
}
