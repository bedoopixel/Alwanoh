import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';
import 'DeliveryMethodPage.dart';

class PaymentMethodPage extends StatefulWidget {
  final List<dynamic> cartItems; // Accepting cart items

  PaymentMethodPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? _selectedPaymentMethod;


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Payment Method',style: TextStyle(
        color:themeProvider.themeMode == ThemeMode.dark
        ? Styles.darkBackground // Dark mode background
            : Styles.lightBackground,
        ),),
        backgroundColor:themeProvider.themeMode == ThemeMode.dark
      ? Styles.customColor // Dark mode background
        : Styles.customColor, // Using customColor from Styles
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
            _buildPaymentMethodContainer('PayPal'),
            SizedBox(height: 10),
            _buildPaymentMethodContainer('MasterCard'),
            SizedBox(height: 10),
            _buildPaymentMethodContainer('Union Western'),
            SizedBox(height: 30),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Styles.customColor, width: 2),
                  borderRadius: BorderRadius.circular(30),// Border color and width
                ),
                child: ElevatedButton(
                  onPressed: _selectedPaymentMethod == null
                      ? null
                      : () {
                    if (_selectedPaymentMethod == 'MasterCard') {
                      _showDemoPaymentDialog(); // Show demo payment dialog
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryMethodPage(
                            cartItems: widget.cartItems,
                            selectedPaymentMethod: _selectedPaymentMethod!,
                          ),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected: $_selectedPaymentMethod'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:themeProvider.themeMode == ThemeMode.dark
                  ? Styles.darkBackground // Dark mode background
                    : Styles.lightBackground,// Button background color
                    minimumSize: Size(200, 50), // Minimum size for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                  ),
                  child: Text(
                    'Proceed',
                    style: TextStyle(color:themeProvider.themeMode == ThemeMode.dark
                    ? Styles.lightBackground // Dark mode background
                        : Styles.darkBackground,)// White text color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show the demo payment dialog
  void _showDemoPaymentDialog() {
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController cardPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Demo Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(labelText: 'Card Number (e.g., 4111 1111 1111 1111)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: cardPasswordController,
                decoration: InputDecoration(labelText: 'Card Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (cardNumberController.text.isNotEmpty && cardPasswordController.text.isNotEmpty) {
                  Navigator.of(context).pop(); // Close dialog
                  _handleDemoPayment(); // Simulate payment process
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter valid card details.'),
                  ));
                }
              },
              child: Text('Pay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to handle demo payment
  void _handleDemoPayment() {
    // Simulate a payment process
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Demo Payment Successful!'),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeliveryMethodPage(
            cartItems: widget.cartItems,
            selectedPaymentMethod: _selectedPaymentMethod!,
          ),
        ),
      );
    });
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
                color:themeProvider.themeMode == ThemeMode.dark
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
