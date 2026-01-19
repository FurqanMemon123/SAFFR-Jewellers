// ignore_for_file: prefer_const_constructors, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:jewellery_app/Admin/AdminDashboard.dart';
import 'package:jewellery_app/Login/LoginPage.dart';
import 'package:jewellery_app/NavigationBars/CurvenavigationBar.dart';
import 'package:jewellery_app/Users/Homepage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for auth state
            return Center();
          }

          if (snapshot.hasData) {
            User? user = snapshot.data;
            return FutureBuilder<void>(
              future: checkUser(user!),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return Center();
                } else {
                  return Container(); // Placeholder while user type is being checked
                }
              },
            );
          } else {
            // User is not logged in

            return LoginPage();
          }
        },
      ),
    );
  }

  Future<void> setprefs(Map<String, dynamic> data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("Login", true);
      await prefs.setString("userType", data["Type"]);
    } catch (e) {
      print("Error setting preferences: $e");
    }
  }

  Future<void> checkUser(User user) async {
    try {
      // Check if user exists in "admin" collection
      var adminDoc = await FirebaseFirestore.instance
          .collection("admin")
          .doc(user.uid)
          .get();
      if (adminDoc.exists) {
        // User is an admin
        var adminData = adminDoc.data() as Map<String, dynamic>;
        await setprefs(adminData); // Save preferences
        // Get.snackbar("SignIn", "Admin Signed In Successfully",
        //     colorText: Colors.white);
        Get.offAll(AdminDashboard());
      } else {
        // Check if user exists in "Users" collection
        var userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
         
            // Get.offAll(UserDashboard());
            Get.offAll(CurveNavBar());
         
          }
          // // User is a regular user
          // var userData = userDoc.data() as Map<String, dynamic>;
          // await setprefs(userData); // Save preferences
          // // Get.snackbar("SignIn", "User Signed In Successfully",
          // //     colorText: Colors.white);
          // Get.offAll(UserDashboard());
         else {
          // User does not exist in either collection
          Get.snackbar(
            "Error",
            "User does not exist in any collection.",
            colorText: Colors.white,
          );
          await FirebaseAuth.instance.signOut(); // Log out the user
        }
      }
    } catch (e) {
      print("Error checking user: $e");
      Get.snackbar("Error", e.toString(), colorText: Colors.white);
    }
  }
}
