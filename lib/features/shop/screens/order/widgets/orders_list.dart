import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../NotificationsService.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../config/config.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../cart/cart_controller.dart';
import 'package:http/http.dart' as http;

/*
class TOrderListItems extends StatelessWidget {
  const TOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final cartController = Get.find<CartController>();

    return Obx(() => ListView.separated(
      shrinkWrap: true,
      itemCount: cartController.purchases.length,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (_, index) {
        final purchase = cartController.purchases[index];
        final fullDate = purchase['purchaseDate']; // Full timestamp
        final formattedDate = _formatDate(fullDate); // Extract date part
        final purchaseId = purchase['id'];

        return GestureDetector(
          onTap: () async {
            // Fetch the latest purchase details from the API
            final orderDetails = await cartController.fetchPurchaseDetails(purchaseId);

            // Show the popup with the order details
            showDialog(
              context: context,
              builder: (context) => OrderDetailsPopup(orderDetails: orderDetails),
            );
          },
          child: FutureBuilder<Map<String, dynamic>>(
            future: cartController.fetchPurchaseDetails(purchaseId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show a loader while fetching
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // Show error if fetch fails
              } else if (!snapshot.hasData) {
                return const Text('No data found'); // Handle no data case
              }

              final purchaseDetails = snapshot.data!;
              final received = purchaseDetails['received'] ?? false;
              final status = received ? 'Received' : 'Pending';

              return TRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.dark : TColors.light,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// -- Row 1
                    Row(
                      children: [
                        const Icon(Iconsax.ship),
                        const SizedBox(width: TSizes.spaceBtwItems / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .apply(color: TColors.primary, fontWeightDelta: 1),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                formattedDate,
                                style: Theme.of(context).textTheme.headlineSmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        // Add the "Mark as Received" button here
                        if (!received)
                          IconButton(
                            onPressed: () async {
                              final token = GetStorage().read('token');
                              const url = AppConfig.baseUrl;

                              try {
                                final response = await http.post(
                                  Uri.parse('$url/api/Purchase/Received/$purchaseId'),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                  },
                                );

                                if (response.statusCode == 200) {
                                  // Update the local state
                                  cartController.purchases[index]['received'] = true;
                                  cartController.purchases.refresh(); // Refresh the UI

                                  // Fetch the latest purchase details from the API
                                  final orderDetails = await cartController.fetchPurchaseDetails(purchaseId);

                                  // Get the user who clicked the button
                                  final currentUser = GetStorage().read('username');

                                  // Get the recipient user (e.g., admin)
                                  final recipientUser = orderDetails['item']['userName'];

                                  // Create the notification message
                                  // Create the notification message
                                  final notificationMessage = '$currentUser marked the order as received: ${orderDetails['item']['name']}';
                                  //final notificationMessage = '$currentUser received their order: ${orderDetails['item']['name']}';

                                  // Send the notification
                                  final notificationsService = NotificationsService();
                                  await notificationsService.writeNotificationForUser(
                                    recipientUser,
                                    {
                                      'title': 'Order Received',
                                      'message': notificationMessage,
                                      'timestamp': DateTime.now().toIso8601String(),
                                      'isRead': false,
                                    },
                                  );

                                  // Show a success message
                                  Get.snackbar(
                                    'Success',
                                    'Order marked as received',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } else {
                                  throw Exception('Failed to mark as received: ${response.body}');
                                }
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to mark as received: $e',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            //Iconsax.tick_circle
                            icon: const Icon(Iconsax.tick_circle, size: TSizes.iconMd, color: Colors.green,),
                          ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// -- Row 2 (Order ID and Shipping Date)
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Iconsax.tag),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order',
                                      style: Theme.of(context).textTheme.labelMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      '#$purchaseId',
                                      style: Theme.of(context).textTheme.titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Iconsax.calendar),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Shipping Date',
                                      style: Theme.of(context).textTheme.labelMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      formattedDate,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ));
  }

  /// Helper function to format the date
  String _formatDate(String fullDate) {
    try {
      final dateTime = DateTime.parse(fullDate);
      return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
    } catch (e) {
      return fullDate;
    }
  }

  /// Helper function to ensure two-digit formatting for month and day
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
*/



class TOrderListItems extends StatelessWidget {
  const TOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final cartController = Get.find<CartController>();

    return Obx(() {
      // Sort the purchases in descending order based on purchaseDate
      final sortedPurchases = List<Map<String, dynamic>>.from(cartController.purchases);
      sortedPurchases.sort((a, b) {
        final aDate = DateTime.parse(a['purchaseDate']);
        final bDate = DateTime.parse(b['purchaseDate']);
        return bDate.compareTo(aDate); // Newest first
      });

      return ListView.separated(
          shrinkWrap: true,
          itemCount: sortedPurchases.length,
          separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
          itemBuilder: (_, index) {
            final purchase = sortedPurchases[index];
            final fullDate = purchase['purchaseDate'];
            final formattedDate = _formatDate(fullDate);
            final purchaseId = purchase['id'];

            return GestureDetector(
              onTap: () async {
                // Fetch the latest purchase details from the API
                final orderDetails = await cartController.fetchPurchaseDetails(purchaseId);

                // Show the popup with the order details
                showDialog(
                  context: context,
                  builder: (context) => OrderDetailsPopup(orderDetails: orderDetails),
                );
              },
              child: FutureBuilder<Map<String, dynamic>>(
                future: cartController.fetchPurchaseDetails(purchaseId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Text('No data found');
                  }

                  final purchaseDetails = snapshot.data!;
                  final received = purchaseDetails['received'] ?? false;
                  final status = received ? 'Received' : 'Pending';

                  return TRoundedContainer(
                    showBorder: true,
                    padding: const EdgeInsets.all(TSizes.md),
                    backgroundColor: dark ? TColors.dark : TColors.light,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// -- Row 1
                        Row(
                          children: [
                            const Icon(Iconsax.ship),
                            const SizedBox(width: TSizes.spaceBtwItems / 2),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    status,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .apply(color: TColors.primary, fontWeightDelta: 1),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    formattedDate,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            // Add the "Mark as Received" button here
                            if (!received)
                              IconButton(
                                onPressed: () async {
                                  final token = GetStorage().read('token');
                                  const url = AppConfig.baseUrl;

                                  try {
                                    final response = await http.post(
                                      Uri.parse('$url/api/Purchase/Received/$purchaseId'),
                                      headers: {
                                        'Authorization': 'Bearer $token',
                                      },
                                    );

                                    if (response.statusCode == 200) {
                                      // Update the local state
                                      cartController.purchases[index]['received'] = true;
                                      cartController.purchases.refresh(); // Refresh the UI

                                      // Fetch the latest purchase details from the API
                                      final orderDetails = await cartController.fetchPurchaseDetails(purchaseId);

                                      // Get the user who clicked the button
                                      final currentUser = GetStorage().read('username');

                                      // Get the recipient user (e.g., admin)
                                      final recipientUser = orderDetails['item']['userName'];

                                      // Create the notification message
                                      // Create the notification message
                                      final notificationMessage = '$currentUser marked the order as received: ${orderDetails['item']['name']}';
                                      //final notificationMessage = '$currentUser received their order: ${orderDetails['item']['name']}';

                                      // Send the notification
                                      final notificationsService = NotificationsService();
                                      await notificationsService.writeNotificationForUser(
                                        recipientUser,
                                        {
                                          'title': 'Order Received',
                                          'message': notificationMessage,
                                          'timestamp': DateTime.now().toIso8601String(),
                                          'isRead': false,
                                        },
                                      );

                                      // Show a success message
                                      Get.snackbar(
                                        'Success',
                                        'Order marked as received',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    } else {
                                      throw Exception('Failed to mark as received: ${response.body}');
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to mark as received: $e',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                                //Iconsax.tick_circle
                                icon: const Icon(Iconsax.tick_circle, size: TSizes.iconMd, color: Colors.green,),
                              ),
                          ],
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        /// -- Row 2 (Order ID and Shipping Date)
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Iconsax.tag),
                                  const SizedBox(width: TSizes.spaceBtwItems / 2),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order',
                                          style: Theme.of(context).textTheme.labelMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          '#$purchaseId',
                                          style: Theme.of(context).textTheme.titleMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Iconsax.calendar),
                                  const SizedBox(width: TSizes.spaceBtwItems / 2),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Shipping Date',
                                          style: Theme.of(context).textTheme.labelMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          formattedDate,
                                          style: Theme.of(context).textTheme.titleMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
      );
    });
  }

  /// Helper function to format the date
  String _formatDate(String fullDate) {
    try {
      final dateTime = DateTime.parse(fullDate);
      return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
    } catch (e) {
      return fullDate;
    }
  }

  /// Helper function to ensure two-digit formatting for month and day
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}

class OrderDetailsPopup extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  const OrderDetailsPopup({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Dialog(
      backgroundColor: dark ? TColors.dark : TColors.light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.borderRadiusLg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400), // Constrain the width of the popup
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: SingleChildScrollView( // Allow scrolling if content overflows vertically
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Order ID
                _buildDetailRow('Order ID', '#${orderDetails['id']}'),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Quantity
                _buildDetailRow('Quantity', '${orderDetails['quantity']}'),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Total Price
                _buildDetailRow('Total Price', '\$${orderDetails['totalPrice']}'),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Status
                _buildDetailRow(
                  'Status',
                  orderDetails['received'] ? 'Received' : 'Pending',
                  color: orderDetails['received'] ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Received Date
                if (orderDetails['received'])
                  _buildDetailRow('Received Date', _formatDate(orderDetails['receivedDate'])),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Item Details
                Text(
                  'Item Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                _buildItemDetails(orderDetails['item']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to build a detail row
  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color),
            overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
            maxLines: 1, // Ensure text is limited to one line
          ),
        ),
      ],
    );
  }

  /// Helper method to build item details
  Widget _buildItemDetails(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Item Name', item['name']),
        _buildDetailRow('Price', '\$${item['price']}'),
        _buildDetailRow('Count', '${item['count']}'),
        _buildDetailRow('Times Used', '${item['timesUsed']}'),
        if (item['itemImageUrl'] != null)
          Center(
            child: Image.network(
              item['itemImageUrl'],
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        _buildDetailRow('User', item['userName']),
        _buildDetailRow('Email', item['email']),
        if (item['phoneNumber'] != null) _buildDetailRow('Phone', item['phoneNumber']),
      ],
    );
  }

  /// Helper function to format the date
  String _formatDate(String fullDate) {
    try {
      final dateTime = DateTime.parse(fullDate);
      return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
    } catch (e) {
      return fullDate;
    }
  }

  /// Helper function to ensure two-digit formatting for month and day
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
