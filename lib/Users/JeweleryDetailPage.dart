// ignore_for_file: file_names, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:jewellery_app/Users/UserDrawerData.dart'; 
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class JewelleryDetailPage extends StatefulWidget {
  final Map<String, dynamic> jewelleryData;

  const JewelleryDetailPage({super.key, required this.jewelleryData});

  @override
  State<JewelleryDetailPage> createState() => _JewelleryDetailPageState();
}

class _JewelleryDetailPageState extends State<JewelleryDetailPage> {
  int quantity = 1; 
  bool isLoading = false; 

  @override
  Widget build(BuildContext context) {
    // Price calculation
    double price = double.tryParse(widget.jewelleryData["price"].toString()) ?? 0.0;
    
    // Extract details
    String image = widget.jewelleryData['image'] ?? '';
    String name = widget.jewelleryData['name'] ?? 'Unknown Item';
    String description = widget.jewelleryData['description'] ?? 'No description available.';
    String color = widget.jewelleryData['color'] ?? 'N/A';
    String size = widget.jewelleryData['size'] ?? 'N/A';

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final sizeHeight = MediaQuery.of(context).size.height; // Height helper

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.5), 
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      drawer: Drawer(child: UDrawerdata()), 
      
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Top Area)
          // CHANGE: Height increased and BoxFit changed to contain
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: sizeHeight * 0.65, // Image ko 65% space di hai
            child: Hero(
              tag: image,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3), // Light background for contrast
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.contain, // ERROR FIX: 'contain' shows full image without cropping
                        errorBuilder: (context, error, stackTrace) => 
                            Container(color: theme.colorScheme.surfaceContainerHighest),
                      )
                    : Container(color: theme.colorScheme.surfaceContainerHighest),
              ),
            ),
          ),

          // 2. DRAGGABLE DETAILS SHEET (Replaces Positioned)
          // CHANGE: Added DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.45, // Sheet starts at 45% height (exposing image)
            minChildSize: 0.3,      // Can be dragged DOWN to 30% (to see full image)
            maxChildSize: 0.9,      // Can be dragged UP to 90% (to read details)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController, // Important: Connects scrolling to dragging
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Little Handle Bar
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 12, bottom: 20),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Name and Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Rs ${price.toStringAsFixed(0)}",
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Color & Size Chips
                      Row(
                        children: [
                          if (color != 'N/A')
                            _buildDetailChip(context, "Color", color),
                          if (size != 'N/A') ...[
                            SizedBox(width: 12),
                            _buildDetailChip(context, "Size", size),
                          ]
                        ],
                      ),
                      SizedBox(height: 24),

                      // Description Title
                      Text(
                        "Description",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Description Text
                      Text(
                        description,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 120), // Extra space for bottom bar
                    ],
                  ),
                ),
              );
            },
          ),

          // 3. BOTTOM FLOATING ACTION BAR
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 20),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) quantity--;
                            });
                          },
                        ),
                        Text(
                          "$quantity",
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 20),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15),

                  // Add To Cart Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => addToFirebaseCart(price, name, image),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading 
                        ? SizedBox(
                            height: 20, width: 20, 
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary, strokeWidth: 2
                            )
                          ) 
                        : Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Chips (Same as before)
  Widget _buildDetailChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  // Firebase Cart Function (Same as before)
  Future<void> addToFirebaseCart(double price, String name, String image) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Error", "You must be logged in to add items to cart.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Cart');

      QuerySnapshot existingItem = await cartRef
          .where('name', isEqualTo: name) 
          .limit(1)
          .get();

      if (existingItem.docs.isNotEmpty) {
        var doc = existingItem.docs.first;
        int currentQty = (doc['quantity'] ?? 0) as int;
        int newQty = currentQty + quantity;
        
        await doc.reference.update({
          'quantity': newQty,
          'totalPrice': newQty * price, 
        });
        
        Get.snackbar("Updated", "Item quantity updated in cart!", 
          snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(10));
      } else {
        await cartRef.add({
          'name': name,
          'image': image, 
          'price': price,
          'quantity': quantity,
          'totalPrice': price * quantity,
          'color': widget.jewelleryData['color'] ?? 'N/A', 
          'size': widget.jewelleryData['size'] ?? 'N/A',   
          'isChecked': false, 
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        Get.snackbar("Success", "Added to cart successfully!", 
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(10));
      }

    } catch (e) {
      Get.snackbar("Error", "Failed to add to cart: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}