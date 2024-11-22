import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  Future<List<Map<String, dynamic>>> _getUserOrders() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return []; // Return empty list if user is not authenticated
    }

    try {
      // Get all orders for the current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      final orders = querySnapshot.docs.map((doc) => doc.data()).toList();
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Orders'),
        backgroundColor: const Color.fromARGB(255, 188, 233, 187),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getUserOrders(),
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
                final order = orders[index];
                final orderId = order['orderId'] ?? 'N/A';
                final orderItems = order['orderItems'] ?? [];
                final totalAmount = order['totalAmount'] ?? 0.0;
                final orderStatus = order['orderStatus'] ?? 'N/A';
                final orderDate = (order['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
                final address = order['address'] ?? {};

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    title: Text('Order ID: $orderId'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Status: $orderStatus'),
                        Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
                        Text('Date: ${orderDate.toLocal()}'),
                        const SizedBox(height: 8),
                        const Text(
                          'Delivery Address:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${address['recipientName'] ?? 'N/A'}, ${address['buildingName'] ?? 'N/A'}, ${address['cityStateZip'] ?? 'N/A'}, ${address['country'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Items:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: orderItems.map<Widget>((item) {
                            final productName = item['productName'] ?? 'Unknown Product';
                            final quantity = item['quantity'] ?? 1;
                            final price = item['price'] ?? 0.0;
                            return Text('$productName - ₹${price.toStringAsFixed(2)} x $quantity');
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
