import 'package:flutter/material.dart';

import 'ProductManagementPage.dart';
import 'beedo/AddProductPage.dart';
import 'Magements/Admins_Management/AdminsManagementPage.dart';
import 'Magements/Admins_Management/Product_Managment/AddProductPage.dart';
import 'Magements/UsersManagementPage.dart';
import 'beedo/ProductListPage.dart';
import 'ProductViewPage.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Primary color as background

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, Admin',
                    style: TextStyle(
                      color: Color(0xFF88683E), // Secondary color
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two columns of items
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  // Manage Users Card
                  _buildAdminPanelCard(
                    context,
                    icon: Icons.person,
                    title: 'Users Management',
                    onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) =>UsersManagementPage() ));
                    },
                  ),
                  _buildAdminPanelCard(
                    context,
                    icon: Icons.admin_panel_settings,
                    title: 'Admins Management',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>AdminsManagementPage() ));
                    },
                  ),
                  _buildAdminPanelCard(
                    context,
                    icon: Icons.add_circle,
                    title: 'Add Products ',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>AddProductPage() ));
                    },
                  ),

                  _buildAdminPanelCard(
                    context,
                    icon: Icons.view_agenda,
                    title: 'View Products',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>ProductViewPage() ));
                    },
                  ),
                  _buildAdminPanelCard(
                    context,
                    icon: Icons.location_on,
                    title: 'Locations Management',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>ProductBViewPage() ));
                    },
                  ),
                  _buildAdminPanelCard(
                    context,
                    icon: Icons.local_shipping,
                    title: 'Shipping Management',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>AddBProductPage() ));
                    },
                  ),
                  // Payments Management Card
                  _buildAdminPanelCard(
                    context,
                    icon: Icons.payment,
                    title: 'Payments Management',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>ProductManagementPage() ));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPanelCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color(0xFF88683E), // Secondary color
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.black, // Primary color for icon
              ),
              SizedBox(height: 16.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black, // Primary color for text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
