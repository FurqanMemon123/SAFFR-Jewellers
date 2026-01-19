// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:food_app/Admin/DrawerData.dart';

// class Userslist extends StatefulWidget {
//   const Userslist({super.key});

//   @override
//   State<Userslist> createState() => _UserslistState();
// }

// class _UserslistState extends State<Userslist> {
//   final CollectionReference usersCollection =
//       FirebaseFirestore.instance.collection('Users');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'User Logged In List',
//         ),
//       ),
//       drawer: Drawer(
//         child: Drawerdata(),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: usersCollection.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No users found.'));
//           }
//           final admin = snapshot.data!.docs;
//           return ListView.builder(
//             shrinkWrap: true,
//             itemCount: admin.length,
//             itemBuilder: (context, index) {
//               final userData = admin[index].data() as Map<String, dynamic>;

//               // Using conditional operators to handle potential null values
//               final imageUrl = userData['image'] ?? ''; // Default to empty string
//               final name = userData['name'] ?? 'No name'; // Default to 'No name'
//               final email = userData['Email'] ?? 'No email'; // Default to 'No email'

//               return Card(
//                 color: const Color.fromARGB(255, 78, 0, 0),
//                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: imageUrl.isNotEmpty
//                         ? NetworkImage(imageUrl)
//                         : null, // Set to null if no image URL
//                     radius: 25,
//                   ),
//                   title: Text(name),
//                   subtitle: Text(email),
//                   trailing: IconButton(
//                     onPressed: () {},
//                     icon: Icon(Icons.block),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jewellery_app/Admin/DrawerData.dart';

class Userslist extends StatefulWidget {
  const Userslist({super.key});

  @override
  State<Userslist> createState() => _UserslistState();
}

class _UserslistState extends State<Userslist> {
  TextEditingController _search = TextEditingController();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<void> toggleBlockUser(String userId, bool isBlocked) async {
    try {
      await usersCollection.doc(userId).update({
        'isBlocked': !isBlocked,
      });
      // Optionally, show a snackbar or a dialog to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBlocked ? 'User Unblocked' : 'User Blocked',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 133, 18, 9),
        ),
      );
    } catch (e) {
      print("Error updating user status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user status.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        title: Text('User Logged In List'),
      ),
      drawer: Drawer(
        child: Drawerdata(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }
          final admin = snapshot.data!.docs;
          return ListView.builder(
            itemCount: admin.length,
            itemBuilder: (context, index) {
              final userData = admin[index].data() as Map<String, dynamic>;
              final userId = admin[index].id;
              final isBlocked =
                  userData['isBlocked'] ?? false; // Default to false if not set

              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userData['image'] != null
                          ? NetworkImage(userData['image'])
                          : null,
                      radius: 25,
                    ),
                    title: Text(userData['name'] ?? 'No name'),
                    subtitle: Text(userData['Email'] ?? 'No email'),
                    // trailing: TextButton(
                    //   child: Text(isBlocked ? 'Unblock' : 'Block'),
                    //   // icon: Icon(isBlocked ? Icons.check : Icons.block),
                    //   onPressed: () => toggleBlockUser(userId, isBlocked),
                    // ),
                  ),
                  Divider(), // Add a divider between each user list item
                ],
              );
            },
          );
        },
      ),
    );
  }
}
