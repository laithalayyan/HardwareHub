import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../config/config.dart';
import '../../../../data/products_data/product_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class CartController extends GetxController {

  Future<void> fetchPurchases() async {
    final token = GetStorage().read('token');
    const url = AppConfig.baseUrl;

    try {
      final response = await http.get(
        Uri.parse('$url/api/Purchase'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> purchaseList = jsonDecode(response.body);
        purchases.assignAll(purchaseList); // Update the purchases list
      } else {
        throw Exception('Failed to fetch purchases: ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch purchases: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<Map<String, dynamic>> fetchPurchaseDetails(String purchaseId) async {
    final token = GetStorage().read('token');
    const url = AppConfig.baseUrl;

    try {
      final response = await http.get(
        Uri.parse('$url/api/Purchase/$purchaseId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch purchase details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch purchase details: $e');
    }
  }


  var cartItems = {}.obs;
  var purchases = [].obs; // List to store purchases

  void clearCart() {
    cartItems.clear(); // Remove all items from the cart
    cartItems.refresh(); // Refresh the UI
  }

  // Add a purchase to the list
  void addPurchase(Map<String, dynamic> purchase) {
    purchases.add(purchase);
  }

  void addToCart(Product product, int quantity) {
    // Check if the product's stock quantity is greater than 0
    if (product.stockQuantity <= 0) {
      Get.snackbar(
        'Out of Stock',
        'This product is currently out of stock.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return; // Exit the method if the product is out of stock
    }

    if (cartItems.containsKey(product.id)) {
      // Increase the quantity if the product is already in the cart
      final currentQuantity = cartItems[product.id]['quantity'];
      final stockQuantity = cartItems[product.id]['product'].stockQuantity;

      // Ensure we do not exceed the stock quantity
      if (currentQuantity + quantity <= stockQuantity) {
        cartItems[product.id]['quantity'] += quantity;
      } else {
        Get.snackbar(
          'Stock Limit',
          'Sorry, only $stockQuantity items are available in stock.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // Add the product to the cart with the specified quantity
      cartItems[product.id] = {'product': product, 'quantity': quantity};
    }
    cartItems.refresh(); // Refresh to update the UI
  }

  /*
  // Add to Cart
  void addToCart(Product product, int quantity) {
    if (cartItems.containsKey(product.id)) {
      // Increase the quantity if the product is already in the cart
      final currentQuantity = cartItems[product.id]['quantity'];
      final stockQuantity = cartItems[product.id]['product'].stockQuantity;

      // Ensure we do not exceed the stock quantity
      if (currentQuantity + quantity <= stockQuantity) {
        cartItems[product.id]['quantity'] += quantity;
      } else {
        Get.snackbar(
          'Stock Limit',
          'Sorry, only $stockQuantity items are available in stock.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // Add the product to the cart with the specified quantity
      cartItems[product.id] = {'product': product, 'quantity': quantity};
    }
    cartItems.refresh(); // Refresh to update the UI
  }
*/

  // Increment Quantity
  void incrementQuantity(String productId) {
    if (cartItems.containsKey(productId)) {
      final currentQuantity = cartItems[productId]['quantity'];
      final stockQuantity = cartItems[productId]['product'].stockQuantity;

      // Check if stock quantity is sufficient
      if (currentQuantity < stockQuantity) {
        cartItems[productId]['quantity']++;
        cartItems.refresh(); // Trigger UI update
      } else {
        // Show a message if stock limit is reached
        Get.snackbar(
          'Stock Limit',
          'Sorry, only $stockQuantity items are available in stock.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Decrement Quantity
  void decrementQuantity(String productId) {
    if (cartItems.containsKey(productId) && cartItems[productId]['quantity'] > 1) {
      cartItems[productId]['quantity']--;
      cartItems.refresh(); // Force UI update
    }
  }

  // Remove Product
  void removeFromCart(String productId) {
    cartItems.remove(productId);
    cartItems.refresh(); // Ensure UI reflects changes
  }

  // Get Total Price
  double get totalPrice => cartItems.entries
      .map((e) => e.value['product'].price * e.value['quantity'])
      .fold(0, (sum, price) => sum + price);

  // Get Total Items in Cart
  RxInt get totalItems => RxInt(
    cartItems.entries.fold(0, (sum, entry) => sum + (entry.value['quantity'] as int)),
  );

  int getProductQuantity(String productId) {
    return cartItems.containsKey(productId) ? cartItems[productId]['quantity'] : 0;
  }


}

