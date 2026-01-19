// ignore_for_file: file_names, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class WhatsappNavBar extends StatefulWidget {
  const WhatsappNavBar({super.key});

  @override
  State<WhatsappNavBar> createState() => _WhatsappNavBarState();
}

class _WhatsappNavBarState extends State<WhatsappNavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(items:[
      
      ] ),
    );
  }
}