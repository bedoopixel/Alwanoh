import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Tap Payments API Keys
  final String secretKey = 'sk_test_8Bs3J9HAuN7UeIvwaXSmzQhV';
  final String publicKey = 'pk_test_hOJMNaCdTVEUgGRSK91Dq4x7';

  Future<void> startPayment() async {
    final url = Uri.parse('https://api.tap.company/v2/charges');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "amount": 10.0, // Replace with your amount
      "currency": "USD", // Replace with your currency
      "description": "Test Payment",
      "customer": {
        "name": "John",
        "email": "john.doe@example.com",
        "phone": {"country_code": "965", "number": "12345678"}
      },
      "source": {"id": "src_all"}, // For test purposes, allow all sources
      "redirect": {
        "url": "https://api.tap.company/v2/charges/" // Replace with your redirect URL
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
      print("Ensure the URL is correct and permissions are configured.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Page"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: startPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: Text(
            "Pay Now",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
