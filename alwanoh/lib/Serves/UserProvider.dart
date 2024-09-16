import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedDocument;
  String? _userId;

  String? get selectedDocument => _selectedDocument;
  String? get userId => _userId;

  UserProvider() {
    _initializeUser();
  }

  void _initializeUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      notifyListeners();
    }
  }

  void updateSelectedDocument(String? document) {
    _selectedDocument = document;
    notifyListeners(); // Notify listeners when the document changes
  }
}
