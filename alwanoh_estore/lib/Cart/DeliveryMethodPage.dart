import 'package:flutter/material.dart';
import '../ChatPage.dart';
import '../Profile_Pages/SelectAddressPage.dart';
import 'OrderStatePage.dart';
import '../Thems/styles.dart';
import 'PaymentMethodPage.dart';

class DeliveryMethodPage extends StatefulWidget {
  final List<dynamic> cartItems; // Accepting cart items
  final String selectedPaymentMethod; // Accepting selected payment method

  DeliveryMethodPage({Key? key, required this.cartItems, required this.selectedPaymentMethod}) : super(key: key);
  @override
  _DeliveryMethodPageState createState() => _DeliveryMethodPageState();
}

class _DeliveryMethodPageState extends State<DeliveryMethodPage> {
  String? _selectedDeliveryMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Delivery Method'),
        backgroundColor: Styles.customColor, // Using customColor from Styles
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a delivery method:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Styles.customColor, // Custom text color
              ),
            ),
            SizedBox(height: 20),
            _buildDeliveryMethodContainer('FedEx'),
            SizedBox(height: 10),
            _buildDeliveryMethodContainer('Master'),
            SizedBox(height: 10),
            _buildDeliveryMethodContainer('Western'),
            SizedBox(height: 30),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Styles.customColor, width: 2), // Set border color and width
                  borderRadius: BorderRadius.circular(30), // Ensure rounded corners
                ),
                child: ElevatedButton(
                  onPressed: _selectedDeliveryMethod == null
                      ? null
                      : () {
                    // Navigate to OrderStatePage when a delivery method is selected
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectAddressPage(
                          cartItems: widget.cartItems, // Pass cartItems
                          selectedPaymentMethod: widget.selectedPaymentMethod, // Pass selectedPaymentMethod
                          selectedDeliveryMethod: _selectedDeliveryMethod!,),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Using primaryColor
                    minimumSize: Size(200, 50), // Set minimum size for the button (width, height)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Ensure rounded corners
                    ),
                  ),
                  child: Text(
                    'Proceed',
                    style: TextStyle(color: Colors.white), // Ensuring text is white
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  // Method to create a delivery method inside a container
  Widget _buildDeliveryMethodContainer(String method) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _selectedDeliveryMethod == method
              ? Styles.seconderyColor.withOpacity(0.2) // Change color when selected
              : Styles.customColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _selectedDeliveryMethod == method
                  ? Styles.customColor // Highlight border when selected
                  : Styles.customColor,
              width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              method,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _selectedDeliveryMethod == method
                    ? Styles.primaryColor
                    : Colors.black,
              ),
            ),
            if (_selectedDeliveryMethod == method)
              Icon(
                Icons.check_circle,
                color: Styles.primaryColor,
              ), // Show check icon for the selected method
          ],
        ),
      ),
    );
  }
}
