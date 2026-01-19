// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:food_app/Admin/DrawerData.dart';
// import 'package:get/get.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AdminDashboard extends StatefulWidget {
//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   final CollectionReference ordersCollection = FirebaseFirestore.instance.collection('Orders');
//   List<DocumentSnapshot> orders = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchOrders();
//   }

//   Future<void> fetchOrders() async {
//     setState(() => isLoading = true);
//     try {
//       QuerySnapshot snapshot = await ordersCollection.get();
//       setState(() {
//         orders = snapshot.docs;
//         isLoading = false;
//       });
//     } catch (e) {
//       // Get.snackbar("Failed", "$e");
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> updateOrderStatus(String orderId, String status, String userId) async {
//     try {
//       var orderData = await ordersCollection.doc(orderId).get();
//       if (!orderData.exists) {
//         Get.snackbar("Error", "Order not found");
//         return;
//       }

//       var orderDetails = orderData.data() as Map<String, dynamic>;
//       String dishNames = (orderDetails['items'] as List<dynamic>).map((item) => item['name']).join(', ');

//       if (status == 'Delivered') {
//         // Save delivered order
//         await FirebaseFirestore.instance.collection('DeliveredOrders').add({
//           'userName': orderDetails['userName'],
//           'userEmail': orderDetails['userEmail'],
//           'address': orderDetails['address'],
//           'items': orderDetails['items'],
//           'totalPrice': orderDetails['totalPrice'],
//           'timestamp': FieldValue.serverTimestamp(),
//         });

//         // Notify user
//         await notifyUser(userId, 'Your order with dishes: $dishNames has been delivered.');

//         // Delete the order
//         await ordersCollection.doc(orderId).delete();
//         Get.snackbar("Success", "Order $orderId has been delivered and removed.",);
//       } else if (status == 'Declined') {
//         // Save the declined order
//         await FirebaseFirestore.instance.collection('DeclinedOrders').add({
//           'userName': orderDetails['userName'],
//           'userEmail': orderDetails['userEmail'],
//           'address': orderDetails['address'],
//           'items': orderDetails['items'],
//           'totalPrice': orderDetails['totalPrice'],
//           'timestamp': FieldValue.serverTimestamp(),
//         });

//         // Notify user about order rejection
//         await notifyUser(userId, 'Your order has been rejected. Please contact with admin.');

//         // Delete the order
//         await ordersCollection.doc(orderId).delete();
//         Get.snackbar("Success", "Order $orderId has been rejected and removed.");
//       } else {
//         await ordersCollection.doc(orderId).update({'status': status});
//         await notifyUser(userId, 'Your order with dishes: $dishNames has been $status.');
//         Get.snackbar("Success", "Order status updated to $status.");
//       }

//       fetchOrders(); // Refresh orders after status update
//     } catch (e) {
//       Get.snackbar("Failed to update order status", "$e");
//     }
//   }

//   Future<void> notifyUser(String userId, String message) async {
//     try {
//       String fcmToken = await getUserFCMToken(userId); // Fetch the user's FCM token
//       if (fcmToken.isNotEmpty) {
//         final notification = {
//           "to": fcmToken,
//           "notification": {
//             "title": "Order Update",
//             "body": message,
//           },
//         };

//         await sendFCM(notification);
//       }
//     } catch (e) {
//       Get.snackbar("Notification Error", "$e");
//     }
//   }

//   Future<String> getUserFCMToken(String userId) async {
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
//     return userDoc['fcmToken'] ?? ''; // Assuming fcmToken is stored in the user's document
//   }

//   Future<void> sendFCM(Map<String, dynamic> notification) async {
//     await http.post(
//       Uri.parse("https://fcm.googleapis.com/fcm/send"),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "key=YOUR_SERVER_KEY", // Replace with your server key
//       },
//       body: jsonEncode(notification),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         title: Text('Admin Dashboard',),
//         //  style: TextStyle(color: Colors.transparent)),
//         // backgroundColor: Colors.transparent,
//         // iconTheme: IconThemeData(color: Colors.transparent),
//         actions: [
//           IconButton(
//             onPressed: fetchOrders,
//             icon: Icon(Icons.refresh,)
//             //  color: Colors.transparent),
//           ),
//         ],
//       ),
//       drawer: Drawer(child: Drawerdata()),
//       body: SafeArea(
//         child: isLoading
//             ? Center(child: CircularProgressIndicator())
//             : orders.isEmpty
//                 ? Center(child: Text('No orders found.',
//                 //  style: TextStyle(color: Colors.transparent)
//                  ))
//                 : buildOrderListView(),
//       ),
//     );
//   }

//   Widget buildOrderListView() {
//     return ListView.builder(
//       itemCount: orders.length,
//       itemBuilder: (context, index) {
//         var orderData = orders[index].data() as Map<String, dynamic>;
//         String orderId = orders[index].id;
//         String userId = orderData['userId'] ?? ''; // Assuming userId is stored in orderData
//         String status = orderData['status'] ?? 'Pending';

//         return buildOrderCard(orderData, orderId, userId, status);
//       },
//     );
//   }

//   Widget buildOrderCard(Map<String, dynamic> orderData, String orderId, String userId, String status) {
//     var items = orderData['items'] as List<dynamic>;
//     var timestamp = orderData['timestamp']?.toDate() ?? DateTime.now();
//     double totalPrice = orderData['totalPrice'] ?? 0.0;

//     return Card(
//       color: Colors.transparent,
//       margin: EdgeInsets.all(8),
//       child: ListTile(
//         title: buildOrderDetails(orderData),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             buildOrderItems(items),
//             SizedBox(height: 4),
//             Text('Total Price: ${totalPrice.toStringAsFixed(2)}',
//             //  style: TextStyle(color: Colors.transparent)
//              ),
//             Text('Ordered Time: ${timestamp.toLocal()}',
//             //  style: TextStyle(color: Colors.transparent)
//              ),
//             buildOrderActions(orderId, userId, status),
//           ],
//         ),
//       ),
//     );
//   }

//   Column buildOrderDetails(Map<String, dynamic> orderData) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Name: ${orderData['userName']}', 
//         // style: TextStyle(color: Colors.transparent)
//         ),
//         Text('Email: ${orderData['userEmail']}',
//         //  style: TextStyle(color: Colors.transparent)
//         ),
//         Text('Address: ${orderData['address']}',
//         //  style: TextStyle(color: Colors.transparent)
//         ),
//       ],
//     );
//   }

//   Widget buildOrderItems(List<dynamic> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ...items.map((item) {
//           return Text('Dish: ${item['name']} (Qty: ${item['quantity']})', 
//           // style: TextStyle(color: Colors.transparent)
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget buildOrderActions(String orderId, String userId, String status) {
//     if (status == 'Accepted') {
//       return Center(
//         child: ElevatedButton(
//           onPressed: () => updateOrderStatus(orderId, 'Out for Delivery', userId),
//           child: Text('Out for Delivery',
//           //  style: TextStyle(color: Colors.transparent)
//            ),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//         ),
//       );
//     } else if (status == 'Out for Delivery') {
//       return Center(
//         child: ElevatedButton(
//           onPressed: () => updateOrderStatus(orderId, 'Delivered', userId),
//           child: Text('Delivered', 
//           // style: TextStyle(color: Colors.transparent)
//           ),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//         ),
//       );
//     } else {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           ElevatedButton(
//             onPressed: () => updateOrderStatus(orderId, 'Accepted', userId),
//             child: Text('Accept',
//              style: TextStyle(color: Colors.white)
//              ),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//           ),
//           ElevatedButton(
//             onPressed: () => updateOrderStatus(orderId, 'Declined', userId),
//             child: Text('Decline',
//              style: TextStyle(color: Colors.white)
//              ),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           ),
//         ],
//       );
//     }
//   }
// }


// ignore_for_file: prefer_const_constructors, file_names, unnecessary_to_list_in_spreads, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewellery_app/Admin/DrawerData.dart';
import 'package:get/get.dart';

// ignore: use_key_in_widget_constructors
class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final CollectionReference ordersCollection = FirebaseFirestore.instance.collection('Orders');

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
  try {
    var orderDoc = ordersCollection.doc(orderId);
    var orderSnapshot = await orderDoc.get();

    if (!orderSnapshot.exists) {
      Get.snackbar("Error", "Order not found");
      return;
    }

    var orderDetails = orderSnapshot.data() as Map<String, dynamic>;
    
    // Batch create karein
    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (status == 'Delivered') {
      // Step 1: Add to DeliveredOrders
      var deliveredRef = FirebaseFirestore.instance.collection('DeliveredOrders').doc();
      batch.set(deliveredRef, {
        ...orderDetails, // Purana sara data copy
        'status': 'Delivered',
        'deliveredAt': FieldValue.serverTimestamp(),
        'address': orderDetails['userAddress'], // Ensure address is copied
      });
      // Step 2: Delete from Orders
      batch.delete(orderDoc);
      
      Get.snackbar("Success", "Order Delivered & Moved to History");

    } else if (status == 'Declined') {
      var declinedRef = FirebaseFirestore.instance.collection('DeclinedOrders').doc();
      batch.set(declinedRef, {
        ...orderDetails,
        'status': 'Declined',
        'declinedAt': FieldValue.serverTimestamp(),
        'address': orderDetails['userAddress'], // Ensure address is copied
      });
      batch.delete(orderDoc);
      
      Get.snackbar("Success", "Order Declined");

    } else {
      // Normal Update (Accept / Out for Delivery)
      batch.update(orderDoc, {'status': status});
      Get.snackbar("Success", "Status updated to $status");
    }

    // Saare changes ek sath commit karein
    await batch.commit();

  } catch (e) {
    Get.snackbar("Error", e.toString());
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      drawer: Drawer(child: Drawerdata()),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: ordersCollection.orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No orders found.'));
            }

            var orders = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var orderData = orders[index].data() as Map<String, dynamic>;
                String orderId = orders[index].id;
                String status = orderData['status'] ?? 'Pending';

                return buildOrderCard(orderData, orderId, status);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> orderData, String orderId, String status) {
    var items = orderData['items'] as List<dynamic>;
    var timestamp = orderData['timestamp']?.toDate() ?? DateTime.now();
    double totalPrice = orderData['totalPrice'] ?? 0.0;

    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: buildOrderDetails(orderData),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildOrderItems(items),
            SizedBox(height: 4),
            Text('Total Price: ${totalPrice.toStringAsFixed(2)}'),
            Text('Ordered Time: ${timestamp.toLocal()}'),
            buildOrderActions(orderId, status),
          ],
        ),
      ),
    );
  }

  Column buildOrderDetails(Map<String, dynamic> orderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text('Name: ${orderData['userName']}'),
        Text('Email: ${orderData['userEmail']}'),
        Text('Address: ${orderData['address']}'),
      ],
    );
  }

  Widget buildOrderItems(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map((item) {
          return Text('Order: ${item['name']} (Qty: ${item['quantity']})');
        }).toList(),
      ],
    );
  }

  Widget buildOrderActions(String orderId, String status) {
    if (status == 'Accepted') {
      return Center(
        child: ElevatedButton(
          onPressed: () => updateOrderStatus(orderId, 'Out for Delivery'),
          child: Text('Out for Delivery',
          style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
      );
    } else if (status == 'Out for Delivery') {
      return Center(
        child: ElevatedButton(
          onPressed: () => updateOrderStatus(orderId, 'Delivered'),
          child: Text('Delivered',
          style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () => updateOrderStatus(orderId, 'Accepted'),
            child: Text('Accept', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          ElevatedButton(
            onPressed: () => updateOrderStatus(orderId, 'Declined'),
            child: Text('Decline', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    }
  }
}
