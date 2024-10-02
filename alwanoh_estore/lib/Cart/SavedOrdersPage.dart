import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../Thems/styles.dart';

class SavedOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Orders'),
        backgroundColor: Styles.customColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchSavedOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No saved orders found.'));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];

              // Access the first cart item for display
              List<dynamic> cartItems = order['cart_items'];
              var firstItem = cartItems.isNotEmpty ? cartItems[0] : null;

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Styles.seconderyColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Styles.customColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (firstItem != null && firstItem['image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          firstItem['image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Final Total: ${_formatCurrency(order['final_total'])}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Styles.customColor),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Order Placed: ${_formatDate(order['timestamp'])}',
                            style: TextStyle(color: Styles.customColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _fetchSavedOrders() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    String userId = user.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('order_management')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.simpleCurrency(decimalDigits: 0);
    return format.format(amount);
  }

  String _formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(date);
  }
}
