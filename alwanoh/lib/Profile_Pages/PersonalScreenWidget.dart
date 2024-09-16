
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Favorite/FavoritesPage.dart';
import '../Thems/styles.dart';
import 'EditProfilePage.dart';



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



    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor:Styles.customColor, // Updated to black
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        child: Stack(
          children: [

            Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 1,
              decoration: BoxDecoration(
                color: Colors.black, // Updated to black
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color:Styles.customColor,),// Updated to black
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              decoration: BoxDecoration(),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 50, 0, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_back_ios_new_outlined, color:Styles.customColor,),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Text(
                                      'Profile',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color:Styles.customColor,
                                      ),
                                    ),
                                    SizedBox(width: 55), // Placeholder for spacing
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(1, 1, 1, 1),
                              child: Container(

                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child:CircleAvatar(

                                  backgroundImage: _profileImageUrl.isNotEmpty
                                      ? NetworkImage(_profileImageUrl)
                                      : AssetImage('assets/default_profile.png') as ImageProvider,
                                  radius: 60,

                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: Text(
                                  _nameController.text.isNotEmpty ? _nameController.text : 'User Name',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    color:Styles.customColor,
                                    fontSize: 20,
                                    letterSpacing: 0,
                                )

                              ),
                            ),

                          ],
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 50,),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.person_outline_outlined,color:Styles.customColor,),
                          title: Text('Edit Profile',style: TextStyle(color:Styles.customColor,),),
                          trailing: Icon(Icons.arrow_forward_ios, color:Styles.customColor,),
                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditProfilePage()),
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.lock_outline,color:Styles.customColor,),
                          title: Text('Change Password ',style: TextStyle(color:Styles.customColor,),),
                          trailing: Icon(Icons.arrow_forward_ios, color:Styles.customColor,),
                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FavoritePage()),
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.privacy_tip_outlined,color:Styles.customColor,),
                          title: Text('Privacy Policy ',style: TextStyle(color:Styles.customColor,),),
                          trailing: Icon(Icons.arrow_forward_ios, color:Styles.customColor,),
                          onTap: () {
                            //
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                            // );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.info_outline_rounded,color:Styles.customColor,),
                          title: Text('About',style: TextStyle(color:Styles.customColor,),),
                          trailing: Icon(Icons.arrow_forward_ios, color:Styles.customColor,),
                          onTap: () {

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => AddProductPage()),
                            // );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.logout,color:Styles.customColor,),
                          title: Text('Logout',style: TextStyle(color:Styles.customColor,),),
                          trailing: Icon(Icons.arrow_forward_ios, color:Styles.customColor,),
                          onTap: () {

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => SignInScreen()),
                            // );
                          },
                        ),
                        Divider(),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0, -0.31),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    height: MediaQuery.sizeOf(context).height * 0.05,
                    decoration: BoxDecoration(
                      color:Styles.customColor, // Updated to black
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(1, 0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {

                            },
                            child: Icon(
                              Icons.sell_rounded,
                              color: Colors.black, // Updated to white
                              size: 25,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                          child: VerticalDivider(
                            thickness: 1,
                            color: Colors.black, // Updated to white
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(1, 0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {

                            },
                            child: FaIcon(
                              FontAwesomeIcons.solidBell,
                              color: Colors.black, // Updated to white
                              size: 25,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                          child: VerticalDivider(
                            thickness: 1,
                            color: Colors.black, // Updated to white
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(1, 0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                            },
                            child: Icon(
                              Icons.location_on,
                              color: Colors.black, // Updated to white
                              size: 25,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                          child: VerticalDivider(
                            thickness: 1,
                            color: Colors.black, // Updated to white
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(1, 0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: FaIcon(
                              FontAwesomeIcons.shoppingBag,
                              color: Colors.black, // Updated to white
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

