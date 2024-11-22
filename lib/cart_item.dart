class CartItem {
  final String productId;
  String productName;
  String description;
  List<String> images;
  double price;
  String unit;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.description,
    required this.images,
    required this.price,
    required this.unit,
    this.quantity = 1,
  });

  // Method to update the product info
  void updateProductInfo({
    required String productName,
    required List<String> images,
    required double price,
    required String unit,
    required String description,
  }) {
    this.productName = productName;
    this.images = images;
    this.price = price;
    this.unit = unit;
    this.description = description;
  }

  // Method to increase quantity if the same item is added again
  void increaseQuantity() {
    quantity++;
  }

  // Method to calculate total price for this cart item
  double get totalPrice => price * quantity;
}
