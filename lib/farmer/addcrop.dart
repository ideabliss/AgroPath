import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Addcrop extends StatefulWidget {
  const Addcrop({super.key});

  @override
  State<Addcrop> createState() => _AddcropState();
}

class _AddcropState extends State<Addcrop> {
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedUnit = 'kg';
  String _selectedCategory = 'Fruits';
  List<File> _imageFiles = [];
  final picker = ImagePicker();

  String? username;
  String? userEmail;
  String? userId;

  // Quotes and index for the current quote
  final List<String> _quotes = [
    "The farmer is the backbone of the world economy.",
    "Farming is not just a job; it's a way of life.",
    "To plant a seed is to believe in tomorrow.",
    "Farmers feed the world one crop at a time.",
    "Without farmers, there’s no food on the table."
  ];
  int _currentQuoteIndex = 0;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _startQuoteTimer();
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  void _startQuoteTimer() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      });
    });
  }

  void _changeQuoteManually() {
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
    });
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        username = user.displayName;
        userEmail = user.email;
        userId = user.uid;
      });
    }
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    for (File image in images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('crops/$fileName');
      await ref.putFile(image);
      String downloadURL = await ref.getDownloadURL();
      imageUrls.add(downloadURL);
    }
    return imageUrls;
  }

  Future<void> _addCrop() async {
    setState(() {
      // Show loading indicator
    });

    if (_imageFiles.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 4 images.')),
      );
      setState(() {
        // Hide loading indicator
      });
      return;
    }

    int? price = (double.tryParse(_priceController.text)! * 1).toInt();
    int? quantity = int.tryParse(_quantityController.text);

    if (quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid price and quantity.')),
      );
      setState(() {
        // Hide loading indicator
      });
      return;
    }

    if (_productNameController.text.isEmpty ||
        _productDescriptionController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      setState(() {
        // Hide loading indicator
      });
      return;
    }

    List<String> imageUrls = await _uploadImages(_imageFiles);

    try {
      DocumentReference cropRef = await FirebaseFirestore.instance.collection('crops').add({
        'productName': _productNameController.text,
        'description': _productDescriptionController.text,
        'quantity': _quantityController.text,
        'unit': _selectedUnit,
        'category': _selectedCategory,
        'price': price,
        'contact': _contactController.text,
        'images': imageUrls,
        'createdAt': Timestamp.now(),
        'uploadedBy': {
          'username': username,
          'email': userEmail,
          'userId': userId,
        },
        'vendorId': userId,
      });

      await cropRef.update({
        'productId': cropRef.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crop added successfully!')),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add crop: $e')),
      );
    } finally {
      setState(() {
        // Hide loading indicator
      });
    }
  }

  void _clearForm() {
    _productNameController.clear();
    _productDescriptionController.clear();
    _quantityController.clear();
    _priceController.clear();
    _contactController.clear();
    setState(() {
      _imageFiles = [];
    });
  }

  Future<void> _pickImage() async {
    final pickedFiles = await picker.pickMultiImage();
    setState(() {
      _imageFiles = pickedFiles.map((file) => File(file.path)).toList();
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: const Color(0xFFA5DAA3),
      elevation: 0,
      title: const Text(
        'Add Crop',
        style: TextStyle(
          fontFamily: 'ProtestStrike',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3E5B3D),
        ),
      ),
    ),

    body: Padding(
      padding: const EdgeInsets.only(top: 50.0), // Reduced top padding
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Quote Widget with reduced top margin
            Container(
              margin: const EdgeInsets.only(top: 0.0, bottom: 8.0, left: 8.0, right: 8.0), // Adjusted top margin to 0.0
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentQuoteIndex = (_currentQuoteIndex - 1 + _quotes.length) % _quotes.length;
                      });
                    },
                    icon: const Icon(Icons.arrow_left),
                  ),
                  Expanded(
                    child: Text(
                      _quotes[_currentQuoteIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto', // Updated to Roboto
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _changeQuoteManually,
                    icon: const Icon(Icons.arrow_right),
                  ),
                ],
              ),
            ),
                      const SizedBox(height: 20),


              // Form Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
              children: [
                      TextField(
                        controller: _productNameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFA5DAA3),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: ['Fruits', 'Vegetables', 'Grains', 'Flowers', 'Fertilizers', 'Others']
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Product Categories',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFA5DAA3),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _productDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Product Description',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFA5DAA3),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                                fillColor: Color(0xFFA5DAA3),
                                filled: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              items: ['gm', 'kg', 'quintal', 'ton', 'hectare']
                                  .map((unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value!;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                                fillColor: Color(0xFFA5DAA3),
                                filled: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Set Product Price for 1kg',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFA5DAA3),
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact No',
                          border: OutlineInputBorder(),
                          fillColor: Color(0xFFA5DAA3),
                          filled: true,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFA5DAA3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Upload Photos'),
                          ),
                          const Text('(Min 4 photos)'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _imageFiles.map((image) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addCrop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFA5DAA3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Add Crop'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
