import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Cart/OrderStatePage.dart';
import '../Main_Screens/HomePage.dart';
import '../Main_Screens/home.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';


class OrdersManagementPage extends StatefulWidget {
  @override
  _OrdersManagementPageState createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends State<OrdersManagementPage> {
  String _selectedStatus = 'Done'; // Default selected status
  Stream<QuerySnapshot>? _orderStream; // Stream variable to hold order data

  @override
  void initState() {
    super.initState();
    // Initialize the stream with orders based on default status
    _orderStream = _fetchSavedOrders(_selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders Management',
            style: TextStyle(color:themeProvider.themeMode == ThemeMode.dark
                ? Styles.lightBackground // Dark mode background
                : Styles.darkBackground,)),
        backgroundColor:themeProvider.themeMode == ThemeMode.dark
            ? Styles.customColor // Dark mode background
            : Styles.customColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          color:themeProvider.themeMode == ThemeMode.dark
              ? Styles.darkBackground // Dark mode background
              : Styles.lightBackground,
          image: DecorationImage(
            image: AssetImage('assets/back.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildStatusSelectionRow(),
            SizedBox(height: 25),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _orderStream, // Use the stream variable
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No orders available for the selected status.'));
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
                          color:Colors.transparent,
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
                                  SizedBox(height: 8), // Space between text and button
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => OrderStatePage()),
                                      );
                                      print('Track Order pressed for order: ${order.id}');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Styles.customColor, // Button color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),

                                      ),
                                    ),
                                    child: Text('Track Order',
                                        style: TextStyle(color:themeProvider.themeMode == ThemeMode.dark
                                            ? Styles.lightBackground // Dark mode background
                                            : Styles.darkBackground,)),
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()), // Navigate to HomePage
          );
        },
        backgroundColor: Styles.customColor,
        child: Icon(Icons.home, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusSelectionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatusButton('Done'),
        _buildStatusButton('Shipping'),
        _buildStatusButton('Canceled'),
      ],
    );
  }

  Widget _buildStatusButton(String status) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status; // Update selected status
          // Update the order stream based on selected status
          _orderStream = _fetchSavedOrders(status); // Fetch orders based on new status
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
          color: _selectedStatus == status ? Styles.customColor : Styles.seconderyColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Styles.customColor),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: _selectedStatus == status ? Colors.white : Styles.customColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _fetchSavedOrders(String status) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    String userId = user.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('user_order')
        .where('status', isEqualTo: status) // Filter by selected status
        .orderBy('status') // Ascending order for status
        .orderBy('timestamp', descending: true) // Descending order for timestamp
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
