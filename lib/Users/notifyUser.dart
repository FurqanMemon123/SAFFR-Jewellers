// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:jewellery_app/Users/UserDrawerData.dart';

class OrderStatus extends StatefulWidget {
  final String userId;
  const OrderStatus({required this.userId, Key? key}) : super(key: key);

  @override
  State<OrderStatus> createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  
  // Status Colors Helper
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'out for delivery': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'declined': return Colors.red;
      case 'cancelled by user': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.access_time;
      case 'accepted': return Icons.thumb_up;
      case 'out for delivery': return Icons.delivery_dining;
      case 'delivered': return Icons.check_circle;
      case 'declined': return Icons.cancel;
      case 'cancelled by user': return Icons.cancel;
      default: return Icons.info;
    }
  }

  // ✅ Function to Cancel Order (Pending -> Declined)
  Future<void> cancelOrder(DocumentSnapshot doc) async {
    try {
      Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
      orderData['status'] = 'Cancelled by User';
      
      await FirebaseFirestore.instance.collection('DeclinedOrders').doc(doc.id).set(orderData);
      await FirebaseFirestore.instance.collection('Orders').doc(doc.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order cancelled"), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ✅ Function to PERMANENTLY Delete Order (History Cleaning)
  Future<void> deleteOrderHistory(DocumentSnapshot doc) async {
    try {
      // Doc reference se direct delete karega (chahay wo Delivered me ho ya Declined me)
      await doc.reference.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Removed from history"), backgroundColor: Colors.grey),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Stream<List<DocumentSnapshot>> getCombinedOrdersStream() {
    var ordersStream = FirebaseFirestore.instance.collection('Orders').where('userId', isEqualTo: widget.userId).snapshots();
    var deliveredStream = FirebaseFirestore.instance.collection('DeliveredOrders').where('userId', isEqualTo: widget.userId).snapshots();
    var declinedStream = FirebaseFirestore.instance.collection('DeclinedOrders').where('userId', isEqualTo: widget.userId).snapshots();

    return Rx.combineLatest3(ordersStream, deliveredStream, declinedStream, (orders, delivered, declined) {
        List<DocumentSnapshot> allOrders = [];
        allOrders.addAll(orders.docs);
        allOrders.addAll(delivered.docs);
        allOrders.addAll(declined.docs);

        allOrders.sort((a, b) {
          Timestamp t1 = (a.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
          Timestamp t2 = (b.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
          return t2.compareTo(t1);
        });
        return allOrders;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders'), centerTitle: true),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: getCombinedOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No order history found.', style: TextStyle(color: Colors.grey, fontSize: 18)));
          }

          var allOrders = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: allOrders.length,
            itemBuilder: (context, index) {
              var orderDoc = allOrders[index];
              var orderData = orderDoc.data() as Map<String, dynamic>;
              
              String status = orderData['status'] ?? 
                              (orderDoc.reference.parent.id == 'DeliveredOrders' ? 'Delivered' : 
                               orderDoc.reference.parent.id == 'DeclinedOrders' ? 'Declined' : 'Pending');
              
              // Status ko lowercase me convert kar rahay hain comparison ke liye
              String statusKey = status.toLowerCase();

              double totalPrice = double.tryParse(orderData['totalPrice'].toString()) ?? 0.0;
              List<dynamic> items = orderData['items'] ?? [];
              Timestamp? timestamp = orderData['timestamp'];
              String dateStr = timestamp != null ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate()) : 'Date unknown';

              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order Date:", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          Text(dateStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Divider(),
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text("${item['quantity']}x ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            Expanded(child: Text(item['name'] ?? 'Item', overflow: TextOverflow.ellipsis)),
                            Text("Rs ${item['totalPrice']}", style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      )).toList(),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: getStatusColor(status)),
                            ),
                            child: Row(
                              children: [
                                Icon(getStatusIcon(status), size: 16, color: getStatusColor(status)),
                                SizedBox(width: 5),
                                Text(status.toUpperCase(), style: TextStyle(color: getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text("Rs ${totalPrice.toStringAsFixed(0)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      // ✅ LOGIC FOR BUTTONS

                      // CASE 1: Pending Order -> Show CANCEL Button
                      if (statusKey == 'pending') ...[
                        SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Cancel Order?"),
                                content: Text("Are you sure you want to cancel this order?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("No")),
                                  TextButton(onPressed: () { Navigator.of(ctx).pop(); cancelOrder(orderDoc); }, child: Text("Yes, Cancel", style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            ),
                            icon: Icon(Icons.cancel_outlined, color: Colors.red),
                            label: Text("Cancel Order", style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ]
                      
                      // CASE 2: Finished Orders (Delivered/Declined/Cancelled) -> Show DELETE Button
                      else if (statusKey == 'delivered' || statusKey == 'declined' || statusKey == 'cancelled by user') ...[
                        SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Delete History?"),
                                content: Text("This will permanently remove this order from your history."),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Cancel")),
                                  TextButton(onPressed: () { Navigator.of(ctx).pop(); deleteOrderHistory(orderDoc); }, child: Text("Delete", style: TextStyle(color: Colors.blue))),
                                ],
                              ),
                            ),
                            icon: Icon(Icons.delete_outline, color: Colors.grey),
                            label: Text("Remove from History", style: TextStyle(color: Colors.grey[700])),
                          ),
                        ),
                      ],

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}