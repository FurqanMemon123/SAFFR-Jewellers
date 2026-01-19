import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  String _name = "No user";
  String _email = "No email signed in";
  String _image = "https://via.placeholder.com/150";
  bool _isDataLoaded = false; // Yeh flag batayega ke data cached hai ya nahi

  // Getters
  String get name => _name;
  String get email => _email;
  String get image => _image;

  // Data Fetch karne ka function
  Future<void> fetchUserData() async {
    // Agar data pehle se loaded hai, to wapas Firestore call mat karo (CACHE LOGIC)
    if (_isDataLoaded) return; 

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          _name = userDoc['name'] ?? "No user";
          _email = userDoc['Email'] ?? "No email signed in";
          _image = userDoc['image'] ?? "https://via.placeholder.com/150";
          _isDataLoaded = true; // Mark as loaded
          notifyListeners(); // UI ko update karo
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Logout ke waqt data clear karne ke liye
  void clearUserData() {
    _name = "No user";
    _email = "No email signed in";
    _image = "https://via.placeholder.com/150";
    _isDataLoaded = false;
    notifyListeners();
  }
}