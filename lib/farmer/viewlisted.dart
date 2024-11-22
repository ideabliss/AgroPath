import 'package:agropath/farmer/crop_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyListedCropsScreen extends StatefulWidget {
  const MyListedCropsScreen({super.key});

  @override
  _MyListedCropsScreenState createState() => _MyListedCropsScreenState();
}

class _MyListedCropsScreenState extends State<MyListedCropsScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Fruits', 'Vegetables', 'Grains', 'Flowers', 'Fertilizer', 'Others'];
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> confirmDeleteCrop(String cropId) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: const Text('Are you sure you want to delete this crop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await FirebaseFirestore.instance.collection('crops').doc(cropId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crop deleted successfully')),
      );
    }
  }

  void showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              return ListTile(
                title: Text(category),
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listed Crops'),
        backgroundColor: const Color(0xFFA5DAA3), // Set app bar color to A5DAA3
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: Column(
        children: [
          // Search Bar and Filter Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search',
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: showCategoryFilterDialog,
                ),
              ],
            ),
          ),

          // Crop List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('crops')
                  .where('uploadedBy.userId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No crops listed.'));
                }

                // Filter crops based on search query and selected category
                final crops = snapshot.data!.docs.where((doc) {
                  final productName = doc['productName'].toString().toLowerCase();
                  final category = doc['category'].toString();
                  final matchesSearch = productName.contains(searchQuery);
                  final matchesCategory = selectedCategory == 'All' || category == selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (crops.isEmpty) {
                  return const Center(child: Text('No matching crops found.'));
                }

                return ListView.builder(
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    final crop = crops[index];
                    return Card(
                      color: Colors.white, // Set crop card background color to white
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: const Color(0xFFA5DAA3), width: 2), // Border color A5DAA3
                      ),
                      child: ListTile(
                        leading: crop['images'] != null && crop['images'].isNotEmpty
                            ? Image.network(crop['images'][0], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 50, color: Colors.grey),
                        title: Text(crop['productName']),
                        subtitle: Text('Category: ${crop['category']}\nPrice: ${crop['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${crop['quantity']} ${crop['unit']}'),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDeleteCrop(crop.id),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to the CropDetailScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CropDetailScreen(cropId: crop.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
