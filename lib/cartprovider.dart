import 'package:agropath/cart_item.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  double get totalAmount {
    return _cartItems.fold(0, (total, item) => total + item.totalPrice);
  }

  // Add product to the cart in Firestore
  Future<void> addToCart(String productId, String productName, double price, List<String> images, String consumerId) async {
    final cartRef = FirebaseFirestore.instance.collection('cartItems');

    // Check if the product is already in the cart
    final existingCartItem = await cartRef
        .where('consumerId', isEqualTo: consumerId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (existingCartItem.docs.isEmpty) {
      // If the product is not in the cart, add it with quantity 1
      await cartRef.add({
        'productId': productId,
        'productName': productName,
        'price': price,
        'images': images,
        'consumerId': consumerId,
        'quantity': 1,  // Initialize quantity to 1
      });
    } else {
      // If the product already exists in the cart, update the quantity
      final cartItem = existingCartItem.docs.first;
      final currentQuantity = cartItem.data()['quantity'] ?? 1;
      await cartRef.doc(cartItem.id).update({
        'quantity': currentQuantity + 1,  // Increase quantity by 1
      });
    }

    notifyListeners(); // Notify listeners to update UI
  }

  // Remove product from the cart
  Future<void> removeFromCart(String productId) async {
    final cartRef = FirebaseFirestore.instance.collection('cartItems');

    // Remove item from Firestore
    final cartItemQuery = await cartRef
        .where('consumerId', isEqualTo: 'consumerId') // You should pass the actual consumerId
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (cartItemQuery.docs.isNotEmpty) {
      final cartItemDoc = cartItemQuery.docs.first;
      await cartRef.doc(cartItemDoc.id).delete();
    }

    notifyListeners(); // Notify listeners to update UI
  }

  // Optionally, this method can handle the increment and decrement actions directly if you're handling cart operations
  Future<void> updateQuantity(String productId, int newQuantity) async {
    final cartRef = FirebaseFirestore.instance.collection('cartItems');

    final cartItemQuery = await cartRef
        .where('consumerId', isEqualTo: 'consumerId') // Use the actual consumerId
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (cartItemQuery.docs.isNotEmpty) {
      final cartItemDoc = cartItemQuery.docs.first;
      final currentQuantity = cartItemDoc.data()['quantity'] ?? 1;

      if (newQuantity == 0) {
        await cartRef.doc(cartItemDoc.id).delete(); // Remove if quantity is 0
      } else {
        await cartRef.doc(cartItemDoc.id).update({
          'quantity': newQuantity, // Update quantity
        });
      }
    }

    notifyListeners(); // Notify listeners to update UI
  }
}
