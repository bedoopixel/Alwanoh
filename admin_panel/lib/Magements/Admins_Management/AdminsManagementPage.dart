import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AddSubadminPage.dart';

class AdminsManagementPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateSubadmin(BuildContext context, String subadminId, String currentId, String currentPassword, String currentCountry, String currentCity, String currentPhone) async {
    final TextEditingController _idController = TextEditingController(text: currentId);
    final TextEditingController _passwordController = TextEditingController(text: currentPassword);
    final TextEditingController _countryController = TextEditingController(text: currentCountry);
    final TextEditingController _cityController = TextEditingController(text: currentCity);
    final TextEditingController _phoneController = TextEditingController(text: currentPhone);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Subadmin'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(labelText: 'ID'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: _countryController,
                  decoration: InputDecoration(labelText: 'Country'),
                ),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('subadmin').doc(subadminId).update({
                  'id': _idController.text,
                  'password': _passwordController.text,
                  'country': _countryController.text,
                  'city': _cityController.text,
                  'phone': _phoneController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSubadmin(BuildContext context, String subadminId) async {
    await _firestore.collection('subadmin').doc(subadminId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Admins Management'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('subadmin').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('An error occurred!'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No subadmins found.'));
                  }

                  final subadmins = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: subadmins.length,
                    itemBuilder: (context, index) {
                      var subadmin = subadmins[index].data() as Map<String, dynamic>;
                      var subadminId = subadmins[index].id;

                      // Debugging output
                      print('Subadmin Data: ${subadmin.toString()}');

                      return Card(
                        color: Color(0xFF88683E),
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: ${subadmin['id'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Password: ${subadmin['password'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Country: ${subadmin['country'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'City: ${subadmin['city'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Phone: ${subadmin['phone'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => _updateSubadmin(
                                      context,
                                      subadminId,
                                      subadmin['id'] ?? '',
                                      subadmin['password'] ?? '',
                                      subadmin['country'] ?? '',
                                      subadmin['city'] ?? '',
                                      subadmin['phone'] ?? '',
                                    ),
                                    child: Text(
                                      'Update',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _deleteSubadmin(context, subadminId),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>AddSubadminPage() ));
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF88683E),
      ),
    );
  }
}
