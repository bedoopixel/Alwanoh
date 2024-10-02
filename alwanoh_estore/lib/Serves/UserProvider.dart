import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedDocument;
  String? _userId;
  bool _isGuest = false;


  String? get selectedDocument => _selectedDocument;
  String? get userId => _userId;
  bool get isGuest => _isGuest;

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


  void setGuestStatus(bool isGuest) {
    _isGuest = isGuest;
    notifyListeners();
  }

  void clearUserData() {
    _selectedDocument = null;
    _isGuest = false; // Reset guest status
    notifyListeners();
  }


}
