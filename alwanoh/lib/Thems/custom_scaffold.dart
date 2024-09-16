import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Stack(
        children: [

          Container(
            child: child!,
          ),
        ],
      ),
    );
  }
}
