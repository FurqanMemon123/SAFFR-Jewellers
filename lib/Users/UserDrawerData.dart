// ignore_for_file: file_names, prefer_const_constructors, avoid_print, use_super_parameters, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jewellery_app/Login/LoginPage.dart';
import 'package:jewellery_app/Users/CartPage.dart';
import 'package:jewellery_app/Users/Homepage.dart';
import 'package:jewellery_app/Users/UserChatwithAdmin.dart';
import 'package:jewellery_app/Users/notifyUser.dart';
// Apne UserProvider ko import karna mat bhoolna
// import 'package:jewellery_app/Providers/user_provider.dart'; 
import 'package:jewellery_app/main.dart'; 
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider package import zaroori hai
import 'package:jewellery_app/main.dart'; // ✅ Yahan se UserProvider class milegi
// Baaki imports...

class UDrawerdata extends StatefulWidget {
  const UDrawerdata({Key? key}) : super(key: key);

  @override
  State<UDrawerdata> createState() => _UDrawerdataState();
}

class _UDrawerdataState extends State<UDrawerdata> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // ✅ Screen load hote hi Provider ko bolo data fetch kare (agar pehle se nahi hai)
    // "listen: false" zaroori hai initState mein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    });
  }

  Future<void> _signOut(UserProvider userProvider) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _updateUserStatus(user.uid, false);
        await _googleSignIn.signOut();
        await _auth.signOut();
        
        // ✅ CACHE CLEAR KARO LOGOUT PAR
        userProvider.clearUserData(); 

        Get.snackbar("SignOut", "User signed out successfully.");
        Get.offAll(LoginPage());
      } catch (e) {
        Get.snackbar("Error", "Error signing out: ${e.toString()}");
      }
    } else {
      Get.snackbar("Info", "No user is currently signed in.",
          colorText: Colors.white);
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
    // ✅ UI mein Provider ka data use karo
    final userProvider = Provider.of<UserProvider>(context); 
    final currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            CircleAvatar(
              
              radius: 50,
              // ✅ Provider se image lo
              backgroundImage: NetworkImage(userProvider.image), 
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 10),
            Text(
              "Name: ${userProvider.name}", // ✅ Provider se name
            ),
            Text(
              "Email: ${userProvider.email}", // ✅ Provider se email
            ),
            Divider(color: Colors.grey),
            buildDrawerItem("Home", Icons.home, () {
              Get.off(UserDashboard());
            }),
        
            buildDrawerItem("Cart", Icons.shopping_cart, () {
              Get.off(CartPage());
            }),
            buildDrawerItem("Order Status", Icons.notification_important_outlined,
                () {
              if (currentUser != null) {
                Get.off(OrderStatus(userId: currentUser.uid));
              } else {
                Get.snackbar("Error", "User not logged in.");
              }
            }),
            buildDrawerItem("Chat With Admin", Icons.chat, () {
              if (currentUser != null) {
                Get.to(UserConversationScreen(
                    userName: userProvider.name, userId: currentUser.uid));
              } else {
                Get.snackbar("Error", "User not logged in.");
              }
            }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Card(
                elevation: 10,
                child: ListTile(
                  title: Text("Dark Mode"),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                ),
              ),
            ),
            // ✅ Signout function mein provider pass karo taake clear kar sake
            buildDrawerItem("Log Out", Icons.logout, () => _signOut(userProvider)),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(String title, IconData icon, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Card(
        elevation: 10,
        child: ListTile(
          title: Text(title),
          leading: Icon(icon, color: Colors.red),
          onTap: onTap,
        ),
      ),
    );
  }
}