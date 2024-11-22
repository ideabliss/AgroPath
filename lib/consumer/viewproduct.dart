import 'package:agropath/consumer/checkout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    if (productId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFFA5DAA3),
        ),
        body: const Center(child: Text('Product ID is invalid or missing')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: const Color(0xFFA5DAA3),
      ),
      body: FutureBuilder<DocumentSnapshot>(  // Fetch product data
        future: FirebaseFirestore.instance.collection('crops').doc(productId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Product not found'));
          }

          final productData = snapshot.data!.data() as Map<String, dynamic>;
          final images = productData['images'] as List<dynamic>;
          final vendorId = productData['vendorId']; // Assume vendorId is stored in the product

          return FutureBuilder<DocumentSnapshot>(  // Fetch vendor data
            future: FirebaseFirestore.instance.collection('farmers').doc(vendorId).get(),
            builder: (context, vendorSnapshot) {
              if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vendorSnapshot.hasError) {
                return const Center(child: Text('Error fetching vendor details'));
              }

              if (!vendorSnapshot.hasData || !vendorSnapshot.data!.exists) {
                return const Center(child: Text('Vendor not found'));
              }

              final vendorData = vendorSnapshot.data!.data() as Map<String, dynamic>;
              final vendorName = vendorData['name'] ?? 'Unknown Vendor';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Product Images
                      if (images.isNotEmpty)
                        SizedBox(
                          height: 250.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                    images[index],
                                    width: 200.0,
                                    height: 250.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16.0),

                      // Product Name
                      Text(
                        productData['productName'] ?? 'No product name',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Description
                      Text(
                        productData['description'] ?? 'No description available.',
                        style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                      const SizedBox(height: 16.0),

                      // Sold by (Vendor) aligned to the right with icon
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront,
                            size: 18.0,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Sold by: $vendorName',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),

                      // Price and Contact
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${productData['price'] ?? '0.0'}',
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Contact: ${productData['contact'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Buttons: Add to Cart and Proceed to Buy
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: const Color(0xFFE8F5E9),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final consumerId = FirebaseAuth.instance.currentUser?.uid;
                                  if (consumerId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('You need to log in to add items to the cart.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    await FirebaseFirestore.instance.collection('cartItems').add({
                                      'productId': productId,
                                      'consumerId': consumerId,
                                      'productName': productData['productName'] ?? 'Unknown',
                                      'images': productData['images'] ?? [],
                                      'price': productData['price'] ?? 0.0,
                                      'vendorId': vendorId, // Add vendorId here
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${productData['productName']} added to cart!'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to add item to cart. Please try again.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text('Add to Cart'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA5DAA3),
                                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final consumerId = FirebaseAuth.instance.currentUser?.uid;
                                  if (consumerId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('You need to log in to proceed.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    final cartSnapshot = await FirebaseFirestore
                                        .instance
                                        .collection('cartItems')
                                        .where('consumerId', isEqualTo: consumerId)
                                        .get();

                                    final cartItems = cartSnapshot.docs;
                                    final totalAmount = cartItems.fold<double>(
                                      0.0,
                                      (sum, item) => sum + (item['price'] as double),
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CheckoutScreen(
                                          cartItems: cartItems,
                                          totalAmount: totalAmount,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to proceed please add a item in cart and proceed from cart screen.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.payment),
                                label: const Text('Buy Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
