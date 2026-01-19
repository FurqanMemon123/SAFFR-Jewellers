// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:jewellery_app/Login/splash_screen.dart';
// import 'package:jewellery_app/Users/Homepage.dart';
// import 'package:jewellery_app/firebase_options.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,

//   );
//   await FirebaseAppCheck.instance.activate(
//     androidProvider: AndroidProvider.playIntegrity,
//   );

//   runApp(
//     // ✅ Change: Single Provider ko MultiProvider me badal diya
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ThemeProvider()), // Theme ke liye
//         ChangeNotifierProvider(create: (_) => UserProvider()),  // User Data Caching ke liye
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context); 

//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(), 
//       darkTheme: ThemeData.dark(), 
//       themeMode: themeProvider.themeMode, 
//       home: const SplashScreen(),
//     );
//   }
// }

// // ================= THEME PROVIDER =================
// class ThemeProvider extends ChangeNotifier {
//   bool _isDarkMode = false;

//   ThemeProvider() {
//     _loadTheme();
//   }

//   bool get isDarkMode => _isDarkMode;

//   void toggleTheme() {
//     _isDarkMode = !_isDarkMode;
//     _saveTheme();
//     notifyListeners(); 
//   }

//   ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDarkMode = prefs.getBool('isDarkMode') ?? false;
//     notifyListeners();
//   }

//   Future<void> _saveTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setBool('isDarkMode', _isDarkMode);
//   }
// }

// // ================= USER PROVIDER (NEW ADDED) =================
// // Yeh class data ko cache karegi taake baar baar database call na ho
// class UserProvider extends ChangeNotifier {
//   String _name = "No user";
//   String _email = "No email signed in";
//   String _image = "https://via.placeholder.com/150";
//   bool _isDataLoaded = false; // Flag to check if data is already fetched

//   String get name => _name;
//   String get email => _email;
//   String get image => _image;

//   Future<void> fetchUserData() async {
//     // Agar data pehle se loaded hai, to dobara fetch mat karo (Save Cost & Bandwidth)
//     if (_isDataLoaded) return; 

//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final userDoc = await FirebaseFirestore.instance
//             .collection("Users")
//             .doc(user.uid)
//             .get();

//         if (userDoc.exists) {
//           _name = userDoc['name'] ?? "No user";
//           _email = userDoc['Email'] ?? "No email signed in";
//           _image = userDoc['image'] ?? "https://via.placeholder.com/150";
//           _isDataLoaded = true; // Mark done
//           notifyListeners(); // UI Update
//         }
//       } catch (e) {
//         print("Error fetching user data: $e");
//       }
//     }
//   }

//   // Logout ke waqt sab clear karne ke liye
//   void clearUserData() {
//     _name = "No user";
//     _email = "No email signed in";
//     _image = "https://via.placeholder.com/150";
//     _isDataLoaded = false;
//     notifyListeners();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // ✅ NEW: Web check karne ke liye zaroori hai
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:jewellery_app/Login/splash_screen.dart';
import 'package:jewellery_app/Users/Homepage.dart';
import 'package:jewellery_app/firebase_options.dart'; // ✅ Make sure yeh file majood ho
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase Initialize (Web Compatible)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. App Check Logic (Crash Fix) 🛠️
  // Yeh code sirf Android/iOS par chalega, Web par skip ho jayega
  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  } 
  // Agar Web hai to hum abhi AppCheck activate nahi kar rahe taake crash na ho.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Theme ke liye
        ChangeNotifierProvider(create: (_) => UserProvider()),  // User Data Caching ke liye
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); 

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), 
      darkTheme: ThemeData.dark(), 
      themeMode: themeProvider.themeMode, 
      home: const SplashScreen(),
    );
  }
}

// ================= THEME PROVIDER =================
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners(); 
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }
}

// ================= USER PROVIDER =================
class UserProvider extends ChangeNotifier {
  String _name = "No user";
  String _email = "No email signed in";
  String _image = "https://via.placeholder.com/150";
  bool _isDataLoaded = false; 

  String get name => _name;
  String get email => _email;
  String get image => _image;

  Future<void> fetchUserData() async {
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
          _isDataLoaded = true; 
          notifyListeners(); 
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  void clearUserData() {
    _name = "No user";
    _email = "No email signed in";
    _image = "https://via.placeholder.com/150";
    _isDataLoaded = false;
    notifyListeners();
  }
}