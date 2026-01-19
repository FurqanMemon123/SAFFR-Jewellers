// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:jewellery_app/Users/UserDrawerData.dart';
// // 👇 New Imports
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class CartPage extends StatefulWidget {
//   const CartPage({Key? key}) : super(key: key);

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   final user = FirebaseAuth.instance.currentUser;

//   // 📍 Map & Location Variables
//   GoogleMapController? mapController;
//   LatLng? currentPosition;
//   String currentAddress = "Fetching location...";
//   Set<Marker> markers = {};
  
//   // 💳 Payment Variable
//   String selectedPaymentMethod = 'COD'; // Default Cash on Delivery

//   @override
//   void initState() {
//     super.initState();
//     _determinePosition(); // Page load hote hi location lo
//   }

//   // 1️⃣ Location Permission & Current Position Logic
//   Future<void> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() => currentAddress = "Location services are disabled.");
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() => currentAddress = "Location permissions are denied");
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       setState(() => currentAddress = "Location permissions are permanently denied");
//       return;
//     }

//     // Get Position
//     Position position = await Geolocator.getCurrentPosition();
//     _updateLocation(LatLng(position.latitude, position.longitude));
//   }

//   // 2️⃣ Update Map & Address based on LatLng
//   Future<void> _updateLocation(LatLng pos) async {
//     setState(() {
//       currentPosition = pos;
//       markers.clear();
//       markers.add(Marker(markerId: const MarkerId('current'), position: pos));
//     });

//     // Move Camera
//     mapController?.animateCamera(CameraUpdate.newLatLng(pos));

//     // Get Address String from Coordinates
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
//       Placemark place = placemarks[0];
//       setState(() {
//         currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
//       });
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (user == null) {
//       return const Scaffold(body: Center(child: Text("No user logged in")));
//     }

//     final userCart = FirebaseFirestore.instance
//         .collection('Users')
//         .doc(user!.uid)
//         .collection('Cart');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Cart'),
//         centerTitle: true,
//         elevation: 3,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//       ),
//       drawer: UDrawerdata(),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: userCart.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('Your cart is empty.'));
//           }

//           final cartDocs = snapshot.data!.docs;

//           // ✅ Total Calculation
//           double total = 0;
//           for (var doc in cartDocs) {
//             final data = doc.data() as Map<String, dynamic>;
//             bool isChecked = data['isChecked'] ?? false;
//             if (isChecked) {
//               total += (data['totalPrice'] ?? 0).toDouble();
//             }
//           }

//           return Column(
//             children: [
//               // 🛒 Cart Items List
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: cartDocs.length,
//                   itemBuilder: (context, index) {
//                     final doc = cartDocs[index];
//                     final item = doc.data() as Map<String, dynamic>;
//                     double price = (item['price'] ?? 0).toDouble();
//                     int quantity = (item['quantity'] ?? 1);

//                     return Card(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       elevation: 3,
//                       child: ListTile(
//                         leading: Checkbox(
//                           value: item['isChecked'] ?? false,
//                           onChanged: (bool? value) async {
//                             await doc.reference.update({'isChecked': value});
//                           },
//                         ),
//                         title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
//                         subtitle: Text("Rs ${price * quantity} (x$quantity)"),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.remove_circle),
//                               onPressed: () async {
//                                 if (quantity > 1) {
//                                   quantity--;
//                                   await doc.reference.update({'quantity': quantity, 'totalPrice': price * quantity});
//                                 }
//                               },
//                             ),
//                             Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
//                             IconButton(
//                               icon: const Icon(Icons.add_circle),
//                               onPressed: () async {
//                                 quantity++;
//                                 await doc.reference.update({'quantity': quantity, 'totalPrice': price * quantity});
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.redAccent),
//                               onPressed: () async => await doc.reference.delete(),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               // ✅ Checkout Section (Map + Payment + Button)
//               Container(
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                   boxShadow: [
//                     BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -3)),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text("Total (selected): Rs $total", 
//                       textAlign: TextAlign.right, 
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
//                     ),
//                     const SizedBox(height: 12),

//                     // 🗺️ Google Map Widget
//                     SizedBox(
//                       height: 180, // Map Height
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(15),
//                         child: currentPosition == null 
//                           ? const Center(child: CircularProgressIndicator()) 
//                           : GoogleMap(
//                               initialCameraPosition: CameraPosition(target: currentPosition!, zoom: 15),
//                               markers: markers,
//                               myLocationEnabled: true,
//                               zoomControlsEnabled: false,
//                               onMapCreated: (controller) => mapController = controller,
//                               onTap: (pos) => _updateLocation(pos), // Tap to change location
//                             ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 8),
                    
//                     // 🏠 Address Display
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on, color: Colors.red, size: 20),
//                         const SizedBox(width: 5),
//                         Expanded(child: Text(currentAddress, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
//                       ],
//                     ),

//                     const SizedBox(height: 10),

//                     // 💳 Payment Methods Radio Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: RadioListTile(
//                             contentPadding: EdgeInsets.zero,
//                             title: const Text("COD", style: TextStyle(fontSize: 14)),
//                             value: "COD",
//                             groupValue: selectedPaymentMethod,
//                             onChanged: (val) => setState(() => selectedPaymentMethod = val.toString()),
//                           ),
//                         ),
//                         Expanded(
//                           child: RadioListTile(
//                             contentPadding: EdgeInsets.zero,
//                             title: const Text("Online", style: TextStyle(fontSize: 14)),
//                             value: "Online",
//                             groupValue: selectedPaymentMethod,
//                             onChanged: (val) => setState(() => selectedPaymentMethod = val.toString()),
//                           ),
//                         ),
//                       ],
//                     ),

//                     // ✅ Checkout Button
//                     ElevatedButton(
//                       onPressed: () async {
//                         if (currentPosition == null) {
//                           Get.snackbar("Error", "Please wait for location or select on map");
//                           return;
//                         }

//                         // Filter Checked Docs
//                         final checkedDocs = cartDocs.where((doc) {
//                           final data = doc.data() as Map<String, dynamic>;
//                           return data['isChecked'] == true;
//                         }).toList();

//                         if (checkedDocs.isEmpty) {
//                           Get.snackbar("Error", "No items selected!");
//                           return;
//                         }

//                         // Place Order
//                         await FirebaseFirestore.instance.collection('Orders').add({
//                           'userId': user!.uid,
//                           'userEmail': user?.email,
//                           'items': checkedDocs.map((d) => d.data()).toList(),
                          
//                           // 👇 Sending Map & Payment Data
//                           'address': currentAddress,
//                           'location': {
//                             'lat': currentPosition!.latitude,
//                             'lng': currentPosition!.longitude
//                           },
//                           'paymentMethod': selectedPaymentMethod,
//                           'paymentStatus': selectedPaymentMethod == 'Online' ? 'Pending' : 'Unpaid',
                          
//                           'totalPrice': total,
//                           'timestamp': FieldValue.serverTimestamp(),
//                         });

//                         // Delete Checked Items
//                         for (var doc in checkedDocs) {
//                           await doc.reference.delete();
//                         }

//                         Get.snackbar("Success", "Order placed via $selectedPaymentMethod!");
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text('Proceed to Checkout'),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// without online paymentMethod
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jewellery_app/Users/UserDrawerData.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController addressController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  // final Color primaryColor = const Color(0xFF0C6980);
  // final Color backgroundColor = const Color(0xFFC0F0F7);

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        
        body: Center(
          child: Text(
            "No user logged in",
            // style: TextStyle(color: primaryColor, fontSize: 16),
          ),
        ),
      );
    }

    final userCart = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Cart');

    return Scaffold(
      // backgroundColor: backgroundColor,
      appBar: AppBar(
        
        // backgroundColor: primaryColor,
        // iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Your Cart',
          // style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      // drawer: UDrawerdata(),
      body: StreamBuilder<QuerySnapshot>(
        stream: userCart.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Your cart is empty.',
                // style: TextStyle(color: primaryColor, fontSize: 16),
              ),
            );
          }

          final cartDocs = snapshot.data!.docs;

          // ✅ Total only for checked items
          double total = 0;
          for (var doc in cartDocs) {
            final data = doc.data() as Map<String, dynamic>;
            bool isChecked = data['isChecked'] ?? false;
            if (isChecked) {
              total += (data['totalPrice'] ?? 0).toDouble();
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final doc = cartDocs[index];
                    final item = doc.data() as Map<String, dynamic>;

                    double price = (item['price'] ?? 0).toDouble();
                    int quantity = (item['quantity'] ?? 1);

                    return Card(
                      // color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        leading: Checkbox(
                          value: item['isChecked'] ?? false,
                          onChanged: (bool? value) async {
                            await doc.reference.update({'isChecked': value});
                          },
                          // activeColor: primaryColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        title: Text(
                          item['name'] ?? '',
                          style: TextStyle(
                            // color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Rs ${price * quantity} (x$quantity)",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                // color: primaryColor,
                              ),
                              onPressed: () async {
                                if (quantity > 1) {
                                  quantity--;
                                  await doc.reference.update({
                                    'quantity': quantity,
                                    'totalPrice': price * quantity,
                                  });
                                } 
                              },
                            ),
                            Text(
                              '$quantity',
                              style: TextStyle(
                                // color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle,
                              //  color: primaryColor
                               ),
                              onPressed: () async {
                                quantity++;
                                await doc.reference.update({
                                  'quantity': quantity,
                                  'totalPrice': price * quantity,
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                await doc.reference.delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ✅ Total Section
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ Show total for checked items only
                    Text(
                      "Total (selected): Rs $total",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        // color: primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  

                    // Address Field
                    TextField(
                      controller: addressController,
                      // style: TextStyle(color: primaryColor),
                      decoration: InputDecoration(
                        labelText: 'Enter your address',
                        // labelStyle: TextStyle(color: primaryColor),
                        filled: true,
                        // fillColor: backgroundColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            // color: primaryColor
                            ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            // color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  
                    // ✅ Checkout Button (checked items only)
                    ElevatedButton(
                      onPressed: () async {
                        final address = addressController.text.trim();
                        if (address.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please enter your address",
                            // backgroundColor: primaryColor.withOpacity(0.8),
                            // colorText: Colors.white,
                          );
                          return;
                        }

                        // ✅ Only get checked items
                        final checkedDocs = cartDocs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['isChecked'] == true;
                        }).toList();

                        if (checkedDocs.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "No items selected!",
                            // backgroundColor: primaryColor.withOpacity(0.8),
                            // colorText: Colors.white,
                          );
                          return;
                        }

                        double totalPrice = 0;
                        for (var doc in checkedDocs) {
                          final data = doc.data() as Map<String, dynamic>;
                          totalPrice += (data['totalPrice'] ?? 0).toDouble();
                        }

                        // ✅ Place order only for selected items
                        await FirebaseFirestore.instance
                            .collection('Orders')
                            .add({
                              'userId': user!.uid,
                              'userEmail': user?.email,
                              'items': checkedDocs
                                  .map((d) => d.data())
                                  .toList(),
                              'address': address,
                              'totalPrice': totalPrice,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                        // ✅ Delete only checked items
                        for (var doc in checkedDocs) {
                          await doc.reference.delete();
                        }

                        Get.snackbar(
                          "Success",
                          "Order placed successfully!",
                          // backgroundColor: primaryColor.withOpacity(0.8),
                          // colorText: Colors.white,
                        );

                        addressController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: primaryColor,
                        // foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:jewellery_app/Users/UserDrawerData.dart'; 

// class CartPage extends StatefulWidget {
//   const CartPage({Key? key}) : super(key: key);

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
//   final TextEditingController addressController = TextEditingController();
//   final user = FirebaseAuth.instance.currentUser;

//   // ✅ 1. Payment Method State
//   String selectedPaymentMethod = 'COD';


//   @override
//   Widget build(BuildContext context) {
//     if (user == null) {
//       return Scaffold(body: Center(child: Text("No user logged in")));
//     }

//     final userCart = FirebaseFirestore.instance.collection('Users').doc(user!.uid).collection('Cart');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Cart'),
//         centerTitle: true,
//         elevation: 3,
//         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
//       ),
//       drawer: UDrawerdata(),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: userCart.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('Your cart is empty.'));

//           final cartDocs = snapshot.data!.docs;

//           // Calculate Total
//           double total = 0;
//           final checkedDocs = cartDocs.where((doc) {
//              final data = doc.data() as Map<String, dynamic>;
//              return data['isChecked'] == true;
//           }).toList();
          
//           for (var doc in checkedDocs) {
//             final data = doc.data() as Map<String, dynamic>;
//             total += (data['totalPrice'] ?? 0).toDouble();
//           }

//           return Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: cartDocs.length,
//                   itemBuilder: (context, index) {
//                     final doc = cartDocs[index];
//                     final item = doc.data() as Map<String, dynamic>;
//                     double price = (item['price'] ?? 0).toDouble();
//                     int quantity = (item['quantity'] ?? 1);

//                     return Card(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       elevation: 3,
//                       child: ListTile(
//                         leading: Checkbox(
//                           value: item['isChecked'] ?? false,
//                           onChanged: (bool? value) async => await doc.reference.update({'isChecked': value}),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                         title: Text(item['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
//                         subtitle: Text("Rs ${price * quantity} (x$quantity)", style: TextStyle(color: Colors.grey[700], fontSize: 14)),
//                         trailing: IconButton(
//                            icon: const Icon(Icons.delete, color: Colors.redAccent),
//                            onPressed: () async => await doc.reference.delete(),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               // ✅ Total & Checkout Section
//               Container(
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -3))],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text("Total (selected): Rs $total", textAlign: TextAlign.right, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),

//                     // Address Field (Manual)
//                     TextField(
//                       controller: addressController,
//                       decoration: InputDecoration(
//                         labelText: 'Enter your address',
//                         filled: true,
//                         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey)),
//                         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1.5, color: Colors.blue)),
//                       ),
//                     ),
//                     const SizedBox(height: 15),

//                     // ✅ 3. RADIO BUTTONS (Payment Selection)
//                     const Text("Select Payment Method:", style: TextStyle(fontWeight: FontWeight.bold)),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: RadioListTile(
//                             contentPadding: EdgeInsets.zero,
//                             title: const Text("COD"),
//                             value: "COD",
//                             groupValue: selectedPaymentMethod,
//                             onChanged: (val) => setState(() => selectedPaymentMethod = val.toString()),
//                           ),
//                         ),
//                         Expanded(
//                           child: RadioListTile(
//                             contentPadding: EdgeInsets.zero,
//                             title: const Text("Online"),
//                             value: "Online",
//                             groupValue: selectedPaymentMethod,
//                             onChanged: (val) => setState(() => selectedPaymentMethod = val.toString()),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 10),

//                     // ✅ 4. Checkout Button
//                     ElevatedButton(
//                       onPressed: () async {
//                         // Basic Validation
//                         if (addressController.text.trim().isEmpty) {
//                           Get.snackbar("Error", "Please enter address");
                          
//                           return ;
//                         }
//                         if (checkedDocs.isEmpty) {
//                           Get.snackbar("Error", "No items selected");
//                           return;
//                         }

//                         // LOGIC: Check Payment Method
//                         // if (selectedPaymentMethod == 'Online') {
//                         //   // 👉 Stripe Payment Start
//                         //   if (total < 1) {
//                         //     Get.snackbar("Error", "Amount too low for online payment");
//                         //     return;
//                         //   }
//                         //   await makePayment(total, checkedDocs);
//                         // } 
//                         if (selectedPaymentMethod == 'COD') {
//                           // 👉 COD Direct Order
//                           await placeOrder(checkedDocs, total, isPaid: false);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                       ),
//                       child: Text(selectedPaymentMethod == 'Online' ? 'Pay & Order' : 'Place Order (COD)'),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

  // // 🔥 5. STRIPE PAYMENT FUNCTIONS
  // Future<void> makePayment(double amount, List<QueryDocumentSnapshot> items) async {
  //   try {
  //     // 1. Intent Create
  //     Map<String, dynamic>? paymentIntentData = await createPaymentIntent(amount, 'USD'); 

  //     // 2. Sheet Init
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         paymentIntentClientSecret: paymentIntentData!['client_secret'],
  //         merchantDisplayName: 'Jewellery Store',
  //         style: ThemeMode.light,
  //       ),
  //     );

  //     // 3. Display Sheet
  //     await displayPaymentSheet(items, amount);

  //   } catch (e) {
  //     Get.snackbar("Error", "Payment Failed: $e");
  //     print(e);
  //   }
  // }

  // // Create Intent (API Call)
  // createPaymentIntent(double amount, String currency) async {
  //   try {
  //     int amountInCents = (amount * 100).toInt(); // Stripe needs cents
  //     Map<String, dynamic> body = {
  //       'amount': amountInCents.toString(),
  //       'currency': currency,
  //       'payment_method_types[]': 'card'
  //     };

  //     var response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //       headers: {
  //         'Authorization': 'Bearer $stripeSecretKey',
  //         'Content-Type': 'application/x-www-form-urlencoded'
  //       },
  //       body: body,
  //     );
  //     return jsonDecode(response.body);
  //   } catch (err) {
  //     print('Error calling Stripe: ${err.toString()}');
  //   }
  // }

  // Show Sheet & Handle Success
  // displayPaymentSheet(List<QueryDocumentSnapshot> items, double totalAmount) async {
  //   try {
  //     await Stripe.instance.presentPaymentSheet().then((newValue) {
        
  //       // 🎉 Payment Success -> Save Order
  //       Get.snackbar("Success", "Payment Successful!");
  //       placeOrder(items, totalAmount, isPaid: true);

  //     }).onError((error, stackTrace) {
  //       Get.snackbar("Cancelled", "Payment Cancelled");
  //     });
  //   } on StripeException catch (e) {
  //     Get.snackbar("Error", "Stripe Error: $e");
  //   }
  // }

//   // 🔥 6. SAVE ORDER TO FIREBASE
//   Future<void> placeOrder(List<QueryDocumentSnapshot> items, double totalAmount, {bool isPaid = false}) async {
//     try {
//       await FirebaseFirestore.instance.collection('Orders').add({
//         'userId': user!.uid,
//         'userEmail': user?.email,
//         'items': items.map((d) => d.data()).toList(),
//         'address': addressController.text.trim(),
//         'totalPrice': totalAmount,
//         'paymentMethod': selectedPaymentMethod,
//         'paymentStatus': isPaid ? 'Paid (Stripe)' : 'Pending (COD)', // ✅ Status Logic
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Delete items from Cart
//       for (var doc in items) {
//         await doc.reference.delete();
//       }

//       Get.snackbar("Success", "Order placed successfully!");
//       addressController.clear();
      
//     } catch (e) {
//       Get.snackbar("Error", "Failed to save order: $e");
//     }
//   }
// }