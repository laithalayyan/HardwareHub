import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import '../../../../NotificationsService.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../cart/cart_controller.dart';
import '../cart/widgets/cart_items.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/config.dart';

/*
class CheckoutScreen extends StatelessWidget {
  final double totalPrice;
  const CheckoutScreen({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      //backgroundColor: const Color(0xfff3feff),
      appBar: TAppBar(showBackArrow: true, title: Text('Request Review', style: Theme.of(context).textTheme.headlineSmall,),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Items in Cart
              const TCartItems(showAddRemoveButtons: false,showDeleteButton: false,),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Billing Section
              TRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.black : TColors.white,
                child: Column(
                  children: [
                    /// Pricing
                    TBillingAmountSection(totalPrice: totalPrice,),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () async {
            final cartController = Get.find<CartController>();
            final token = GetStorage().read('token'); // Retrieve the token
            const url = AppConfig.baseUrl; // Base URL

            try {
              // Loop through each product in the cart
              for (var entry in cartController.cartItems.entries) {
                final productId = entry.key;
                final quantity = entry.value['quantity'];

                // Prepare the request body
                final body = {
                  "quantity": quantity,
                  "itemId": productId,
                };

                // Send the request
                final response = await http.post(
                  Uri.parse('$url/api/Purchase'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(body),
                );

                if (response.statusCode == 200) {
                  // Parse the response
                  final purchaseResponse = jsonDecode(response.body);
                  print('Purchase successful: $purchaseResponse');

                  // Store the purchase response (you can use GetStorage or a controller)
                  // For example, add it to a list of purchases
                  cartController.addPurchase(purchaseResponse);
                } else {
                  throw Exception('Failed to purchase: ${response.body}');
                }
              }

              // Clear the cart after successful checkout
              cartController.clearCart();

              // Navigate to the success screen
              Get.to(
                    () => SuccessScreen(
                  image: TImages.successfulPaymentIcon,
                  title: 'Request Sent!',
                  subTitle: 'The Owner will review it! ',
                  onPressed: () => Get.offAll(() => const NavigationMenu()),
                ),
              );
            } catch (e) {
              Get.snackbar(
                'Error',
                'Failed to complete checkout: $e',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          child: Text('Request Items: ${totalPrice.toStringAsFixed(2)}\₪'),
        ),
      ),

    );
  }
}
*/



class CheckoutScreen extends StatelessWidget {
  final double totalPrice;
  const CheckoutScreen({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(showBackArrow: true, title: Text('Request Review', style: Theme.of(context).textTheme.headlineSmall,)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Items in Cart
              const TCartItems(showAddRemoveButtons: false, showDeleteButton: false,),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Billing Section
              TRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.black : TColors.white,
                child: Column(
                  children: [
                    /// Pricing
                    TBillingAmountSection(totalPrice: totalPrice,),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () async {
            final cartController = Get.find<CartController>();
            final currentUser = GetStorage().read('username'); // Get the current user
            final notificationsService = NotificationsService(); // Initialize the notification service
            final List<String> productIds = cartController.cartItems.keys
                .map((key) =>  key.toString())
                .toList();

            try {
              // Loop through each product in the cart
              final itemsWithOwners = await _getItemsWithOwners(productIds);
              for (var entry in cartController.cartItems.entries) {
                final productId = entry.key;
                final quantity = entry.value['quantity'];
                // Find the owner of the item
                String? ownerName;
                String? itemName;
                for (var item in itemsWithOwners) {
                  if (item['id'].toString() == productId.toString()) {
                    ownerName = item['userName'];
                    itemName = item['name'];
                    break;
                  }
                }
                if (ownerName == null) {
                  Get.snackbar(
                    'Error',
                    'Could not find the owner of the item $productId',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                // Prepare the request body
                final requestBody = {
                  "quantity": quantity,
                  "itemId": productId,
                  "buyer": currentUser,
                  "requestDate": DateTime.now().toIso8601String(),
                  "status": "Pending", // Initial status
                };
                // Create the notification message
                final notificationMessage = '$currentUser has requested to buy ${quantity} items of $itemName';

                // Send the notification to the item owner
                await notificationsService.writeNotificationForUser(
                  ownerName,
                  {
                    'title': 'Purchase Request',
                    'message': notificationMessage,
                    'timestamp': DateTime.now().toIso8601String(),
                    'isRead': false,
                    'type': 'request'
                  },
                );
                // Save the purchase request to the owner's file
                await _savePurchaseRequest(ownerName, requestBody);
              }
              cartController.clearCart(); // Clear the cart after sending requests
              // Navigate to the success screen
              Get.to(
                    () => SuccessScreen(
                  image: TImages.successfulPaymentIcon,
                  title: 'Request Sent!',
                  subTitle: 'The Owner will review it! ',
                  onPressed: () => Get.offAll(() => const NavigationMenu()),
                ),
              );
            } catch (e) {
              Get.snackbar(
                'Error',
                'Failed to complete request: $e',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          child: Text('Request Items: ${totalPrice.toStringAsFixed(2)}\₪'),
        ),
      ),
    );
  }

  Future<void> _savePurchaseRequest(String userName, Map<String, dynamic> request) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/purchase_requests_$userName.json');

    List<Map<String, dynamic>> existingRequests = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        existingRequests = List<Map<String, dynamic>>.from(jsonDecode(content));
      }
    }
    // Add a unique ID to the request
    request['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    existingRequests.add(request);
    await file.writeAsString(jsonEncode(existingRequests));
  }

  Future<List<Map<String, dynamic>>> _getItemsWithOwners(List<String> productIds) async {
    final token = GetStorage().read('token');
    const url = AppConfig.baseUrl;
    List<Map<String, dynamic>> itemsWithOwners = [];

    for (var productId in productIds) {
      try {
        final response = await http.get(
          Uri.parse('$url/api/Items/$productId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final item = jsonDecode(response.body);
          // Correctly access the username from the nested 'user' object
          item['userName'] = item['user']['username']; // add item owner user name to the item
          itemsWithOwners.add(item);
        } else {
          throw Exception('Failed to fetch item details for ID $productId: ${response.body}');
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to fetch item details for ID $productId: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
    return itemsWithOwners;
  }
}

class TBillingAmountSection extends StatelessWidget {
  final double totalPrice;
  const TBillingAmountSection({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Order Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Total', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${totalPrice.toStringAsFixed(2)}\₪', // Convert double to String with 2 decimal places
              style: Theme.of(context).textTheme.titleMedium,
            ),
            //Text(totalPrice as String, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}

