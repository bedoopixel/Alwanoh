// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../Profile_Pages/UseOrdersPage.dart';
//
// class PaymentPage extends StatefulWidget {
//   final List<Map<String, dynamic>> cartItems;
//   final String selectedDeliveryMethod;
//   final String selectedAddressId;
//
//   PaymentPage({
//     required this.cartItems,
//     required this.selectedDeliveryMethod,
//     required this.selectedAddressId,
//   });
//
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> {
//   String? _selectedPaymentMethod;
//
//   void _continueToOrder() async {
//     if (_selectedPaymentMethod == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a payment method.')),
//       );
//       return;
//     }
//
//     // Here you can call your existing _saveOrder() function
//     // and pass the selected payment method.
//     await _saveOrder(_selectedPaymentMethod!);
//   }
//
//   Future<void> _saveOrder(String paymentMethod) async {
//     // Save the order with the selected payment method.
//     final User? user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('User is not logged in. Unable to save order.')),
//       );
//       return;
//     }
//
//     String userId = user.uid;
//
//     if (widget.selectedAddressId == null || widget.cartItems.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select an address and add items to the cart.')),
//       );
//       return; // Exit the function
//     }
//
//     var orderData = {
//       'user_id': userId,
//       'address_id': widget.selectedAddressId,
//       'cart_items': widget.cartItems.map((item) {
//         if (item is Map<String, dynamic>) {
//           return item; // Directly return the map as it is (no need for .data())
//         } else if (item is DocumentSnapshot) {
//           return item.data() as Map<String, dynamic>; // Only call .data() if it's a DocumentSnapshot
//         }
//         throw Exception('Invalid item type: ${item.runtimeType}'); // Handle invalid types
//       }).toList(),
//       'payment_method': paymentMethod,
//       'delivery_method': widget.selectedDeliveryMethod,
//       'order_state': 'Ready',
//       'timestamp': FieldValue.serverTimestamp(),
//     };
//
//
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('order_management')
//           .add(orderData);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Order saved successfully!')),
//       );
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => UseOrdersPage()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving order: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Payment Method'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               'Please select a payment method:',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 20),
//             _buildPaymentMethodOption('Tab'),
//             _buildPaymentMethodOption('Alkuraimi'),
//             _buildPaymentMethodOption('Joal'),
//             SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: _continueToOrder,
//               child: Text('Continue'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethodOption(String method) {
//     return ListTile(
//       title: Text(method),
//       leading: Radio<String>(
//         value: method,
//         groupValue: _selectedPaymentMethod,
//         onChanged: (value) {
//           setState(() {
//             _selectedPaymentMethod = value;
//           });
//         },
//       ),
//     );
//   }
// }
