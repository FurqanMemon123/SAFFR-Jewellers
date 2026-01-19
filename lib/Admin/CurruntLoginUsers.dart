// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewellery_app/Admin/DrawerData.dart';

class UserLoggedinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logged-In Users'),
      ),
      drawer: Drawer(
        child: Drawerdata(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('isLoggedIn', isEqualTo: true) // Filter for logged-in users
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return Center(child: Text('No logged-in users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>; // Get user data as a map
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData['image'] ?? ''),
                    radius: 25,
                  ),
                  title: Text(userData['name'] ?? 'No name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${userData['Email'] ?? 'No email'}'),
                      // Text('Last Sign In: ${userData['lastSignIn']?.toDate().toString() ?? 'No date'}'),
                      Text("Login Status: ${userData['isLoggedIn']?? 'No Login Status'}"),
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

