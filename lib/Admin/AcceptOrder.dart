// ignore_for_file: prefer_const_constructors, unnecessary_to_list_in_spreads, avoid_print, use_key_in_widget_constructors, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewellery_app/Admin/DrawerData.dart';
import 'package:get/get.dart';

class AcceptedOrders extends StatefulWidget {
  @override
  State<AcceptedOrders> createState() => _AcceptedOrdersState();
}

class _AcceptedOrdersState extends State<AcceptedOrders> {
  final CollectionReference ordersCollection = FirebaseFirestore.instance.collection('Orders');
  List<DocumentSnapshot> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAcceptedOrders();
  }

  Future<void> fetchAcceptedOrders() async {
    setState(() {
      isLoading = true; // Show loading indicator while fetching
    });

    try {
      QuerySnapshot snapshot = await ordersCollection.where('status', isEqualTo: 'Accepted').get();
      setState(() {
        orders = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Failed to load accepted orders: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Accepted Orders', 
        // style: TextStyle(color: Colors.white)
        ),
        // backgroundColor: Colors.black,
        // iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: fetchAcceptedOrders, // Refresh orders
            icon: Icon(Icons.refresh,
            //  color: Colors.white
             ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Drawerdata(),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? Center(child: Text('No accepted orders found.',
                //  style: TextStyle(color: Colors.white)
                 ))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var orderData = orders[index].data() as Map<String, dynamic>;
                      var items = orderData['items'] as List<dynamic>;
                      var timestamp = orderData['timestamp']?.toDate() ?? DateTime.now();

                      return Card(
                        // color: Colors.white10,
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Text('Name: ${orderData['name']}',
                              // //  style: TextStyle(color: Colors.white)
                              //  ),
                              Text('Email: ${orderData['userEmail']}',
                              //  style: TextStyle(color: Colors.white)
                               ),
                              Text('Address: ${orderData['address']}',
                              //  style: TextStyle(color: Colors.white)
                               ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...items.map((item) {
                                return Text(
                                  '${item['name']} (Qty: ${item['quantity']})',
                                  // style: TextStyle(color: Colors.white),
                                );
                              }).toList(),
                              SizedBox(height: 4),
                              Text('Total Price: ${orderData['totalPrice']}',
                              //  style: TextStyle(color: Colors.white)
                               ),
                              Text('Ordered Time: ${timestamp.toLocal()}',
                              //  style: TextStyle(color: Colors.white)
                               ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
