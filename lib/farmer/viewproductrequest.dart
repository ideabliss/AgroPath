import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewPurchasedRequestScreen extends StatefulWidget {
  const ViewPurchasedRequestScreen({super.key});

  @override
  _ViewPurchasedRequestScreenState createState() =>
      _ViewPurchasedRequestScreenState();
}

class _ViewPurchasedRequestScreenState
    extends State<ViewPurchasedRequestScreen> {
  final String? vendorId = FirebaseAuth.instance.currentUser?.uid;

  // Fetch orders placed for the vendor's products
  Future<List<DocumentSnapshot>> _getOrders() async {
    try {
      if (vendorId == null) {
        return [];
      }

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      return ordersSnapshot.docs;
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }

  // Function to approve an order
  Future<void> _approveOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'orderStatus': 'In Progress',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated to In Progress')),
      );
    } catch (e) {
      print("Error updating order status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status')),
      );
    }
  }

  // Fetch address details from the order
  Widget _buildAddress(Map<String, dynamic> address) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // Increase width (90% of screen width)
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Recipient: ${address['recipientName']}'),
            Text('Contact: ${address['contact']}'),
            Text('Building: ${address['buildingName']}'),
            Text('City/State/Zip: ${address['cityStateZip']}'),
            Text('Country: ${address['country']}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Purchased Requests'),
        backgroundColor: const Color.fromARGB(255, 188, 233, 187),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final orderItems = order['orderItems'] as List;
              final totalAmount = order['totalAmount'];
              final orderStatus = order['orderStatus'];
              final address = order['address']; // Assuming address is stored in the order

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Title
                      Text(
                        'Order #$orderId',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Address Display
                      _buildAddress(address),
                      const SizedBox(height: 16),
                      // Order Items List
                      const Text(
                        'Order Items:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...orderItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '${item['productName']} - ${item['quantity']} kg',
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      // Total Amount & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount: ₹${totalAmount.toString()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: $orderStatus',
                            style: TextStyle(
                              fontSize: 16,
                              color: orderStatus == 'Pending'
                                  ? Colors.orange
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Approve Button (Only if Pending)
                      orderStatus == 'Pending'
                          ? ElevatedButton(
                              onPressed: () => _approveOrder(orderId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text('Approve Order'),
                            )
                          : const SizedBox.shrink(),
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
