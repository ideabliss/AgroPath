import 'package:agropath/consumer/savedaddress.dart'; // Assuming this screen exists for updating address
import 'package:agropath/consumer/trackorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class CheckoutScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Fetch the user's saved address
  Future<Map<String, dynamic>?> _getUserAddress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return null; // Return null if user is not authenticated
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('consumers').doc(userId).get();
      if (userDoc.exists) {
        // Return the address field inside the user document
        return userDoc.data()?['address']; // Assuming 'address' field exists
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching address: $e');
      return null;
    }
  }

  // Function to place an order
  Future<void> _placeOrder(Map<String, dynamic> address) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to place an order.')),
      );
      return;
    }

    try {
      List<Map<String, dynamic>> orderItems = [];
      String? vendorId;

      // Loop through cart items and get the vendorId from each product
      for (var cartItem in widget.cartItems) {
        final data = cartItem.data() as Map<String, dynamic>;
        vendorId = data['vendorId']; // Fetch vendorId from product data
        
        orderItems.add({
          'productName': data['productName'],
          'quantity': data['quantity'],
          'price': data['price'],
        });
      }

      // Prepare the order data
      final orderData = {
        'userId': userId,
        'orderItems': orderItems,
        'totalAmount': widget.totalAmount,
        'orderStatus': 'Pending',
        'orderDate': FieldValue.serverTimestamp(),
        'address': address,
        'vendorId': vendorId,  // Store the vendorId in the order
      };

      // Save the order in Firestore
      final orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your order has been placed!')),
      );

      // Navigate to the Track Order screen after placing the order
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrackOrderScreen(),
        ),
      );
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color.fromARGB(255, 188, 233, 187),  // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<Map<String, dynamic>?>(  // Fetch user address
          future: _getUserAddress(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No address found.'));
            }

            final address = snapshot.data!;

            return Column(
              children: [
                // Display the user's address with increased width
                Container(
                  width: double.infinity, // Full width
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Recipient Name: ${address['recipientName'] ?? 'No recipient name'}'),
                      Text('Contact: ${address['contact'] ?? 'No contact'}'),
                      Text('Building Name: ${address['buildingName'] ?? 'No building name'}'),
                      Text('City, State, Zip: ${address['cityStateZip'] ?? 'No city/state/zip'}'),
                      Text('Country: ${address['country'] ?? 'No country'}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Navigate to the Update Address screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SaveAddressesScreen(addressId: null),
                      ),
                    );
                  },
                  child: const Text(
                    'Update Address',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = widget.cartItems[index];
                      final data = cartItem.data() as Map<String, dynamic>;
                      final quantity = data['quantity'] ?? 1;
                      final price = double.tryParse(data['price'].toString()) ?? 0.0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: data['images'] != null && data['images'].isNotEmpty
                              ? Image.network(
                                  data['images'][0],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported, size: 50),
                          title: Text(
                            data['productName'] ?? 'Unknown Product',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '₹${price.toStringAsFixed(2)} x $quantity kg',
                          ),
                          trailing: Text(
                            '₹${(price * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Display total amount
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${widget.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                // Cash on delivery message
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Payment Method: Cash on Delivery (COD) is available',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                // Checkout button with the same color as the AppBar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _placeOrder(address),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color.fromARGB(255, 188, 233, 187), // AppBar color
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Place order when clicked
                    child: const Text('Place your order'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
