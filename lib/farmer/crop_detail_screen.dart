import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CropDetailScreen extends StatefulWidget {
  final String cropId;

  const CropDetailScreen({super.key, required this.cropId});

  @override
  _CropDetailScreenState createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  int _currentImageIndex = 0; // Track the current selected image
  final PageController _pageController = PageController();

  Future<void> confirmDeleteCrop(BuildContext context, String cropId) async {
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
      Navigator.pop(context); // Go back after deleting
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Details'),
        backgroundColor: const Color(0xFFA5DAA3),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('crops').doc(widget.cropId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Crop not found.'));
          }

          final crop = snapshot.data!;
          final images = List<String>.from(crop['images'] ?? []);

          // Check if images list is empty
          if (images.isEmpty) {
            return const Center(child: Text('No images available.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  crop['productName'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Image Carousel with PageView (display 4 images at once)
                SizedBox(
                  height: 250, // Set a height for the image carousel
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: (images.length / 4).ceil(), // Show groups of 4 images
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      // Calculate the index of images to show in each page
                      int startIndex = index * 4;
                      int endIndex = startIndex + 4;
                      List<String> pageImages = images.sublist(
                        startIndex, 
                        endIndex > images.length ? images.length : endIndex
                      );

                      return Row(
                        children: pageImages.map((imageUrl) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover, // Ensures full image display
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Dots indicating number of images, clicking on dot changes image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate((images.length / 4).ceil(), (index) {
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? const Color(0xFFA5DAA3) // Selected dot color
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  'Description: ${crop['description'] ?? 'No description available'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                // Price with Rupees symbol
                Text(
                  'Price: ₹${crop['price']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50), // Green color for price
                  ),
                ),
                const SizedBox(height: 8),
                // Category and Quantity
                Text(
                  'Category: ${crop['category']}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quantity: ${crop['quantity']} ${crop['unit']}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // Action Buttons (Add More Crops and Delete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Add more crop functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA5DAA3),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Add More Crops',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => confirmDeleteCrop(context, crop.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Delete Crop',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
