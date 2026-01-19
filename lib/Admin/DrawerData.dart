import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jewellery_app/Admin/AcceptOrder.dart';
import 'package:jewellery_app/Admin/AddJewellery.dart';
import 'package:jewellery_app/Admin/AdminChatPage.dart';
import 'package:jewellery_app/Admin/AdminDashboard.dart';
import 'package:jewellery_app/Admin/DeclinedOrders.dart';
import 'package:jewellery_app/Admin/DeliveredOrders.dart';
import 'package:jewellery_app/Admin/UsersList.dart';
import 'package:jewellery_app/Admin/CurruntLoginUsers.dart';
import 'package:jewellery_app/Login/LoginPage.dart';
import 'package:jewellery_app/main.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORT THIS

class Drawerdata extends StatefulWidget {
  const Drawerdata({Key? key}) : super(key: key);

  @override
  State<Drawerdata> createState() => _DrawerdataState();
}

class _DrawerdataState extends State<Drawerdata> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String name = "No user";
  String email = "No email signed in";
  String image = "https://via.placeholder.com/150";

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadUserData(); // Changed function name
    }
  }

  // --- NEW LOGIC START ---
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check agar Cache (SharedPreferences) mein data hai
    String? cachedName = prefs.getString('admin_name');
    String? cachedEmail = prefs.getString('admin_email');
    String? cachedImage = prefs.getString('admin_image');

    if (cachedName != null && cachedEmail != null && cachedImage != null) {
      // Agar cache mein data hai, to wahin se set kardo (No Firebase Call)
      setState(() {
        name = cachedName;
        email = cachedEmail;
        image = cachedImage;
      });
      print("Data loaded from Cache"); 
    } else {
      // Agar cache khali hai, to Firebase se lao
      print("Cache empty, fetching from Firebase...");
      await _fetchAndSaveUserData(prefs);
    }
  }

  Future<void> _fetchAndSaveUserData(SharedPreferences prefs) async {
    try {
      final userDoc = await _firestore.collection("admin").doc(_user!.uid).get();
      if (userDoc.exists) {
        String fetchedName = userDoc.data()?['name'] ?? "No user";
        String fetchedEmail = userDoc.data()?['Email'] ?? "No email signed in";
        String fetchedImage = userDoc.data()?['image'] ?? "https://via.placeholder.com/150";

        // UI Update
        setState(() {
          name = fetchedName;
          email = fetchedEmail;
          image = fetchedImage;
        });

        // 2. Data ko Cache mein save karo taake agli baar fetch na karna pare
        await prefs.setString('admin_name', fetchedName);
        await prefs.setString('admin_email', fetchedEmail);
        await prefs.setString('admin_image', fetchedImage);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user data: ${e.toString()}");
    }
  }
  // --- NEW LOGIC END ---

  Future<void> _signOut() async {
    try {
      // 3. Logout karte waqt Cache clear karo
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Saara saved data urr jayega

      if (_user != null) {
        await _updateUserStatus(_user!.uid, false);
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
      Get.snackbar("SignOut", "User signed out successfully.");
      Get.offAll(LoginPage());
    } catch (e) {
      Get.snackbar("Error", "Error signing out: ${e.toString()}");
    }
  }

  Future<void> _updateUserStatus(String userId, bool isLoggedIn) async {
    try {
      await _firestore.collection('users').doc(userId).update({'isLoggedIn': isLoggedIn});
    } catch (e) {
      Get.snackbar("Error", "Failed to update user status: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Divider(color: Colors.grey),
            _buildDrawerItem("Home", Icons.home, () {
              Get.off(AdminDashboard());
            }),
            _buildDrawerItem("Accepted Orders", Icons.verified, () {
              Get.off(AcceptedOrders());
            }),
            _buildDrawerItem("Delivered Orders", Icons.delivery_dining_outlined, () {
              Get.off(DeliveredOrders());
            }),
            _buildDrawerItem("Orders Rejected", Icons.cancel, () {
              Get.off(DeclinedOrders());
            }),
            _buildDrawerItem("Chats", Icons.chat, () {
              Get.off(UserListScreen());
            }),
            _buildDrawerItem("Add Jewellery", Icons.category, () {
              Get.off(Adddishes());
            }),
            _buildDrawerItem("Users", Icons.people, () {
              Get.off(Userslist());
            }),
            _buildDrawerItem("Logged-In Users", Icons.people, () {
              if (_user != null) {
                Get.off(UserLoggedinScreen());
              } else {
                Get.snackbar("Error", "No user is currently logged in.");
              }
            }),
            
            _buildThemeSwitch(themeProvider),
            _buildDrawerItem("Log Out", Icons.logout, () {
              _signOut();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 30),
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(image),
          onBackgroundImageError: (_, __) {
            // Error handle karne ke liye agar image url broken ho
          },
        ),
        SizedBox(height: 10),
        Text(
          "Name: $name",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
        ),
        SizedBox(height: 5),
        Text(
          "Email: $email",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, Function onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Card(
        elevation: 10,
        child: ListTile(
          title: Text(title),
          leading: Icon(icon, color: Colors.red),
          onTap: () => onTap(),
        ),
      ),
    );
  }

  Widget _buildThemeSwitch(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 10,
        child: SwitchListTile(
          title: Text("Dark Mode"),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
        ),
      ),
    );
  }
}