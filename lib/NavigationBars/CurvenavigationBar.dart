// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_key_in_widget_constructors, library_private_types_in_public_api, file_names

// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:whatsapp_ui/pages/Calls.dart';
// import 'package:whatsapp_ui/pages/Communities.dart';
// import 'package:whatsapp_ui/pages/Updates.dart';
// import 'package:whatsapp_ui/pages/homePage.dart';
// class CurveNavBar extends StatefulWidget {
//   const CurveNavBar({super.key});

//   @override
//   State<CurveNavBar> createState() => _NavBarState();
// }

// class _NavBarState extends State<CurveNavBar> {

//   @override
//   Widget build(BuildContext context) {
//     return  MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: NavigationHome(),
//     );
//   }
// }

// class NavigationHome extends StatefulWidget {
//   @override
//   _NavigationHomeState createState() => _NavigationHomeState();
// }

// class _NavigationHomeState extends State<NavigationHome> {
//   int _currentIndex = 0;
//   final PageController _pageController = PageController();

//   final List<Widget> _pages = [
//     Homepage(),
//     Updates(),
//     Communities(),
//     Calls(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: CurvedNavigationBar(
        
//         index: _currentIndex,
//         height: 60.0,
//         items: <Widget>[
//           Badge.count(child: Icon(Icons.home, size: 30),count: 1000,),
//           Badge.count(child: Icon(Icons.update, size: 30),count: 1000,),
//           Badge.count(child: Icon(Icons.group, size: 30),count: 1000,),
//           Badge.count(child: Icon(Icons.call, size: 30),count: 1000,),
//         ],
//         color: Colors.green,
//         buttonBackgroundColor: Colors.green,
//         backgroundColor: Colors.green.shade300,
//         animationCurve: Curves.easeInOut,
//         animationDuration: Duration(milliseconds: 300),
//         onTap: (index) {
//           setState(() { 
//             _currentIndex = index;
//           });
//           _pageController.jumpToPage(index);
//         },
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         children: _pages,
//       ),
//     );
//   }
// }
  

// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:todo/pages/Calls.dart';
// import 'package:todo/pages/Communities.dart';
// import 'package:todo/pages/Updates.dart';
// import 'package:todo/pages/homePage.dart';

// class CurveNavBar extends StatefulWidget {
//   const CurveNavBar({super.key});

//   @override
//   State<CurveNavBar> createState() => _CurveNavBarState();
// }

// class _CurveNavBarState extends State<CurveNavBar> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: NavigationHome(),
//     );
//   }
// }

// class NavigationHome extends StatefulWidget {
//   @override
//   _NavigationHomeState createState() => _NavigationHomeState();
// }

// class _NavigationHomeState extends State<NavigationHome> {
//   int _currentIndex = 0;
//   final PageController _pageController = PageController();

//   final List<Widget> _pages = [
//     Padding(
//       padding: const EdgeInsets.only(bottom:50.0),
//       child: Homepage(),
//     ),
//     Updates(),
//     Communities(),
//     Calls(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//             children: _pages,
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: CurvedNavigationBar(
//               index: _currentIndex,
//               height: 60.0,
//               items: <Widget>[
//                 Badge.count(child: Icon(Icons.home, size: 30), count: 1000),
//                 Badge.count(child: Icon(Icons.update, size: 30), count: 1000),
//                 Badge.count(child: Icon(Icons.group, size: 30), count: 1000),
//                 Badge.count(child: Icon(Icons.call, size: 30), count: 1000),
//               ],
//               color: Colors.white.withOpacity(0.9), // Semi-transparent bar color
//               buttonBackgroundColor: Colors.green, // Semi-transparent button background
//               backgroundColor: Colors.transparent, // Transparent overall background
//               animationCurve: Curves.easeInOut,
//               onTap: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//                 _pageController.jumpToPage(index);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:whatsapp_ui/pages/Calls.dart';
// import 'package:whatsapp_ui/pages/Communities.dart';
// import 'package:whatsapp_ui/pages/Updates.dart';
// import 'package:whatsapp_ui/pages/homePage.dart';

// class CurveNavBar extends StatefulWidget {
//   final String? username; // Add username as a parameter

//   const CurveNavBar({super.key, this.username});

//   @override
//   State<CurveNavBar> createState() => _NavBarState();
// }

// class _NavBarState extends State<CurveNavBar> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: NavigationHome(username: widget.username), // Pass username here
//     );
//   }
// }

// class NavigationHome extends StatefulWidget {
//   final String? username; // Add username parameter

//   NavigationHome({required this.username});

//   @override
//   _NavigationHomeState createState() => _NavigationHomeState();
// }

// class _NavigationHomeState extends State<NavigationHome> {
//   int _currentIndex = 0;
//   final PageController _pageController = PageController();

//   final List<Widget> _pages = [
//     Homepage(),
//     Updates(),
//     Communities(),
//     Calls(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      
//       bottomNavigationBar: CurvedNavigationBar(
//         index: _currentIndex,
//         height: 60.0,
//         items: <Widget>[
//           Icon(Icons.home, size: 30),
//           Icon(Icons.update, size: 30),
//           Icon(Icons.group, size: 30),
//           Icon(Icons.call, size: 30),
//         ],
//         color: Colors.green,
//         buttonBackgroundColor: Colors.green,
//         backgroundColor: Colors.green.shade300,
//         animationCurve: Curves.easeInOut,
//         animationDuration: Duration(milliseconds: 300),
//         onTap: (index) {
//           setState(() { 
//             _currentIndex = index;
//           });
//           _pageController.jumpToPage(index);
//         },
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         children: _pages,
//       ),
//     );
//   }
// }
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jewellery_app/Users/CartPage.dart';
import 'package:jewellery_app/Users/Homepage.dart';
import 'package:jewellery_app/Users/Setting.dart';
import 'package:jewellery_app/Users/UserChatwithAdmin.dart';
import 'package:jewellery_app/Users/notifyUser.dart';

class CurveNavBar extends StatefulWidget {
  final String? username;

  const CurveNavBar({super.key, this.username});

  @override
  State<CurveNavBar> createState() => _NavBarState();
}

class _NavBarState extends State<CurveNavBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationHome(username: widget.username);
  }
}

class NavigationHome extends StatefulWidget {
  final String? username;

  const NavigationHome({super.key, required this.username});

  @override
  _NavigationHomeState createState() => _NavigationHomeState();
}

class _NavigationHomeState extends State<NavigationHome> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String uid = currentUser?.uid ?? widget.username ?? '';
    final String username = currentUser?.displayName ?? widget.username ?? '';

    _pages = [
       UserDashboard(),                          // Index 0
       const CartPage(),                         // Index 1
       OrderStatus(userId: uid),                 // Index 2
       UserConversationScreen(userId: uid, userName: username), // Index 3
       Setting()                                 // Index 4
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  // 🌈 NAV BAR COLOR
  Color navBarColor = isDarkMode
      ? const Color.fromARGB(255, 37, 36, 36)   // Premium dark graphite
      : const Color.fromARGB(255, 196, 197, 198);  // Clean light grey

  // 🔵 CENTER BUTTON COLOR (Curve Button)
  Color buttonColor = isDarkMode
      ? const Color(0xFF2979FF)   // Neon blue (dark mode pop)
      : const Color(0xFF1565C0);  // Deep royal blue

  // 🎯 ICON COLOR
  Color iconColor = isDarkMode
      ? Colors.white70
      : const Color(0xFF263238);

    return Scaffold(
      
      // ✅ 3. Swipe Enable karne ke liye PageView update kiya
      body: PageView(
        controller: _pageController,
        // physics: const NeverScrollableScrollPhysics(), // ❌ YE LINE HATA DI (Swipe On)
        
        // Jab user haath se swipe karega, to ye function chalega
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),

      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        
        // Icons list
        items: <Widget>[
          Icon(Icons.home, size: 30, ),          
          Icon(Icons.shopping_cart, size: 30, ), 
          Icon(Icons.list_alt, size: 30, ),      
          Icon(Icons.chat, size: 30, ),          
          Icon(Icons.settings, size: 30, ),      
        ],
        
        // ✅ Colors Apply kiye variables se
        color: navBarColor, 
        buttonBackgroundColor: buttonColor,
        
        // Background transparent taake swipe smooth lage
        backgroundColor: Colors.transparent, 
        
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        
        // Jab user icon pe click karega
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index); // Page change logic
        },
      ),
    );
  }
}