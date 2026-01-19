// // add_CartPage class to display cart items
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jewellery_app/Users/Homepage.dart';
// import 'package:jewellery_app/Users/UserDrawerData.dart';
// import 'package:get/get.dart';

// class add_CartPage extends StatelessWidget {
//   final TextEditingController addressController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final CartManager cartManager = Get.put(CartManager());

//     return Scaffold(
//       // backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text('Your Cart',)
//         //  style: TextStyle(color: Colors.white)),
//         // iconTheme: IconThemeData(color: Colors.white),
//         // backgroundColor: Colors.black,
//       ),
//       drawer: Drawer(
//         child: UDrawerdata(),
//       ),
//       body: Obx(() {
//         if (cartManager.cartItems.isEmpty) {
//           return Center(
//               child: Text('Your cart is empty.',));
//                   // style: TextStyle(color: Colors.white)));
//         }

//         return Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cartManager.cartItems.length,
//                 itemBuilder: (context, index) {
//                   final item = cartManager.cartItems[index];
//                   return ListTile(
//                     title: Text(item['name'],
//                         // style: TextStyle(color: Colors.white)
//                         ),
//                     subtitle: Text(
//                         "Rs: ${item['totalPrice']} (x${item['quantity']})",
//                         // style: TextStyle(color: Colors.white)
//                         ),
//                     trailing: IconButton(
//                       icon: Icon(Icons.remove_circle,
//                        color: Colors.red
//                        ),
//                       onPressed: () {
//                         cartManager.removeFromCart(index);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 // style: TextStyle(color: Colors.white),
//                 controller: addressController,
//                 decoration: InputDecoration(
//                   labelText: 'Enter your address',
//                   // labelStyle: TextStyle(color: Colors.white),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide(color: Colors.orange),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide(color: Colors.orange),
//                   ),
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => proceedToCheckout(cartManager.cartItems),
//               child: Text('Proceed to Checkout'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.black,
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }

//   Future<void> proceedToCheckout(List<Map<String, dynamic>> cartItems) async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     final userEmail = FirebaseAuth.instance.currentUser?.email;

//     if (userId != null) {
//       final userAddress = addressController.text.trim();
//       if (userAddress.isEmpty) {
//         Get.snackbar(
//           "Error", 
//           "Please enter your address.",
//           // backgroundColor: Colors.transparent,
//           // colorText: Colors.white,
//         );
//         return;
//       }

//       try {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(userId)
//             .get();
//         String userName = userDoc['name'] ?? 'Unknown User';

//         await FirebaseFirestore.instance.collection('Orders').add({
//           'userId': userId,
//           'userEmail': userEmail,
//           'userName': userName,
//           'userAddress': userAddress,
//           'items': cartItems,
//           'totalPrice': cartItems.fold(
//               0.0, (sum, item) => sum + (item['totalPrice'] ?? 0.0)),
//           'timestamp': FieldValue.serverTimestamp(),
//         });

//         Get.snackbar(
//           "Order Placed", 
//           "Your order has been placed successfully!",
//           // backgroundColor: Colors.transparent,
//           // colorText: Colors.white,
//         );

//         Get.find<CartManager>().clearCart();
//         Get.back();
//       } catch (e) {
//         Get.snackbar(
//           "Error", 
//           "Failed to place order: $e",
//           // backgroundColor: Colors.transparent,
//           // colorText: Colors.white,
//         );
//       }
//     } else {
//       Get.snackbar(
//         "Error", 
//         "You must be logged in to place an order.",
//         // backgroundColor: Colors.transparent,
//         // colorText: Colors.white,
//       );
//     }
//   }
// }