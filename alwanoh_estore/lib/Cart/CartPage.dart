import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';
import 'PaymentMethodPage.dart';

class CartBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text('User not logged in', style: TextStyle(fontSize: 16)),
      );
    }

    final String userId = user.uid;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 1.0, // Allow dragging up to full screen
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color:themeProvider.themeMode == ThemeMode.dark
          ? Styles.darkBackground // Dark mode background
            : Styles.lightBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your Cart',
                style: TextStyle(
                  color: Styles.customColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('cart')
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

                    final cartItems = snapshot.data!.docs;
                    double totalPrice = cartItems.fold(0.0, (sum, item) {
                      final price = double.tryParse(item['price'].toString()) ?? 0.0;
                      return sum + price;
                    });

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final cartItem = cartItems[index];
                              final name = cartItem['name'];
                              final price = cartItem['price'];
                              final imageUrl = cartItem['image'];

                              return Dismissible(
                                key: Key(cartItem.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  color: Colors.red,
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (direction) async {
                                  // Delete the item from Firestore
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('cart')
                                      .doc(cartItem.id)
                                      .delete();

                                  // Show a SnackBar notification
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
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: imageUrl != null
                                          ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                          : Icon(Icons.image_not_supported, size: 50),
                                    ),
                                    title: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Styles.customColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '$price YER',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Styles.customColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )

                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: $totalPrice YER',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Styles.customColor,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (cartItems.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentMethodPage(cartItems: cartItems),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Your cart is empty')),
                                    );
                                  }
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
      },
    );
  }
}
