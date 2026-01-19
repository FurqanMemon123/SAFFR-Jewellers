// // ignore_for_file: file_names, prefer_const_constructors, curly_braces_in_flow_control_structures, use_key_in_widget_constructors, non_constant_identifier_names

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:food_app/Admin/AdminConversationRoom.dart';

// class UserListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'User List',
//           // style: TextStyle(color: Colors.transparent),
//         ),
//         iconTheme: IconThemeData(
//           // color: Colors.transparent,
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('Users').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData)
//             return Center(child: CircularProgressIndicator());

//           final Users = snapshot.data!.docs;

//           return ListView.builder(
//             shrinkWrap: true,
//             itemCount: Users.length,
//             itemBuilder: (context, index) {
//               final user = Users[index];
//               final userId = user.id; // Assuming user ID is the document ID
//               final userName = user['name']; // Fetch the user name directly

//               return Column(
//                 children: [
//                   ListTile(
//                     title: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           userName,
//                         ),
//                         Text(
//                           user['Email'],
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AdminConversationScreen(
//                             userId: userId,
//                             userName: userName, // Pass the correct userName
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   Divider(
//                     thickness: 1,
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewellery_app/Admin/AdminConversationRoom.dart';
import 'package:jewellery_app/Admin/DrawerData.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Drawerdata(),
      ),
      appBar: AppBar(
        title: Text('User List',

        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id; // User ID from document ID
              final userData = user.data() as Map<String, dynamic>; // Get user data as a map

              // Check if fields exist and assign default values if they don't
              final userName = userData.containsKey('name') ? userData['name'] : 'No name';
              final userEmail = userData.containsKey('Email') ? userData['Email'] : 'No email';
              final UserImage = userData.containsKey('image') ? userData['image'] : 'No image';

              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(UserImage),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName),
                        Text(userEmail),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminConversationScreen(
                            userId: userId,
                            userName: userName,
                            UserImage: UserImage, // Pass the correct userImage

                          ),
                        ),
                      );
                    },
                  ),
                  Divider(thickness: 1),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
