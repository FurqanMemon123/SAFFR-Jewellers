// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:jewellery_app/Users/AddtoCart.dart';
// import 'package:jewellery_app/Users/CartPage.dart';
// import 'package:jewellery_app/Users/JeweleryDetailPage.dart';
// import 'package:jewellery_app/Users/UserDrawerData.dart';
// import 'package:get/get.dart';

// class CartManager extends GetxController {
//   var cartItems = <Map<String, dynamic>>[].obs;

//   void addToCart(Map<String, dynamic> dish) {
//     cartItems.add(dish);
//     Get.snackbar(
//       "Added to Cart",
//       "${dish['name']} has been added to your cart.",
//     );
//   }

//   void removeFromCart(int index) {
//     cartItems.removeAt(index);
//   }

//   void clearCart() {
//     cartItems.clear();
//   }
// }

// class UserDashboard extends StatefulWidget {
//   const UserDashboard({super.key});

//   @override
//   State<UserDashboard> createState() => _UserDashboardState();
// }

// class _UserDashboardState extends State<UserDashboard> {

//   final CollectionReference dishesCollection =
//       FirebaseFirestore.instance.collection('Category');
//   final CartManager cartManager = Get.put(CartManager());
//   List<Map<String, dynamic>> dishes = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchDishes();
//   }

//   fetchDishes() async {
//     try {
//       QuerySnapshot snapshot = await dishesCollection.get();
//       setState(() {
//         dishes = snapshot.docs
//             .map((doc) => doc.data() as Map<String, dynamic>)
//             .toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       // Get.snackbar(
//       //   "Error",
//       //   "Failed to load dishes: $e",
//       //   backgroundColor: Colors.transparent,
//       //   colorText: Colors.transparent,
//       // );
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.black,
//        appBar: AppBar(
//         // backgroundColor: Colors.black,
//         title: Text('Dishes',
//         // style: TextStyle(color: Colors.transparent)
//         ),
//         // iconTheme: IconThemeData(color: Colors.transparent),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.shopping_cart,
//             //  color: Colors.transparent
//              ),
//             onPressed: () {
//               Get.to(CartPage());
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.refresh,
//             //  color: Colors.transparent
//              ),
//             onPressed: fetchDishes,
//           ),
//         ],
//       ),
//       drawer: Drawer(child: UDrawerdata()),
//       body:
//        isLoading
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10.0,
//                 mainAxisSpacing: 10.0,
//                 childAspectRatio: 0.9,
//               ),
//               itemCount: dishes.length,
//               itemBuilder: (context, index) {
//                 final dishData = dishes[index];
//                 return Card(
//                   elevation: 20,
//                   // color: Colors.transparent10,
//                   child: InkWell(
//                     onTap: () {
//                       Get.to(DishDetailPage(dishData: dishData));
//                     },
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: CircleAvatar(
//                             radius: 60,
//                             backgroundImage: dishData['image'] != null &&
//                                     dishData['image'].isNotEmpty
//                                 ? NetworkImage(dishData['image'])
//                                 : AssetImage('assets/placeholder.png'),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 5),
//                           child: Text(
//                             "${dishData['name'] ?? 'No Name'}",
//                             style: TextStyle( fontSize: 15),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 5, top: 3),
//                           child: Text(
//                             "Price: ${dishData['price']}",
//                             style: TextStyle(fontSize: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// // // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:jewellery_app/Users/AddtoCart.dart';
// // import 'package:jewellery_app/Users/CartPage.dart';
// // import 'package:jewellery_app/Users/DishDetailPage.dart';
// // import 'package:jewellery_app/Users/UserDrawerData.dart';
// // import 'package:jewellery_app/Users/UserDish.dart';
// // import 'package:get/get.dart';

// // class UserDashboard extends StatefulWidget {
// //   const UserDashboard({super.key});

// //   @override
// //   State<UserDashboard> createState() => _UserDashboardState();
// // }

// // class _UserDashboardState extends State<UserDashboard> {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final CollectionReference dishesCollection =
// //       FirebaseFirestore.instance.collection('Category');
// //   final CollectionReference usersCollection =
// //       FirebaseFirestore.instance.collection('Users');
// //   final CartManager cartManager = Get.put(CartManager());
// //   List<Map<String, dynamic>> dishes = [];
// //   bool isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     updateLoginStatus();
// //     fetchDishes();
// //   }

// //   // Fetch and update user's login status in Firestore
// //   Future<void> updateLoginStatus() async {
// //     try {
// //       User? currentUser = _auth.currentUser;
// //       if (currentUser != null) {
// //         await usersCollection.doc(currentUser.uid).update({
// //           'isLoggedIn': true,
// //         });
// //       }
// //     } catch (e) {
// //       print("Failed to update login status: $e");
// //       Get.snackbar("Error", "Failed to update login status: $e",
// //           colorText: Colors.red);
// //     }
// //   }

// //   fetchDishes() async {
// //     try {
// //       QuerySnapshot snapshot = await dishesCollection.get();
// //       setState(() {
// //         dishes = snapshot.docs
// //             .map((doc) => doc.data() as Map<String, dynamic>)
// //             .toList();
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;
// //       });
// //       print("Failed to load dishes: $e");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Dishes'),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.shopping_cart),
// //             onPressed: () {
// //               Get.to(CartPage());
// //             },
// //           ),
// //           IconButton(
// //             icon: Icon(Icons.refresh),
// //             onPressed: fetchDishes,
// //           ),
// //         ],
// //       ),
// //       drawer: Drawer(child: UDrawerdata()),
// //       body: isLoading
// //           ? Center(child: CircularProgressIndicator())
// //           : GridView.builder(
// //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: 2,
// //                 crossAxisSpacing: 10.0,
// //                 mainAxisSpacing: 10.0,
// //                 childAspectRatio: 0.9,
// //               ),
// //               itemCount: dishes.length,
// //               itemBuilder: (context, index) {
// //                 final dishData = dishes[index];
// //                 return Card(
// //                   elevation: 20,
// //                   child: InkWell(
// //                     onTap: () {
// //                       Get.to(DishDetailPage(dishData: dishData));
// //                     },
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: [
// //                         Expanded(
// //                           child: CircleAvatar(
// //                             radius: 60,
// //                             backgroundImage: dishData['image'] != null &&
// //                                     dishData['image'].isNotEmpty
// //                                 ? NetworkImage(dishData['image'])
// //                                 : AssetImage('assets/placeholder.png')
// //                                     as ImageProvider,
// //                           ),
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(horizontal: 5),
// //                           child: Text(
// //                             "${dishData['name'] ?? 'No Name'}",
// //                             style: TextStyle(fontSize: 15),
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.only(bottom: 5, top: 3),
// //                           child: Text(
// //                             "Price: ${dishData['price']}",
// //                             style: TextStyle(fontSize: 14),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //     );
// //   }

// // // }
// perfect code
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jewellery_app/Users/CartPage.dart';
// import 'package:jewellery_app/Users/JeweleryDetailPage.dart';
// import 'package:jewellery_app/Users/UserDrawerData.dart';

// class HomePage extends StatefulWidget {
//   final String gender;
//   const HomePage({super.key, required this.gender});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Default selected category
//   String? selectedCategory = 'Ring';

//   // 🔹 FILTER & SORT VARIABLES
//   String sortBy = 'default'; // 'low_high', 'high_low'
//   String? selectedColorFilter; // 'Gold', 'Silver', etc.
//   double maxPriceFilter = 500000; // Default max price range (Change as per need)
//   RangeValues _currentPriceRange = const RangeValues(0, 500000); // Slider values

//   // 🔹 CATEGORY WIDGETS
//   Widget categorySelector() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         categoryButton('Ring', 'assets/images/diamond-ring-icon-png.png'),
//         categoryButton('Earrings', 'assets/images/err.png'),
//         categoryButton('Necklace', 'assets/images/naclace.png'),
//         categoryButton('Bangle', 'assets/images/bangles.png'),
//       ],
//     );
//   }

//   Widget categoryButton(String category, String imageUrl) {
//     bool isSelected = selectedCategory == category;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedCategory = category;
//         });
//       },
//       child: Material(
//         elevation: 5,
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.black : Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Image.asset(
//             imageUrl,
//             height: 50,
//             width: 50,
//             fit: BoxFit.cover,
//             color: isSelected ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }

//   // 🔹 BACKEND QUERY (Raw Data)
//   Stream<QuerySnapshot> getJewelleryItems() {
//     CollectionReference ref = FirebaseFirestore.instance
//         .collection('Category')
//         .doc(widget.gender)
//         .collection(selectedCategory ?? 'Ring');

//     return ref.snapshots();
//   }

//   // 🔹 FILTER DIALOG (Bottom Sheet)
//   void showFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Filter & Sort", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 20),

//                   // 1. SORT BY PRICE
//                   const Text("Sort By Price", style: TextStyle(fontWeight: FontWeight.w600)),
//                   Wrap(
//                     spacing: 10,
//                     children: [
//                       ChoiceChip(
//                         label: const Text("Low to High"),
//                         selected: sortBy == 'low_high',
//                         onSelected: (bool selected) {
//                           setModalState(() => sortBy = 'low_high');
//                         },
//                       ),
//                       ChoiceChip(
//                         label: const Text("High to Low"),
//                         selected: sortBy == 'high_low',
//                         onSelected: (bool selected) {
//                           setModalState(() => sortBy = 'high_low');
//                         },
//                       ),
//                       ChoiceChip(
//                         label: const Text("Default"),
//                         selected: sortBy == 'default',
//                         onSelected: (bool selected) {
//                           setModalState(() => sortBy = 'default');
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // 2. FILTER BY COLOR
//                   const Text("Filter By Color", style: TextStyle(fontWeight: FontWeight.w600)),
//                   Wrap(
//                     spacing: 10,
//                     children: ['Gold', 'Silver', 'Other'].map((color) {
//                       return ChoiceChip(
//                         label: Text(color),
//                         selected: selectedColorFilter == color,
//                         onSelected: (bool selected) {
//                           setModalState(() {
//                             selectedColorFilter = selected ? color : null;
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 20),

//                   // 3. FILTER BY PRICE RANGE
//                   Text("Price Range: PKR ${_currentPriceRange.start.toInt()} - ${_currentPriceRange.end.toInt()}", 
//                     style: const TextStyle(fontWeight: FontWeight.w600)),
//                   RangeSlider(
//                     values: _currentPriceRange,
//                     min: 0,
//                     max: 500000, // Max limit adjust kar lena
//                     divisions: 100,
//                     labels: RangeLabels(
//                       _currentPriceRange.start.round().toString(),
//                       _currentPriceRange.end.round().toString(),
//                     ),
//                     onChanged: (RangeValues values) {
//                       setModalState(() {
//                         _currentPriceRange = values;
//                       });
//                     },
//                   ),

//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
//                       onPressed: () {
//                         // Apply changes to main state
//                         setState(() {}); 
//                         Navigator.pop(context);
//                       },
//                       child: const Text("Apply Filters"),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           // 🔹 FILTER BUTTON ADDED HERE
//           IconButton(
//             onPressed: showFilterBottomSheet,
//             icon: const Icon(Icons.filter_list),
//           ),
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 // Reset Filters
//                 sortBy = 'default';
//                 selectedColorFilter = null;
//                 _currentPriceRange = const RangeValues(0, 500000);
//               });
//             },
//             icon: const Icon(Icons.refresh),
//           ),
//           IconButton(
//             onPressed: () {
//               Get.to(() => const CartPage());
//             },
//             icon: const Icon(Icons.shopping_cart_outlined),
//           ),
//         ],
//       ),
//       // drawer: const UDrawerdata(),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Beautiful Jewellery', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
//               const Text('for you', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
              
//               categorySelector(),
              
//               const SizedBox(height: 10),
              
//               // Helper text showing current filters
//               if(selectedColorFilter != null || sortBy != 'default')
//                 Text(
//                   "Filtered: ${selectedColorFilter ?? 'All Colors'} | Sort: $sortBy",
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),

//               const SizedBox(height: 10),

//               // 🔹 STREAM BUILDER WITH FILTER LOGIC
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: getJewelleryItems(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Center(child: Text('No items found.'));
//                     }

//                     // 1. Get All Data
//                     var docs = snapshot.data!.docs;

//                     // 2. APPLY FILTERING (Client Side)
//                     var filteredList = docs.where((doc) {
//                       var data = doc.data() as Map<String, dynamic>;
                      
//                       // Price Parse (String to Double safe convert)
//                       double price = double.tryParse(data['price'].toString()) ?? 0.0;
                      
//                       // Color Check (Case insensitive)
//                       String color = (data['color'] ?? '').toString().toLowerCase();
//                       String? filterColor = selectedColorFilter?.toLowerCase();

//                       // Condition 1: Price Range
//                       bool pricePass = price >= _currentPriceRange.start && price <= _currentPriceRange.end;

//                       // Condition 2: Color
//                       bool colorPass = filterColor == null || color.contains(filterColor);

//                       return pricePass && colorPass;
//                     }).toList();

//                     // 3. APPLY SORTING
//                     if (sortBy == 'low_high') {
//                       filteredList.sort((a, b) {
//                         double p1 = double.tryParse((a.data() as Map)['price'].toString()) ?? 0;
//                         double p2 = double.tryParse((b.data() as Map)['price'].toString()) ?? 0;
//                         return p1.compareTo(p2);
//                       });
//                     } else if (sortBy == 'high_low') {
//                       filteredList.sort((a, b) {
//                         double p1 = double.tryParse((a.data() as Map)['price'].toString()) ?? 0;
//                         double p2 = double.tryParse((b.data() as Map)['price'].toString()) ?? 0;
//                         return p2.compareTo(p1); // Reverse
//                       });
//                     }

//                     // CHECK IF LIST EMPTY AFTER FILTER
//                     if (filteredList.isEmpty) {
//                        return const Center(child: Text('No items match your filters.'));
//                     }

//                     return GridView.builder(
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 0.65,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                       ),
//                       itemCount: filteredList.length,
//                       itemBuilder: (context, index) {
//                         var item = filteredList[index];
//                         var data = item.data() as Map<String, dynamic>;

//                         return GestureDetector(
//                           onTap: () {
//                             Get.to(() => JewelleryDetailPage(jewelleryData: data));
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).cardColor,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
//                               boxShadow: [
//                                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(
//                                   height: 140,
//                                   width: double.infinity,
//                                   child: ClipRRect(
//                                     borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                                     child: Hero(
//                                       tag: data['image'] ?? 'img$index',
//                                       child: Image.network(
//                                         data['image'] ?? '',
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error, stackTrace) =>
//                                             const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               data['name'] ?? 'No Name',
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                                 fontWeight: FontWeight.bold, fontSize: 15),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               data['description'] ?? 'No description',
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                                 color: Colors.grey, height: 1.2),
//                                             ),
//                                           ],
//                                         ),
//                                         Text(
//                                           "PKR ${data['price'] ?? '0'}",
//                                           style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w700),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// // ignore_for_file: prefer_const_constructors

// class UserDashboard extends StatefulWidget {
//   const UserDashboard({super.key});

//   @override
//   State<UserDashboard> createState() => _UserDashboardState();
// }

// class _UserDashboardState extends State<UserDashboard> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // drawer: Drawer(child: UDrawerdata()),
//       appBar: AppBar(
//         title: Text("Welcome"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent, // Keep transparent for Dark Mode
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Select Category",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 30),

//               // Row containing the two buttons
//               Row(
//                 children: [
//                   // 1. MAN BUTTON
//                   Expanded(
//                     child: _buildGenderButton(
//                       context,
//                       title: "Man",
//                       icon: Icons.male_rounded,
//                       color: Colors.blueAccent,
//                       onTap: () {
//                         // Navigate to Dashboard (You can pass "Man" data if needed later)
//                         Get.to(() => HomePage(gender: 'Man'));
//                       },
//                     ),
//                   ),

//                   SizedBox(width: 20), // Spacing between buttons
//                   // 2. WOMAN BUTTON
//                   Expanded(
//                     child: _buildGenderButton(
//                       context,
//                       title: "Woman",
//                       icon: Icons.female_rounded,
//                       color: Colors.pinkAccent,
//                       onTap: () {
//                         // Navigate to Dashboard (You can pass "Woman" data if needed later)
//                         Get.to(() => HomePage(gender: 'Woman'));
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper Widget for Custom Buttons
//   Widget _buildGenderButton(
//     BuildContext context, {
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 180, // Large Height
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor, // Adapts to Dark Mode
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: color.withOpacity(0.5),
//             width: 2,
//           ), // Colored Border
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(
//                 0.2,
//               ), // Glow effect based on gender color
//               blurRadius: 15,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Icon Circle
//             Container(
//               padding: EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 50, color: color),
//             ),
//             SizedBox(height: 15),

//             // Title Text
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 // color: Theme.of(context).textTheme.bodyLarge?.color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewellery_app/Users/ChainAR.dart';
import 'package:jewellery_app/Users/CartPage.dart';
import 'package:jewellery_app/Users/EaringsAR.dart';
import 'package:jewellery_app/Users/JeweleryDetailPage.dart';
import 'package:jewellery_app/Users/UserDrawerData.dart';

class HomePage extends StatefulWidget {
  final String gender;
  const HomePage({super.key, required this.gender});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Default selected category
  String? selectedCategory = 'Ring';

  // 🔹 FILTER & SORT VARIABLES
  String sortBy = 'default'; // 'low_high', 'high_low'
  String? selectedColorFilter; // 'Gold', 'Silver', etc.
  
  // 🔥 UPDATE 1: Max Price 20,000 kar di hai
  double maxPriceFilter = 20000; 
  RangeValues _currentPriceRange = const RangeValues(0, 20000);

  // 🔹 SEARCH VARIABLES
  String searchQuery = ""; // Search text store karne ke liye
  TextEditingController searchController = TextEditingController();

  // 🔹 CATEGORY WIDGETS
  Widget categorySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        categoryButton('Ring', 'assets/images/diamond-ring-icon-png.png'),
        categoryButton('Earrings', 'assets/images/err.png'),
        categoryButton('Necklace', 'assets/images/naclace.png'),
        categoryButton('Bangle', 'assets/images/bangles.png'),
      ],
    );
  }

  Widget categoryButton(String category, String imageUrl) {
    bool isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            imageUrl,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // 🔹 BACKEND QUERY (Raw Data)
  Stream<QuerySnapshot> getJewelleryItems() {
    CollectionReference ref = FirebaseFirestore.instance
        .collection('Category')
        .doc(widget.gender)
        .collection(selectedCategory ?? 'Ring');

    return ref.snapshots();
  }

  // 🔹 FILTER DIALOG (Bottom Sheet)
  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter & Sort", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // 1. SORT BY PRICE
                  const Text("Sort By Price", style: TextStyle(fontWeight: FontWeight.w600)),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text("Low to High"),
                        selected: sortBy == 'low_high',
                        onSelected: (bool selected) {
                          setModalState(() => sortBy = 'low_high');
                        },
                      ),
                      ChoiceChip(
                        label: const Text("High to Low"),
                        selected: sortBy == 'high_low',
                        onSelected: (bool selected) {
                          setModalState(() => sortBy = 'high_low');
                        },
                      ),
                      ChoiceChip(
                        label: const Text("Default"),
                        selected: sortBy == 'default',
                        onSelected: (bool selected) {
                          setModalState(() => sortBy = 'default');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. FILTER BY COLOR
                  const Text("Filter By Color", style: TextStyle(fontWeight: FontWeight.w600)),
                  Wrap(
                    spacing: 10,
                    children: ['Gold', 'Silver', 'Other'].map((color) {
                      return ChoiceChip(
                        label: Text(color),
                        selected: selectedColorFilter == color,
                        onSelected: (bool selected) {
                          setModalState(() {
                            selectedColorFilter = selected ? color : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 3. FILTER BY PRICE RANGE (Updated to 20,000)
                  Text("Price Range: PKR ${_currentPriceRange.start.toInt()} - ${_currentPriceRange.end.toInt()}", 
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                  RangeSlider(
                    values: _currentPriceRange,
                    min: 0,
                    max: 20000, // 🔥 Changed Max Limit to 20,000
                    divisions: 100,
                    labels: RangeLabels(
                      _currentPriceRange.start.round().toString(),
                      _currentPriceRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        _currentPriceRange = values;
                      });
                    },
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      onPressed: () {
                        // Apply changes to main state
                        setState(() {}); 
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: showFilterBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                // Reset Filters
                sortBy = 'default';
                selectedColorFilter = null;
                _currentPriceRange = const RangeValues(0, 20000);
                searchQuery = ""; // Reset Search
                searchController.clear();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Get.to(() => const CartPage());
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Beautiful Jewellery', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const Text('for you', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // 🔥 UPDATE 2: SEARCH BAR ADDED
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search jewellery...",
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              categorySelector(),
              const SizedBox(height: 10),
              
              if(selectedColorFilter != null || sortBy != 'default' || searchQuery.isNotEmpty)
                Text(
                  "Filters Active: ${selectedColorFilter ?? 'All Colors'} | Sort: $sortBy",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),

              const SizedBox(height: 10),

              // 🔹 STREAM BUILDER WITH SEARCH & FILTER LOGIC
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getJewelleryItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No items found.'));
                    }

                    // 1. Get All Data
                    var docs = snapshot.data!.docs;

                    // 2. APPLY FILTERING (Client Side)
                    var filteredList = docs.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      
                      // Price Parse
                      double price = double.tryParse(data['price'].toString()) ?? 0.0;
                      
                      // Color Check
                      String color = (data['color'] ?? '').toString().toLowerCase();
                      String? filterColor = selectedColorFilter?.toLowerCase();

                      // Name Check for Search
                      String name = (data['name'] ?? '').toString().toLowerCase();

                      // Condition 1: Price Range
                      bool pricePass = price >= _currentPriceRange.start && price <= _currentPriceRange.end;

                      // Condition 2: Color
                      bool colorPass = filterColor == null || color.contains(filterColor);

                      // 🔥 Condition 3: Search Query
                      bool searchPass = searchQuery.isEmpty || name.contains(searchQuery);

                      return pricePass && colorPass && searchPass;
                    }).toList();

                    // 3. APPLY SORTING
                    if (sortBy == 'low_high') {
                      filteredList.sort((a, b) {
                        double p1 = double.tryParse((a.data() as Map)['price'].toString()) ?? 0;
                        double p2 = double.tryParse((b.data() as Map)['price'].toString()) ?? 0;
                        return p1.compareTo(p2);
                      });
                    } else if (sortBy == 'high_low') {
                      filteredList.sort((a, b) {
                        double p1 = double.tryParse((a.data() as Map)['price'].toString()) ?? 0;
                        double p2 = double.tryParse((b.data() as Map)['price'].toString()) ?? 0;
                        return p2.compareTo(p1); // Reverse
                      });
                    }

                    if (filteredList.isEmpty) {
                       return const Center(child: Text('No items match your search or filters.'));
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        var item = filteredList[index];
                        var data = item.data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () {
                            Get.to(() => JewelleryDetailPage(jewelleryData: data));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 140,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Hero(
                                      tag: data['image'] ?? 'img$index',
                                      child: Image.network(
                                        data['image'] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['name'] ?? 'No Name',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              data['description'] ?? 'No description',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey, height: 1.2),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "PKR ${data['price'] ?? '0'}",
                                          style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
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
      ),
    );
  }
}


class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: Drawer(child: UDrawerdata()),
      floatingActionButton: Row(
        children: [
           FloatingActionButton(
            focusColor: Colors.blue,
            
            onPressed: () {
              Get.to(() => const ArEaringScreen());
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.earbuds_outlined, color: Colors.black),
          ),
          FloatingActionButton(
            focusColor: Colors.blue,
            
            onPressed: () {
              Get.to(() => const ArChainScreen());
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.circle_outlined, color: Colors.black),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text("Welcome"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // Keep transparent for Dark Mode
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Select Category",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // Row containing the two buttons
              Row(
                children: [
                  // 1. MAN BUTTON
                  Expanded(
                    child: _buildGenderButton(
                      context,
                      title: "Man",
                      icon: Icons.male_rounded,
                      color: Colors.blueAccent,
                      onTap: () {
                        // Navigate to Dashboard (You can pass "Man" data if needed later)
                        Get.to(() => HomePage(gender: 'Man'));
                      },
                    ),
                  ),

                  SizedBox(width: 20), // Spacing between buttons
                  // 2. WOMAN BUTTON
                  Expanded(
                    child: _buildGenderButton(
                      context,
                      title: "Woman",
                      icon: Icons.female_rounded,
                      color: Colors.pinkAccent,
                      onTap: () {
                        // Navigate to Dashboard (You can pass "Woman" data if needed later)
                        Get.to(() => HomePage(gender: 'Woman'));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Custom Buttons
  Widget _buildGenderButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180, // Large Height
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Adapts to Dark Mode
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ), // Colored Border
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(
                0.2,
              ), // Glow effect based on gender color
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: color),
            ),
            SizedBox(height: 15),

            // Title Text
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                // color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}