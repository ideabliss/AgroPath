import 'package:agropath/consumer/viewproduct.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FertilizerScreen extends StatefulWidget {
  const FertilizerScreen({super.key});

  @override
  _FertilizerScreenState createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Fertilizers'),
        backgroundColor: const Color(0xFFA5DAA3),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        const SizedBox(height: 8),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search Fertilizers...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Fertilizer Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('crops') // Assuming 'crops' collection also contains fertilizers
                    .where('category', isEqualTo: 'Fertilizers') // Only fetch fertilizers
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  final fertilizers = snapshot.data!.docs.where((doc) {
                    final productData = doc.data() as Map<String, dynamic>;
                    final productName = productData['productName'].toString().toLowerCase();
                    return productName.contains(_searchQuery);
                  }).toList();

                  if (fertilizers.isEmpty) {
                    return Center(child: Text('No fertilizers found.'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.7,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fertilizers.length,
                    itemBuilder: (context, index) {
                      final data = fertilizers[index].data() as Map<String, dynamic>;
                      return FertilizerCard(data: data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class FertilizerCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const FertilizerCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the product detail screen using the productId
        final productId = data['productId'];
        if (productId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: productId),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                data['images'][0], // Assuming the first image is the main one
                height: 120.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    data['productName'],
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // Description (max 2 lines)
                  Text(
                    data['description'] ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  // Price (ensure it's in one line with ellipsis if overflow)
                  Text(
                    'Price: ₹${data['price']} (for 1kg)',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.green,
                    ),
                    maxLines: 1,  // Ensure only one line
                    overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
                  ),
                  const SizedBox(height: 1.0),
                  // Category
                  Text(
                    'Category: ${data['category']}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
