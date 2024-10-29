import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Main Content Here'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Center(
          child: Container(
            height: 60,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First Icon with Rounded Edge and Oval
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 250,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFFD4AC78),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(27.5),
                          bottomLeft: Radius.circular(27.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.person),
                            onPressed: () {},
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: Icon(Icons.favorite),
                            onPressed: () {},
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: Icon(Icons.shopping_cart),
                            onPressed: () {},
                            color: Colors.white,
                          ),

                        ],
                      ),
                    ),
                    Positioned(
                      right: -30,
                      top: 0,
                      child: ClipOval(
                        child: Container(
                          width: 50,
                          height: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Second Icon with Rounded Circle, moved left using Transform
                Transform.translate(
                  offset: Offset(-15, 0), // Adjust the X offset for closeness
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFD4AC78),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () {},
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        color: Colors.white, // Bottom AppBar background color
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: CustomBottomNavBar(),
));
