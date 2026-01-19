// ignore_for_file: file_names, prefer_const_constructors, unnecessary_to_list_in_spreads, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jewellery_app/Admin/DrawerData.dart';

class DeliveredOrders extends StatefulWidget {
  @override
  State<DeliveredOrders> createState() => _DeliveredOrdersState();
}

class _DeliveredOrdersState extends State<DeliveredOrders> {
  final CollectionReference deliveredOrdersCollection = 
      FirebaseFirestore.instance.collection('DeliveredOrders');

  // Function to delete a specific document
  Future<void> _deleteOrder(String docId) async {
    await deliveredOrdersCollection.doc(docId).delete();
  }

  // Function to delete all documents in the collection
  Future<void> _deleteAllOrders() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await deliveredOrdersCollection.get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivered Orders'),
        actions: [
          TextButton(
            onPressed: () async {
              await _deleteAllOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("All delivered orders deleted")),
              );
            },
            child: Text(
              "Delete All",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
      drawer: Drawer(child: Drawerdata()),
      body: StreamBuilder<QuerySnapshot>(
        stream: deliveredOrdersCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No delivered orders.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var orderData = doc.data() as Map<String, dynamic>;
              var items = orderData['items'] as List<dynamic> ?? [];
              var deliveredTime = orderData['timestamp']?.toDate() ?? DateTime.now();

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  // title: Text('Name: ${orderData['userName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${orderData['userEmail']}'),
                      // Text('Address: ${orderData['userAddress']}'),
                      Text('Delivered Time: ${deliveredTime.toLocal()}'),
                      Text('Total Price: ${orderData['totalPrice']}'),
                      SizedBox(height: 4),
                      Text('Items:'),
                      ...items.map((item) {
                        return Text(
                          'Order: ${item['name']} (Qty: ${item['quantity']})',
                        );
                      }).toList(),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      await _deleteOrder(doc.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Order deleted")),
                      );
                    },
                    icon: Icon(Icons.delete_forever, color: Colors.red),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
