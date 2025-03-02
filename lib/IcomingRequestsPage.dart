import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import 'NotificationsService.dart';
import 'common/widgets/appbar/appbar.dart';
import 'common/widgets/custom_shapes/containers/rounded_container.dart';
import 'config/config.dart';
import 'features/shop/screens/cart/cart_controller.dart';

/*
class IncomingRequestsPage extends StatefulWidget {
  const IncomingRequestsPage({super.key});
  @override
  _IncomingRequestsPageState createState() => _IncomingRequestsPageState();
}

class _IncomingRequestsPageState extends State<IncomingRequestsPage> {
  List<Map<String, dynamic>> _requests = [];
  final cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final currentUser = GetStorage().read('username');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/purchase_requests_$currentUser.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        setState(() {
          _requests = List<Map<String, dynamic>>.from(jsonDecode(content));
        });
      } else {
        setState(() {
          _requests = [];
        });
      }
    }else{
      setState(() {
        _requests = [];
      });
    }

  }


  Future<void> _acceptRequest(String requestId, int index) async {
    final request = _requests[index];
    final token = GetStorage().read('token');
    const url = AppConfig.baseUrl;

    // Prepare the request body
    final body = {
      "quantity": request['quantity'],
      "itemId": request['itemId'],
    };
    try {
      // Send the request to the API
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
        final notificationsService = NotificationsService();
        // Get the user who clicked the button
        final currentUser = GetStorage().read('username');
        // Create the notification message
        final notificationMessage = '$currentUser accepted the request of  ${request['itemId']}';

        // Send the notification
        await notificationsService.writeNotificationForUser(
          request['buyer'],
          {
            'title': 'Order Accepted',
            'message': notificationMessage,
            'timestamp': DateTime.now().toIso8601String(),
            'isRead': false,
          },
        );
        // Remove the request locally
        await _removeRequest(requestId);
        await _loadRequests();

        // Show a success message
        Get.snackbar(
          'Success',
          'Request accepted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

      } else {
        throw Exception('Failed to purchase: ${response.body}');
      }

    }catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  Future<void> _denyRequest(String requestId) async {
    await _removeRequest(requestId);
    await _loadRequests();
    // Show a success message
    Get.snackbar(
      'Success',
      'Request denied successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> _removeRequest(String requestId) async {
    final currentUser = GetStorage().read('username');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/purchase_requests_$currentUser.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        List<Map<String, dynamic>> requests = List<Map<String, dynamic>>.from(jsonDecode(content));
        requests.removeWhere((request) => request['id'] == requestId);
        await file.writeAsString(jsonEncode(requests));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const TAppBar(title: Text('Incoming Requests'), showBackArrow: true),
      body: _requests.isEmpty ? const Center(child: Text('No incoming requests'))
          : ListView.separated(
        itemCount: _requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
        itemBuilder: (context, index) {
          final request = _requests[index];
          final formattedDate = _formatDate(request['requestDate']);
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
                    const Icon(Iconsax.shopping_bag),
                    const SizedBox(width: TSizes.spaceBtwItems / 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request From: ${request['buyer']}',
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
                                  'Item ID',
                                  style: Theme.of(context).textTheme.labelMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  '#${request['itemId']}',
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
                                  'Request Date',
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
                const SizedBox(height: TSizes.spaceBtwItems),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _acceptRequest(request['id'],index);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Accept', style: TextStyle(color: Colors.white),),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _denyRequest(request['id']);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Deny', style: TextStyle(color: Colors.white)),
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

class IncomingRequestsPage extends StatefulWidget {
  const IncomingRequestsPage({super.key});
  @override
  _IncomingRequestsPageState createState() => _IncomingRequestsPageState();
}

class _IncomingRequestsPageState extends State<IncomingRequestsPage> {
  List<Map<String, dynamic>> _requests = [];
  final cartController = Get.find<CartController>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });
    final currentUser = GetStorage().read('username');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/purchase_requests_$currentUser.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        List<Map<String,dynamic>> requests = List<Map<String, dynamic>>.from(jsonDecode(content));
        await _fetchItemNames(requests);
        setState(() {
          _requests = requests;
          _isLoading= false;
        });
      } else {
        setState(() {
          _requests = [];
          _isLoading= false;
        });
      }
    }else{
      setState(() {
        _requests = [];
        _isLoading= false;
      });
    }

  }

  Future<void> _fetchItemNames(List<Map<String, dynamic>> requests) async {
    for(var request in requests){
      final itemId = request['itemId'];
      final itemName = await _fetchItemName(itemId);
      if (itemName != null){
        request['itemName']=itemName;
      }
    }
  }

  Future<String?> _fetchItemName(String itemId) async {
    try {
      final notificationsService = NotificationsService();
      final itemName = await notificationsService.fetchItemName(itemId);
      return itemName;
    } catch (e) {
      debugPrint("Error fetching item name: $e");
      return null;
    }
  }
  Future<void> _acceptRequest(String requestId, int index) async {
    final request = _requests[index];
    final token = GetStorage().read('token');
    const url = AppConfig.baseUrl;

    // Prepare the request body
    final body = {
      "quantity": request['quantity'],
      "itemId": request['itemId'],
    };
    try {
      // Send the request to the API
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
        final notificationsService = NotificationsService();
        // Get the user who clicked the button
        final currentUser = GetStorage().read('username');
        // Create the notification message
        final notificationMessage = '$currentUser accepted the request of  ${request['itemName']}';

        // Send the notification
        await notificationsService.writeNotificationForUser(
          request['buyer'],
          {
            'title': 'Order Accepted',
            'message': notificationMessage,
            'timestamp': DateTime.now().toIso8601String(),
            'isRead': false,
          },
        );
        // Remove the request locally
        await _removeRequest(requestId);
        await _loadRequests();

        // Show a success message
        Get.snackbar(
          'Success',
          'Request accepted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

      } else {
        throw Exception('Failed to purchase: ${response.body}');
      }

    }catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _denyRequest(String requestId) async {
    await _removeRequest(requestId);
    await _loadRequests();
    // Show a success message
    Get.snackbar(
      'Success',
      'Request denied successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> _removeRequest(String requestId) async {
    final currentUser = GetStorage().read('username');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/purchase_requests_$currentUser.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        List<Map<String, dynamic>> requests = List<Map<String, dynamic>>.from(jsonDecode(content));
        requests.removeWhere((request) => request['id'] == requestId);
        await file.writeAsString(jsonEncode(requests));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const TAppBar(title: Text('Incoming Requests'), showBackArrow: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? const Center(child: Text('No incoming requests'))
          :ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          final formattedDate = _formatDate(request['requestDate']);
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: GestureDetector(
          onTap: () async {
          // Fetch the item details from the API
          final itemDetails = await _fetchItemDetails(request['itemId']);
          // Show the popup with the request details
          if (itemDetails != null){
          showDialog(
          context: context,
          builder: (context) => RequestDetailsPopup(requestDetails: request, itemDetails: itemDetails),
          );
          }else {
          Get.snackbar(
          'Error',
          'Failed to fetch item details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          );
          }
          },
          child: TRoundedContainer(
          showBorder: true,
          padding: const EdgeInsets.all(TSizes.md),
          backgroundColor: dark ? TColors.dark : TColors.light,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          /// -- Row 1
          Row(
          children: [
          const Icon(Iconsax.shopping_bag),
          const SizedBox(width: TSizes.spaceBtwItems / 2),
          Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
          'Request From: ${request['buyer']}',
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
          'Item Name',
          style: Theme.of(context).textTheme.labelMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          ),
          Text(
          '${request['itemName']}',
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
          'Request Date',
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
          const SizedBox(height: TSizes.spaceBtwItems),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          Expanded(
          flex: 1,
          child: ElevatedButton(
          onPressed: () async {
          await _acceptRequest(request['id'],index);
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjust padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
          ),
          child: const Text('Accept', style: TextStyle(color: Colors.white , fontSize: 17),),
          ),
          ),
          const SizedBox(width: 15,),
          Expanded(
          flex: 1,
          child: ElevatedButton(
          onPressed: () async {
          await _denyRequest(request['id']);
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Deny', style: TextStyle(color: Colors.white , fontSize: 17)),
          ),
          ),
          ],
          ),
          ],
          ),
          ),
          ),
          ),
          );
        },
      ),
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
  Future<Map<String, dynamic>?> _fetchItemDetails(String itemId) async {
    final token = GetStorage().read('token');
    const url = AppConfig.baseUrl;
    try {
      final response = await http.get(
        Uri.parse('$url/api/Items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);
        return item;
      } else {
        throw Exception('Failed to fetch item details for ID $itemId: ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch item details for ID $itemId: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }
}


class RequestDetailsPopup extends StatelessWidget {
  final Map<String, dynamic> requestDetails;
  final Map<String, dynamic> itemDetails;

  const RequestDetailsPopup({super.key, required this.requestDetails, required this.itemDetails});

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
                /// Request ID
                _buildDetailRow('Request ID', '#${requestDetails['id']}'),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Quantity
                _buildDetailRow('Quantity', '${requestDetails['quantity']}'),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Status
                _buildDetailRow(
                  'Status',
                  requestDetails['status'] ,
                  color:  Colors.orange,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Request Date
                _buildDetailRow('Request Date', _formatDate(requestDetails['requestDate'])),
                const SizedBox(height: TSizes.spaceBtwItems),
                /// Item Details
                Text(
                  'Item Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                _buildItemDetails(itemDetails),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'Buyer Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                _buildDetailRow('Buyer', requestDetails['buyer']),
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
        _buildDetailRow('User', item['user']['username']),
        _buildDetailRow('Email', item['user']['email']),
        if (item['user']['phoneNumber'] != null) _buildDetailRow('Phone', item['user']['phoneNumber']),
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
