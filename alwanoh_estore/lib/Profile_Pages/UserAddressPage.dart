import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../Thems/ThemeProvider.dart';
import '../Thems/styles.dart'; // Import your Styles class
import 'AddAddressPage.dart';


class UserAddressPage extends StatefulWidget {
  @override
  _UserAddressPageState createState() => _UserAddressPageState();
}

class _UserAddressPageState extends State<UserAddressPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor:themeProvider.themeMode == ThemeMode.dark
          ? Styles.darkBackground // Dark mode background
          : Styles.lightBackground,
      appBar: AppBar(
        title: Text('User Addresses'),
        backgroundColor: Styles.customColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchUserAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No addresses found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var address = snapshot.data!.docs[index];
              return Card(
                color: Styles.seconderyColor,

                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('${address['type']}',style: TextStyle(color: Styles.customColor),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${address['description']}',style: TextStyle(color: Styles.customColor),),
                      Text('Phone: ${address['phone_number']}',style: TextStyle(color: Styles.customColor),),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Styles.customColor),
                    onPressed: () {
                      _deleteAddress(address.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAddressPage()), // Navigate to AddAddressPage
          );
        },
        backgroundColor: Styles.customColor,
        child: Icon(Icons.add,color:themeProvider.themeMode == ThemeMode.dark
            ? Styles.darkBackground // Dark mode background
            : Styles.lightBackground,),
      ),
    );
  }

  Stream<QuerySnapshot> _fetchUserAddresses() async* {
    final User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user == null) {
      yield* Stream.empty(); // Return an empty stream if user is not logged in
      return; // Exit the function
    }

    String userId = user.uid; // Get the actual user ID from your auth provider
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('address') // Fetch cart items from the specific user's cart
        .snapshots();
  }

  Future<void> _deleteAddress(String addressId) async {
    final User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in. Unable to delete address.')),
      );
      return; // Exit the function
    }

    String userId = user.uid; // Get the actual user ID from your auth provider
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('address').doc(addressId).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Address deleted successfully!')));
  }

}
