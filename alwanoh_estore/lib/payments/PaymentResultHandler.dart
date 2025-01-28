import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class PaymentResultHandler extends StatefulWidget {
  @override
  _PaymentResultHandlerState createState() => _PaymentResultHandlerState();
}

class _PaymentResultHandlerState extends State<PaymentResultHandler> {
  StreamSubscription<Uri?>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinkListener();
  }

  void _initializeDeepLinkListener() {
    _linkSubscription = uriLinkStream.listen((Uri? link) {
      if (link != null) {
        _handlePaymentResult(link);
      }
    }, onError: (err) {
      print("Error listening for deep links: $err");
    });
  }

  void _handlePaymentResult(Uri uri) {
    final status = uri.queryParameters['status'];
    final message = status == "success"
        ? "Payment successful!"
        : "Payment failed. Please try again.";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Status"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              // إغلاق الحوار أولاً
              Navigator.of(context).pop();
              // العودة إلى صفحة الهوم
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Result Handler")),
      body: Center(child: Text("Waiting for payment result...")),
    );
  }
}