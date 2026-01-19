// ignore_for_file: file_names, prefer_const_constructors, curly_braces_in_flow_control_structures, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminConversationScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String UserImage;
  AdminConversationScreen({required this.userId, required this.userName, required this.UserImage});

  @override
  _AdminConversationScreenState createState() =>
      _AdminConversationScreenState();
}

class _AdminConversationScreenState extends State<AdminConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages_${widget.userId}').add({
        'text': _messageController.text,
        'sender': 'admin',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.UserImage),
            ),
            Text(
              ' ${widget.userName}',
              style: GoogleFonts.aBeeZee(
                fontSize: 20,
                // fontWeight: FontWeight.bold,
              )
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages_${widget.userId}')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                });
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index]['text'];
                    final sender = messages[index]['sender'];

                    return Align(
                      alignment: sender == 'admin'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: sender == 'admin'
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                              color: sender == 'admin'
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.red,
                    // style: TextStyle(color: Colors.white),
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      hintStyle:
                          TextStyle(color: Colors.white, fontSize: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.red),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
