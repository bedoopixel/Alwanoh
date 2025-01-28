import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Profile_Pages/UseOrdersPage.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';

class PaymentMethodPage extends StatefulWidget {
  final List<dynamic> cartItems; // Accepting cart items

  PaymentMethodPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? _selectedPaymentMethod;
  String finalTotal = "0.0"; // Default final total
  String? userName;
  String? userEmail;
  String? userPhone;
  List<dynamic> cartItems = []; // List to store cart items

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data from Firestore
    _fetchCartItems(); // Fetch cart items and calculate total
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = userDoc['name'];
        userEmail = userDoc['email'];
        userPhone = userDoc['phoneNumber'];
      });
    }
  }

  // Fetch cart items and calculate the total amount
  void _fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      double total = 0.0;
      cartSnapshot.docs.forEach((doc) {
        final price = doc['price']; // Assuming price is stored as 'price'
        total += price;
      });

      setState(() {
        finalTotal = total.toStringAsFixed(2); // Convert to string with 2 decimal places
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Payment Method',
          style: TextStyle(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Styles.darkBackground // Dark mode background
                : Styles.lightBackground,
          ),
        ),
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? Styles.customColor // Dark mode background
            : Styles.customColor, // Using customColor from Styles
      ),
      body: Container(
        decoration: BoxDecoration(
          color: themeProvider.themeMode == ThemeMode.dark
              ? Styles.darkBackground // Dark mode background
              : Styles.lightBackground, // Set color with 90% opacity
          image: DecorationImage(
            image: AssetImage('assets/back.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a payment method:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Styles.customColor, // Custom text color
              ),
            ),
            SizedBox(height: 20),
            _buildPaymentMethodContainer('Tab'),
            SizedBox(height: 10),
            _buildPaymentMethodContainer('MasterCard'),
            SizedBox(height: 10),
            _buildPaymentMethodContainer('Union Western'),
            SizedBox(height: 30),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Styles.customColor, width: 2),
                  borderRadius: BorderRadius.circular(30), // Border color and width
                ),
                child: ElevatedButton(
                  onPressed: _selectedPaymentMethod == null
                      ? null
                      : () {
                    if (_selectedPaymentMethod == 'Tab') {
                      _startTabPayment();
                    } else {
                      // Handle other payment methods
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UseOrdersPage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.themeMode == ThemeMode.dark
                        ? Styles.darkBackground // Dark mode background
                        : Styles.lightBackground, // Button background color
                    minimumSize: Size(200, 50), // Minimum size for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                  ),
                  child: Text(
                    'Proceed',
                    style: TextStyle(
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Styles.lightBackground // Dark mode background
                          : Styles.darkBackground, // White text color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to start the Tab payment process
  void _startTabPayment() async {
    if (userName == null || userEmail == null || userPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User data not found, please try again.'),
      ));
      return;
    }

    final String secretKey = 'sk_test_8Bs3J9HAuN7UeIvwaXSmzQhV';
    final url = Uri.parse('https://api.tap.company/v2/charges');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "amount": finalTotal, // Use the final total from the cart items
      "currency": "USD", // Replace with your currency
      "description": "Test Payment",
      "customer": {
        "name": userName,
        "email": userEmail,
        "phone": {"country_code": "965", "number": userPhone}
      },
      "source": {"id": "src_all"}, // For test purposes, allow all sources
      "redirect": {
        "url": "myapp://payment-result"
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final redirectUrl = responseData['transaction']['url'];
        if (await canLaunchUrlString(redirectUrl)) {
          await launchUrlString(redirectUrl);
        } else {
          throw 'Could not launch $redirectUrl';
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        print("Payment Error: $errorMessage");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Error: $errorMessage")),
        );
      }
    } catch (e) {
      print("Error launching URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Method to create a payment method inside a container
  Widget _buildPaymentMethodContainer(String method) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == method
              ? Styles.seconderyColor.withOpacity(0.2) // Change color when selected
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Styles.customColor, // Border color for the container
              width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              method,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _selectedPaymentMethod == method
                    ? Styles.customColor
                    : Styles.customColor,
              ),
            ),
            if (_selectedPaymentMethod == method)
              Icon(
                Icons.check_circle,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Styles.customColor // Dark mode background
                    : Styles.customColor,
              ), // Check icon for selected method
          ],
        ),
      ),
    );
  }
}


class LeftCarveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0); // Top-right corner
    path.lineTo(size.width, size.height); // Bottom-right corner
    path.lineTo(30, size.height); // Bottom-left corner with some offset
    path.quadraticBezierTo(0, size.height / 2, 30, 0); // Carved left side
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
