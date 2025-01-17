import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../ChatPage.dart';
import '../Login/loginScreen.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart';
import 'Change-Password.dart';
import 'EditProfilePage.dart';
import 'OrdersManagementPage.dart';
import 'UserAddressPage.dart';

class PersonalScreenWidget extends StatefulWidget {
  const PersonalScreenWidget({
    super.key,
    int? selectedPageIndex,
    bool? hidden,
  })  : this.selectedPageIndex = selectedPageIndex ?? 1,
        this.hidden = hidden ?? false;

  final int selectedPageIndex;
  final bool hidden;

  @override
  State<PersonalScreenWidget> createState() => _PersonalScreenWidgetState();
}

class _PersonalScreenWidgetState extends State<PersonalScreenWidget> {
  final _nameController = TextEditingController();
  String _profileImageUrl = '';
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _profileImageUrl = userData['imageUrl'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? Styles.darkBackground // Dark mode background
          : Styles.lightBackground,
      body: user == null ? _buildEmptyState() : _buildUserProfile(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
          Text(
            "Create an account",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Styles.customColor,
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            child: Container(
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Styles.customColor),
              ),
              child: Center(
                child: Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Styles.customColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return SingleChildScrollView( // Wrap the Column with SingleChildScrollView
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            _buildProfileOptions(),
            SizedBox(height: 20),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileHeader() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.36,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Styles.customColor),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 50, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_outlined, color: Styles.customColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Styles.customColor,
                  ),
                ),
                SizedBox(width: 55), // Placeholder for spacing
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(1, 1, 1, 1),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
                radius: 60,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
            child: Text(
              _nameController.text.isNotEmpty ? _nameController.text : 'User Name',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Styles.customColor,
                fontSize: 20,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView( // Add SingleChildScrollView here
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person_outline_outlined, color: Styles.customColor),
              title: Text('Edit Profile', style: TextStyle(color: Styles.customColor)),
              trailing: Icon(Icons.arrow_forward_ios, color: Styles.customColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            Divider(color: Styles.customColor),
            ListTile(
              leading: Icon(Icons.lock_outline, color: Styles.customColor),
              title: Text('Change Password ', style: TextStyle(color: Styles.customColor)),
              trailing: Icon(Icons.arrow_forward_ios, color: Styles.customColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },
            ),
            Divider(color: Styles.customColor),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: Styles.customColor),
              title: Text('Privacy Policy ', style: TextStyle(color: Styles.customColor)),
              trailing: Icon(Icons.arrow_forward_ios, color: Styles.customColor),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => HomesPages()));
              },
            ),
            Divider(color: Styles.customColor),
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: Styles.customColor),
              title: Text('About', style: TextStyle(color: Styles.customColor)),
              trailing: Icon(Icons.arrow_forward_ios, color: Styles.customColor),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePages()));
              },
            ),
            Divider(color: Styles.customColor),
            ListTile(
              leading: Icon(Icons.logout, color: Styles.customColor),
              title: Text('Logout', style: TextStyle(color: Styles.customColor)),
              trailing: Icon(Icons.arrow_forward_ios, color: Styles.customColor),
              onTap: () {
                // Handle logout
              },
            ),
            Divider(color: Styles.customColor),
            ListTile(
              leading: Icon(Icons.brightness_high, color: Styles.customColor),
              title: Text('Mode', style: TextStyle(color: Styles.customColor)),
              trailing: Transform.scale(
                scale: 0.8, // Adjust this value to change the size (1.0 = default size)
                child: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                  activeColor: Styles.darkBackground,
                  activeTrackColor: Styles.customColor,
                  inactiveThumbColor: Styles.lightBackground,
                  inactiveTrackColor: Styles.customColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomNavigation() {
    return Container(
      width: MediaQuery.of(context).size.width*0.7,
      decoration: BoxDecoration(
        color: Colors.transparent, // Set background color
        border: Border.all(color: Styles.customColor, width: 2), // Set border color and width
        borderRadius: BorderRadius.circular(30), // Optional: to round the corners
      ),
      padding: const EdgeInsets.only(bottom: 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Styles.customColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
          ),
          SizedBox(
            height: 25, // Adjust height as needed
            child: VerticalDivider(
              thickness: 1,
              color: Styles.customColor, // Set the divider color
            ),
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.bell, color: Styles.customColor),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => OrdersManagementPage()),
              // );
            },
          ),
          SizedBox(
            height: 25, // Adjust height as needed
            child: VerticalDivider(
              thickness: 1,
              color: Styles.customColor, // Set the divider color
            ),
          ),
          IconButton(
            icon: Icon(Icons.location_on_outlined, color: Styles.customColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserAddressPage()),
              );
            },
          ),
          SizedBox(
            height: 25, // Adjust height as needed
            child: VerticalDivider(
              thickness: 1,
              color: Styles.customColor, // Set the divider color
            ),
          ),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.shoppingBag, color: Styles.customColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersManagementPage()),
              );
            },
          ),
        ],
      )


    );
  }
}
