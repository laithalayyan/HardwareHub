class Product {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final bool inStock;
  final String description;
  final int stockQuantity; // Stock quantity for inventory
  int quantity; // Quantity added to cart

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    this.inStock = true ,
    this.description = '',
    this.stockQuantity = 10 ,
    this.quantity = 1, // Default cart quantity
  });
}
