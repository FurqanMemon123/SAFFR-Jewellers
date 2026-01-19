// ignore_for_file: prefer_const_constructors, file_names, use_key_in_widget_constructors, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewellery_app/Admin/DrawerData.dart';

class DeclinedOrders extends StatefulWidget {
  @override
  State<DeclinedOrders> createState() => _DeclinedOrdersState();
}

class _DeclinedOrdersState extends State<DeclinedOrders> {

  // final String userId;
  // DeclinedOrders({required this.userId});

  final CollectionReference declinedOrdersCollection =
      FirebaseFirestore.instance.collection('DeclinedOrders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rejected Orders',
         ),
         actions: [
          TextButton(onPressed: (){

          }, child: Text(
            "Delete All",style: TextStyle(
              color: Colors.red
            ),
          ))
         ],
      ),
      drawer: Drawer(child: Drawerdata()),
      body: StreamBuilder<QuerySnapshot>(
        stream: declinedOrdersCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No declined orders.',
               ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var orderData = doc.data() as Map<String, dynamic>;
              var items = orderData['items'] as List<dynamic> ?? [];
              var timestamp = orderData['timestamp']?.toDate() ?? DateTime.now();

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  // title: Text('Name: ${orderData['userName']}',
                  //  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${orderData['userEmail']}',
                       ),
                      Text('Total Price: ${orderData['totalPrice'].toStringAsFixed(2)}',
                       ),
                      Text('Ordered Time: ${timestamp.toLocal()}',
                       ),
                      SizedBox(height: 4),
                      Text('Items:',
                       ),
                      ...items.map((item) {
                        return Text(
                          'Order: ${item['name']} (Qty: ${item['quantity']})',
                        );
                      }).toList(),
                    ],
                  ),
                  trailing: IconButton(onPressed: (){

                  }, icon: Icon(Icons.delete_forever,color: Colors.red,)),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Future<void> deleteorder(String notificationId, BuildContext context) async {
  //   final CollectionReference notificationsCollection = FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(userId)
  //       .collection('DeclinedOrders');
  //   await notificationsCollection.doc(notificationId).delete();

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Rejected Order has been deleted.'),
  //       duration: Duration(seconds: 2),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  // Future<void> DeleteallOrders(BuildContext context) async {
  //   final CollectionReference notificationsCollection = FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(userId)
  //       .collection('DeclinedOrders');

  //   final querySnapshot = await notificationsCollection.get();

  //   for (var doc in querySnapshot.docs) {
  //     await notificationsCollection.doc(doc.id).delete();
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('All Rejected Orders have been deleted.'),
  //       duration: Duration(seconds: 2),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

}
