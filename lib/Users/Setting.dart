// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jewellery_app/Login/LoginPage.dart';
import 'package:jewellery_app/main.dart'; // ThemeProvider & UserProvider import
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    });
  }

  // 🔥 Logout Logic
  Future<void> _signOut(UserProvider userProvider) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _updateUserStatus(user.uid, false);
        await _googleSignIn.signOut();
        await _auth.signOut();
        userProvider.clearUserData();

        Get.snackbar("Success", "Logged out successfully", 
          backgroundColor: Colors.green, colorText: Colors.white);
        
        Get.offAll(() => const LoginPage());
        
      } catch (e) {
        Get.snackbar("Error", "Error signing out: $e", 
          backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  Future<void> _updateUserStatus(String userId, bool isLoggedIn) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'isLoggedIn': isLoggedIn,
      });
    } catch (e) {
      print("Error updating user status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Theme Colors
    Color cardColor = Theme.of(context).cardColor;
    // Text Color logic handles both modes
    Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 1. PROFILE SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                
                // ✅ FIX: Dark Mode mein Border lagaya, Light Mode mein null
                border: themeProvider.isDarkMode 
                    ? Border.all(color: Colors.white.withOpacity(0.2), width: 1) 
                    : null,
                
                // ✅ FIX: Shadow sirf Light Mode mein dikhega
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.isDarkMode 
                        ? const Color.fromARGB(255, 73, 71, 71) // Dark mode mein shadow gayab
                        : Colors.black.withOpacity(0.1), // Light mode mein shadow
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (userProvider.image.isNotEmpty)
                        ? NetworkImage(userProvider.image)
                        : null,
                    child: (userProvider.image.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  
                  // Name
                  Text(
                    userProvider.name.isNotEmpty ? userProvider.name : "User Name",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // Email
                  Text(
                    userProvider.email.isNotEmpty ? userProvider.email : "user@email.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 2. SETTINGS LIST
            
            // Dark Mode Switch
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              // ✅ Dark mode border for Card
              margin: EdgeInsets.only(bottom: 15),
              color: cardColor,
              child: Container(
                decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(15),
                   border: themeProvider.isDarkMode 
                    ? Border.all(color: Colors.white.withOpacity(0.1)) 
                    : null,
                ),
                child: SwitchListTile(
                  title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600)),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: themeProvider.isDarkMode ? Colors.orange : Colors.blueGrey,
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: Colors.green,
                ),
              ),
            ),

            // Logout Button
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: cardColor,
              child: Container(
                decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(15),
                   border: themeProvider.isDarkMode 
                    ? Border.all(color: Colors.white.withOpacity(0.1)) 
                    : null,
                ),
                child: ListTile(
                  title: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  onTap: () {
                    // Confirm Dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Log Out"),
                        content: const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Dialog band karo
                              _signOut(userProvider); // Logout chalao
                            },
                            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}