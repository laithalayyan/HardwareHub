import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/products/cart/add_remove_button.dart';
import '../../../../../common/widgets/products/cart/cart_item.dart';
import '../../../../../common/widgets/products/product_price/product_price_text.dart';
import '../../../../../config/config.dart';
import '../../../../../toke.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../authentication/screens/login/login.dart';
import '../cart_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*
class TCartItems extends StatelessWidget {
  const TCartItems({super.key, this.showAddRemoveButtons = true, this.showDeleteButton = true});

  final bool showAddRemoveButtons;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Obx(() {
      // If the cart is empty, show a message
      if (cartController.cartItems.isEmpty) {
        return const Center(
          child: Text('Your cart is empty'),
        );
      }

      // Display cart items
      return ListView.separated(
        shrinkWrap: true,
        itemCount: cartController.cartItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwSections),
        itemBuilder: (_, index) {
          // Get product and its details
          final product = cartController.cartItems.keys.elementAt(index);
          final quantity = cartController.cartItems[product]['quantity'];
          final productDetails = cartController.cartItems[product]['product'];

          return Column(
            children: [
              /// Cart Item
              TCartItem(
                showDeleteButton: showDeleteButton,
                imageUrl: productDetails.imageUrl,
                name: productDetails.name,
                price: productDetails.price,
                onRemove: () => cartController.removeFromCart(product),
              ),

              /// Add/Remove Buttons and Total Price
              if (showAddRemoveButtons) ...[
                const SizedBox(height: TSizes.spaceBtwItems),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 70),
                        TProductQuantityWithAddRemoveButton(
                          quantity: quantity,
                          onIncrement: () => cartController.incrementQuantity(product),
                          onDecrement: () => cartController.decrementQuantity(product),
                        ),
                      ],
                    ),
                    TProductPriceText(
                      price: (productDetails.price * quantity).toStringAsFixed(2),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      );
    });
  }
}
*/
Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
  final url = '${AppConfig.baseUrl}/api/Items/$productId';
  final headers = await getHeaders();

  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    Get.offAll(() => const LoginScreen());
    throw Exception('Unauthorized: Please log in again');
  } else {
    throw Exception('Failed to load product details');
  }
}
Future<List<Map<String, dynamic>>> fetchCategories() async {
  const url = '${AppConfig.baseUrl}/api/Category/CategoryItem/All';
  final headers = await getHeaders();

  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else if (response.statusCode == 401) {
    Get.offAll(() => const LoginScreen());
    throw Exception('Unauthorized: Please log in again');
  } else {
    throw Exception('Failed to load categories');
  }
}
String getCategoryName(String categoryItemId, List<Map<String, dynamic>> categories) {
  final category = categories.firstWhere(
        (category) => category['id'] == categoryItemId,
    orElse: () => {},
  );

  return category['name'] ?? 'Unknown Category';
}

class TCartItems extends StatelessWidget {
  const TCartItems({super.key, this.showAddRemoveButtons = true, this.showDeleteButton = true});

  final bool showAddRemoveButtons;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCategories(),
      builder: (context, categoriesSnapshot) {
        if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoriesSnapshot.hasError) {
          return Center(child: Text('Error: ${categoriesSnapshot.error}'));
        }

        final categories = categoriesSnapshot.data!;

        return Obx(() {
          // If the cart is empty, show a message
          if (cartController.cartItems.isEmpty) {
            return const Center(
              child: Text('Your cart is empty'),
            );
          }

          // Display cart items
          return ListView.separated(
            shrinkWrap: true,
            itemCount: cartController.cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwSections),
            itemBuilder: (_, index) {
              // Get product and its details
              final productId = cartController.cartItems.keys.elementAt(index);
              final quantity = cartController.cartItems[productId]['quantity'];
              final productDetails = cartController.cartItems[productId]['product'];

              return FutureBuilder<Map<String, dynamic>>(
                future: fetchProductDetails(productId),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (productSnapshot.hasError) {
                    return Center(child: Text('Error: ${productSnapshot.error}'));
                  }

                  final productData = productSnapshot.data!;
                  final categoryName = getCategoryName(productData['categoryItemId'], categories);

                  return Column(
                    children: [
                      /// Cart Item
                      TCartItem(
                        showDeleteButton: showDeleteButton,
                        imageUrl: productDetails.imageUrl,
                        name: productDetails.name,
                        price: productDetails.price,
                        cat: categoryName, // Pass the category name
                        onRemove: () => cartController.removeFromCart(productId),
                      ),

                      /// Add/Remove Buttons and Total Price
                      if (showAddRemoveButtons) ...[
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 70),
                                TProductQuantityWithAddRemoveButton(
                                  quantity: quantity,
                                  onIncrement: () => cartController.incrementQuantity(productId),
                                  onDecrement: () => cartController.decrementQuantity(productId),
                                ),
                              ],
                            ),
                            TProductPriceText(
                              price: (productDetails.price * quantity).toStringAsFixed(2),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          );
        });
      },
    );
  }
}