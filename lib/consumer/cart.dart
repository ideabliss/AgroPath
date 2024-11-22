import 'package:agropath/consumer/checkout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: const Center(
          child: Text('You need to log in to view your cart.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(255, 188, 233, 187),
        title: const Text('Your Cart'),
      ),


      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cartItems')
            .where('consumerId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading cart items.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items in the cart.'));
          }

          final cartItems = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.only(top: 8.0), // Add padding here

            child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final data = cartItem.data() as Map<String, dynamic>;
              final quantity = data['quantity'] ?? 1;
              final TextEditingController quantityController =
                  TextEditingController(text: quantity.toString());
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFA5DAA3), width: 1),
                ),
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      data['images'] != null && data['images'].isNotEmpty
                          ? Image.network(
                              data['images'][0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported, size: 50),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['productName'] ?? 'Unknown Product',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '₹${(double.tryParse(data['price'].toString()) ?? 0.0).toStringAsFixed(2)} x $quantity kg',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () async {
                              if (quantity > 1) {
                                await FirebaseFirestore.instance
                                    .collection('cartItems')
                                    .doc(cartItem.id)
                                    .update({'quantity': quantity - 1});
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('cartItems')
                                    .doc(cartItem.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${data['productName']} removed from your cart.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                hintText: '$quantity',
                              ),
                              onSubmitted: (value) async {
                                final newQuantity =
                                    int.tryParse(value) ?? quantity;

                                if (newQuantity > 0) {
                                  await FirebaseFirestore.instance
                                      .collection('cartItems')
                                      .doc(cartItem.id)
                                      .update({'quantity': newQuantity});
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('cartItems')
                                      .doc(cartItem.id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${data['productName']} removed from your cart.'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('cartItems')
                                  .doc(cartItem.id)
                                  .update({'quantity': quantity + 1});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('cartItems')
                                  .doc(cartItem.id)
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${data['productName']} removed from your cart.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            )
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cartItems')
            .where('consumerId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final cartItems = snapshot.data!.docs;

          final totalAmount = cartItems.fold<double>(
            0.0,
            (sum, item) {
              final data = item.data() as Map<String, dynamic>;
              final price = double.tryParse(data['price'].toString()) ?? 0.0;
              final quantity = data['quantity'] ?? 1;
              return sum + (price * quantity);
            },
          );

          return BottomAppBar(
            color: Colors.white,
            elevation: 5,
            shape: const CircularNotchedRectangle(),
            child: SafeArea(
              minimum: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                   SizedBox(
  height: 40, // Fixed button height
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFA5DAA3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
    ),
    onPressed: () async {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        // Show error if user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to log in to place an order.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Fetch the cart items
      final snapshot = await FirebaseFirestore.instance
          .collection('cartItems')
          .where('consumerId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        // If the cart is empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your cart is empty. Add items to the cart before proceeding.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Calculate the total amount
      final totalAmount = snapshot.docs.fold<double>(0.0, (sum, item) {
        final data = item.data();
        final price = double.tryParse(data['price'].toString()) ?? 0.0;
        final quantity = data['quantity'] ?? 1;
        return sum + (price * quantity);
      });

      // Navigate to CheckoutScreen and pass cart items and total amount
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            cartItems: snapshot.docs,
            totalAmount: totalAmount,
          ),
        ),
      );
    },
    child: const Text(
      'Proceed to Checkout',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  ),
)

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
