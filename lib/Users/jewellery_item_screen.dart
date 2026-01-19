import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JawelleryItemScreen extends StatefulWidget {
  const JawelleryItemScreen({super.key});

  @override
  State<JawelleryItemScreen> createState() => _JawelleryItemScreenState();
}

class _JawelleryItemScreenState extends State<JawelleryItemScreen> {
  String? selectedCategory = 'Rings';

  Widget categorySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        categoryButton('Rings', 'assets/images/diamond-ring-icon-png.png'),
        categoryButton('Earrings', 'assets/images/err.png'),
        categoryButton('Necklace', 'assets/images/naclace.png'),
        categoryButton('Bangles', 'assets/images/bangles.png'),
      ],
    );
  }

  Widget categoryButton(String category, String imageUrl) {
    bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            imageUrl,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // 🔹 Function to fetch items from Firebase (based on selected collection)
  Stream<QuerySnapshot> getJewelleryItems() {
    if (selectedCategory == null) {
      // Show empty stream (nothing selected yet)
      return FirebaseFirestore.instance.collection('Rings').snapshots();
    } else {
      // Dynamically choose the selected collection
      return FirebaseFirestore.instance
          .collection(selectedCategory!)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Beautiful Jewellery',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                'for you',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              categorySelector(),
              const SizedBox(height: 20),

              // 🔹 Firestore StreamBuilder
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getJewelleryItems(),
                  builder: (context, snapshot) {
                    if (selectedCategory == null) {
                      return const Center(
                        child: Text(
                          'Select a category to view items',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No items found'));
                    }

                    var items = snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        var item = items[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item['Image'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,

                                      // 🔹 Loader when image is loading
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return SizedBox(
                                          height: 120,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                        );
                                      },

                                      // 🔹 Error icon if image fails
                                      errorBuilder: (context, error, stackTrace) {
                                        return const SizedBox(
                                          height: 120,
                                          child: Center(
                                            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['Name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "PKR ${item['Price']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
}
