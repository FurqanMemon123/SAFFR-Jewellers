// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, non_constant_identifier_names, unused_field, unnecessary_string_interpolations, sized_box_for_whitespace, avoid_print, file_names, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jewellery_app/Admin/DrawerData.dart'; // Ensure this path is correct
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Adddishes extends StatefulWidget {
  const Adddishes({super.key});

  @override
  State<Adddishes> createState() => _AdddishesState();
}

class _AdddishesState extends State<Adddishes> {
  var downloadLink = "";
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  var nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  
  // Dropdown Variables
  String? selectedGender; // Man, Woman
  String? selectedType; // Ring, Necklace, etc.
  String? selectedColor; // Gold, Silver, Other
  String? currentDocId; // To handle updates

  // Lists for Dropdowns
  final List<String> genderList = ['Man', 'Woman'];
  final List<String> typeList = ['Ring', 'Necklace', 'Bangle', 'Earrings']; 
  final List<String> colorList = ['Gold', 'Silver', 'Other']; 

  // Placeholder Image
  final String placeholderImage = "https://cdn-icons-png.flaticon.com/512/610/610365.png"; 

  void imagesource() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: 150,
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: Text("Camera"),
                  leading: Icon(Icons.camera),
                  onTap: () {
                    pickimage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () {
                    pickimage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickimage(ImageSource source) async {
    final PickedFile = await _picker.pickImage(source: source);
    if (PickedFile != null) {
      setState(() {
        _image = File(PickedFile.path);
      });
    }
  }

  Future<void> imagestorestorage() async {
    if (_image == null) return;

    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageref = storage
          .ref()
          .child("Jewellery/${selectedType ?? 'Others'}/${DateTime.now().millisecondsSinceEpoch}");
      
      UploadTask uploadTask = storageref.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      downloadLink = await snapshot.ref.getDownloadURL();
      print("Download URL: $downloadLink");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> uploadData() async {
    // Validation
    if (nameController.text.isEmpty ||
        selectedGender == null ||
        selectedType == null ||
        selectedColor == null ||
        priceController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields");
      return;
    }

    if (_image != null) {
      await imagestorestorage();
    } else if (downloadLink.isEmpty) {
      Get.snackbar("Error", "Please select an image");
      return;
    }

    // Prepare Data Object
    var dataObj = {
      "name": nameController.text,
      "price": priceController.text,
      "description": descController.text,
      "size": sizeController.text,
      "gender": selectedGender,
      "type": selectedType,
      "color": selectedColor, 
      "image": downloadLink,
      "status": true,
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      // Path: Category -> [Gender] -> [Type] -> [DocID]
      CollectionReference targetCollection = FirebaseFirestore.instance
          .collection('Category')
          .doc(selectedGender)
          .collection(selectedType!);

      if (currentDocId == null) {
        DocumentReference docRef = await targetCollection.add(dataObj);
        await docRef.update({"id": docRef.id});
        Get.snackbar("Success", "Item Added to ${selectedGender} > ${selectedType}");
      } else {
        await targetCollection.doc(currentDocId).update(dataObj);
        Get.snackbar("Success", "Item Updated");
      }

      // We call clearForm here, but modified it to keep the dropdown selection
      clearForm(keepSelection: true); 

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // MODIFIED CLEAR FORM
  void clearForm({bool keepSelection = false}) {
    setState(() {
      nameController.clear();
      priceController.clear();
      descController.clear();
      sizeController.clear();
      
      // We do NOT clear Gender or Type if keepSelection is true
      // This ensures the list stays visible after adding an item
      if (!keepSelection) {
        selectedGender = null;
        selectedType = null;
      }
      
      selectedColor = null;
      _image = null;
      downloadLink = "";
      currentDocId = null;
    });
  }

  // Helper widget for TextFields
  Widget buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.orange),
          ),
          labelText: label,
          alignLabelWithHint: maxLines > 1, 
          suffixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey) : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  // Helper widget for Dropdowns
  Widget buildDropdown(String label, List<String> items, String? currentValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(50),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(label),
            value: currentValue,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Jewellery"),
        actions: [
          // Button to completely clear form and selection
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => clearForm(keepSelection: false),
            tooltip: "Reset Form",
          )
        ],
      ),
      drawer: Drawer(child: Drawerdata()),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 10),
            // Image Picker
            GestureDetector(
              onTap: imagesource,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: downloadLink.isNotEmpty
                    ? NetworkImage(downloadLink)
                    : (_image == null
                        ? NetworkImage(placeholderImage)
                        : FileImage(_image!) as ImageProvider),
              ),
            ),
            SizedBox(height: 20),

            // --- INPUT FIELDS ---
            buildTextField(nameController, "Item Name", Icons.label),
            
            // Gender & Type Row
            Row(
              children: [
                Expanded(
                  child: buildDropdown("Gender", genderList, selectedGender, (val) {
                    setState(() => selectedGender = val);
                  }),
                ),
                Expanded(
                  child: buildDropdown("Category", typeList, selectedType, (val) {
                    setState(() => selectedType = val);
                  }),
                ),
              ],
            ),

            buildTextField(priceController, "Price (PKR)", Icons.attach_money, type: TextInputType.number),
            
            buildTextField(descController, "Description", Icons.description, maxLines: 4),
            
            Row(
              children: [
                Expanded(child: buildTextField(sizeController, "Size", Icons.straighten)),
                Expanded(
                  child: buildDropdown("Color", colorList, selectedColor, (val) {
                    setState(() => selectedColor = val);
                  }),
                ),
              ],
            ),

            SizedBox(height: 20),
            
            // Submit Button
            Container(
              width: MediaQuery.of(context).size.width * 0.90,
              height: 50,
              child: ElevatedButton(
                onPressed: uploadData,
                child: Text(
                  currentDocId == null ? "Add Item" : "Update Item",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),

            SizedBox(height: 20),
            Divider(thickness: 2),
            
            // --- DISPLAY LIST ---
            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (selectedGender != null && selectedType != null) 
                        ? "$selectedGender's $selectedType" 
                        : "Select Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if(selectedGender != null && selectedType != null)
                    Text("Live Preview", style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            
            SizedBox(height: 10),

            // STREAM BUILDER
            // Logic: Shows list only if dropdowns are selected
            if (selectedGender != null && selectedType != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Category')
                    .doc(selectedGender)
                    .collection(selectedType!)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading data"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('No items found in $selectedGender > $selectedType.'),
                    );
                  }

                  final items = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final data = items[index].data() as Map<String, dynamic>;
                      final docId = items[index].id;

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(data['image'] ?? placeholderImage),
                              ),
                            ),
                          ),
                          title: Text(data['name'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("PKR ${data['price']}", style: TextStyle(color: Colors.green[700])),
                              Text("Color: ${data['color'] ?? 'N/A'} | Size: ${data['size'] ?? 'N/A'}", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    currentDocId = docId;
                                    nameController.text = data['name'];
                                    priceController.text = data['price'];
                                    descController.text = data['description'] ?? "";
                                    sizeController.text = data['size'] ?? "";
                                    
                                    // Populate Dropdowns
                                    selectedGender = data['gender'];
                                    selectedType = data['type'];
                                    selectedColor = data['color'];
                                    
                                    downloadLink = data['image'];
                                    _image = null;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Delete Item?"),
                                      content: Text("Are you sure you want to delete this item?"),
                                      actions: [
                                        TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context, false)),
                                        TextButton(child: Text("Delete"), onPressed: () => Navigator.pop(context, true)),
                                      ],
                                    ),
                                  ) ?? false;

                                  if (confirm) {
                                    await FirebaseFirestore.instance
                                        .collection('Category')
                                        .doc(selectedGender)
                                        .collection(selectedType!)
                                        .doc(docId)
                                        .delete();
                                    Get.snackbar("Deleted", "Item removed successfully");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            else 
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    Icon(Icons.touch_app, size: 50, color: Colors.grey),
                    Text("Select Gender & Category to view list", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}