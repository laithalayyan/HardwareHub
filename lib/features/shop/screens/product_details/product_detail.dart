import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/bottom_add_to_cart_widget.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/product_detail_image_slider.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/product_meta_data.dart';
import 'package:t_store/features/shop/screens/product_details/widgets/rating_share_widget.dart';
import 'package:t_store/features/shop/screens/product_reviews/product_reviews.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import '../../../../chatPage.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../config/config.dart';
import '../../../../data/products_data/product_model.dart';
import '../../../../utils/constants/sizes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

import '../cart/cart_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewService {
  static Future<Map<String, dynamic>> fetchReviewData(String itemId) async {
    final box = GetStorage();
    final token = box.read('token');
    final url = '${AppConfig.baseUrl}/api/Review/Item/$itemId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Log the API response
      print('API Response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log the parsed data
        print('Parsed Data: $data');

        // Handle case where averageGrade is an int or double
        final averageGrade = data['averageGrade'] is int
            ? (data['averageGrade'] as int).toDouble() // Convert int to double
            : data['averageGrade'] as double; // Use as double if already a double

        final reviews = data['reviews'] as List; // Get reviews array
        final reviewCount = reviews.length; // Count reviews

        // Log the extracted values
        print('Average Grade: $averageGrade');
        print('Review Count: $reviewCount');

        return {
          'averageGrade': averageGrade,
          'reviewCount': reviewCount,
        };
      } else {
        // If the API call fails, return default values
        return {
          'averageGrade': 0.0,
          'reviewCount': 0,
        };
      }
    } catch (e) {
      // Handle any exceptions (e.g., network errors)
      print('Error: $e');
      return {
        'averageGrade': 0.0,
        'reviewCount': 0,
      };
    }
  }
}

class ProductService {
  static Future<Map<String, dynamic>> fetchProductOwnerDetails(String itemId) async {
    final box = GetStorage();
    final token = box.read('token');
    final url = '${AppConfig.baseUrl}/api/Items/$itemId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        //throw Exception('Failed to load product owner details');
        final data = json.decode(response.body);
        return data;
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

/*
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final CartController cartController = Get.find<CartController>();
    final GetStorage storage = GetStorage();
    final String loggedInUsername = storage.read('username') ?? '';

    return Scaffold(
      bottomNavigationBar: TBottomAddToCart(product: product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1 - Product Image Slider
            TProductImageSlider(product: product),

            /// 2 - Product Details
            Padding(
              padding: const EdgeInsets.only(
                right: TSizes.defaultSpace,
                left: TSizes.defaultSpace,
                bottom: TSizes.defaultSpace,
              ),
              child: Column(
                children: [
                  /// Rating & Share Button
                  FutureBuilder<Map<String, dynamic>>(
                    future: ReviewService.fetchReviewData(product.id ?? 'default-id'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('No review data found');
                      } else {
                        final reviewData = snapshot.data!;
                        return TRatingAndShare(
                          averageGrade: reviewData['averageGrade'],
                          reviewCount: reviewData['reviewCount'],
                        );
                      }
                    },
                  ),

                  /// Price, Title, Stock, & Brand
                  TProductMetaData(product: product),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add the product to the cart with a default quantity of 1
                        cartController.addToCart(product, 1);
                        // Show a confirmation message
                        Get.snackbar(
                          'Added to Cart',
                          '${product.name} x 1 added!',
                          snackPosition: SnackPosition.BOTTOM,
                          //backgroundColor: TColors.dark,
                        );
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Description
                  const TSectionHeading(title: 'Description', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ReadMoreText(
                    product.description,
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more ',
                    trimExpandedText: ' Less ',
                    moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  /// Times Used Section
                  FutureBuilder<Map<String, dynamic>>(
                    future: ProductService.fetchProductOwnerDetails(product.id ?? 'default-id'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return const Text('No product details found');
                      }

                      final productDetails = snapshot.data!;
                      final timesUsed = productDetails['timesUsed'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: TSizes.spaceBtwItems),
                          TSectionHeading(
                            title: 'Times Used: $timesUsed',
                            showActionButton: false,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8,),
                  const Divider(),
                  const SizedBox(height: 8,),

                  /// Owner Section
                  FutureBuilder<Map<String, dynamic>>(
                    future: ProductService.fetchProductOwnerDetails(product.id ?? 'default-id'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return const Text('No owner data found');
                      }

                      final ownerData = snapshot.data!['user'];
                      final ownerUsername = ownerData['username'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TSectionHeading(
                            title: 'Owner: $ownerUsername',
                            showActionButton: false,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              // Create a unique chat ID using the usernames
                              final String chatId = _generateChatId(loggedInUsername, ownerUsername);

                              // Navigate to the chat screen
                              Get.to(() => ChatScreen(
                                chatId: chatId,
                                currentUserUsername: loggedInUsername,
                                otherUserUsername: ownerUsername,
                              ));

                              // Create or update the chat in Firebase
                              await _createOrUpdateChat(chatId, loggedInUsername, ownerUsername);
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Chat with Owner',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Iconsax.message, size: 22),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              _showBoardSelectionDialog(context, product.name);
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Connect with Board',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Iconsax.cpu, size: 22),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  /// Reviews
                  const Divider(),
                  //const SizedBox(height: 5),
                  FutureBuilder<Map<String, dynamic>>(
                    future: ReviewService.fetchReviewData(product.id ?? 'default-id'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('No reviews found');
                      } else {
                        final reviewCount = snapshot.data!['reviewCount'];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TSectionHeading(title: 'Reviews ($reviewCount)', showActionButton: false),
                            IconButton(
                              icon: const Icon(Iconsax.arrow_right_3, size: 18),
                              onPressed: () {
                                Get.to(() => ProductReviewsScreen(itemId: product.id));
                                                            },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Add Report a Problem Line
                  InkWell(
                    onTap: () => _showReportDialog(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Report a Problem',
                        style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GetStorage storage = GetStorage();
  String? loggedInUsername;

  @override
  void initState() {
    super.initState();
    loggedInUsername = storage.read('username');
  }


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      bottomNavigationBar: TBottomAddToCart(product: widget.product),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1 - Product Image Slider
            TProductImageSlider(product: widget.product),

            /// 2 - Product Details
            Padding(
              padding: const EdgeInsets.only(
                right: TSizes.defaultSpace,
                left: TSizes.defaultSpace,
                bottom: TSizes.defaultSpace,
              ),
              child: Column(
                children: [
                  /// Rating & Share Button
                  FutureBuilder<Map<String, dynamic>>(
                    future: ReviewService.fetchReviewData(widget.product.id ?? 'default-id'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('No review data found');
                      } else {
                        final reviewData = snapshot.data!;
                        return TRatingAndShare(
                          averageGrade: reviewData['averageGrade'],
                          reviewCount: reviewData['reviewCount'],
                        );
                      }
                    },
                  ),

                  /// Price, Title, Stock, & Brand
                  TProductMetaData(product: widget.product),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add the product to the cart with a default quantity of 1
                        cartController.addToCart(widget.product, 1);
                        // Show a confirmation message
                        Get.snackbar(
                          'Added to Cart',
                          '${widget.product.name} x 1 added!',
                          snackPosition: SnackPosition.BOTTOM,
                          //backgroundColor: TColors.dark,
                        );
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Description
                  const TSectionHeading(title: 'Description', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ReadMoreText(
                    widget.product.description,
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more ',
                    trimExpandedText: ' Less ',
                    moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),

                  /// Times Used Section
                  FutureBuilder<Map<String, dynamic>>(
                    future: ProductService.fetchProductOwnerDetails(widget.product.id ?? 'default-id'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return const Text('No product details found');
                      }

                      final productDetails = snapshot.data!;
                      final timesUsed = productDetails['timesUsed'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: TSizes.spaceBtwItems),
                          TSectionHeading(
                            title: 'Times Used: $timesUsed',
                            showActionButton: false,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8,),
                  const Divider(),
                  const SizedBox(height: 8,),

                  /// Owner Section
                  FutureBuilder<Map<String, dynamic>>(
                    future: ProductService.fetchProductOwnerDetails(widget.product.id ?? 'default-id'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return const Text('No owner data found');
                      }

                      final ownerData = snapshot.data!['user'];
                      final ownerUsername = ownerData['username'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TSectionHeading(
                            title: 'Owner: $ownerUsername',
                            showActionButton: false,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              // Create a unique chat ID using the usernames
                              final String chatId = _generateChatId(loggedInUsername ?? '', ownerUsername);

                              // Navigate to the chat screen
                              Get.to(() => ChatScreen(
                                chatId: chatId,
                                currentUserUsername: loggedInUsername ?? '',
                                otherUserUsername: ownerUsername,
                              ));

                              // Create or update the chat in Firebase
                              await _createOrUpdateChat(chatId, loggedInUsername ?? '', ownerUsername);
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Chat with Owner',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Iconsax.message, size: 22),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              _showBoardSelectionDialog(context, widget.product.name);
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Connect with Board',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    decoration: TextDecoration.underline,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Iconsax.cpu, size: 22),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  /// Reviews
                  const Divider(),
                  //const SizedBox(height: 5),
                  FutureBuilder<Map<String, dynamic>>(
                    future: ReviewService.fetchReviewData(widget.product.id ?? 'default-id'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('No reviews found');
                      } else {
                        final reviewCount = snapshot.data!['reviewCount'];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TSectionHeading(title: 'Reviews ($reviewCount)', showActionButton: false),
                            IconButton(
                              icon: const Icon(Iconsax.arrow_right_3, size: 18),
                              onPressed: () {
                                Get.to(() => ProductReviewsScreen(itemId: widget.product.id));
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  // Add Report a Problem Line
                  InkWell(
                    onTap: () => _showReportDialog(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Report a Problem',
                        style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    String? selectedProblem;
    final TextEditingController otherReasonsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: TColors.black,
            title: const Text(
              'Choose a Problem',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TColors.white),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntrinsicWidth(
                    child: DropdownButtonFormField<String>(
                      value: selectedProblem,
                      items: const [
                        DropdownMenuItem(
                          value: 'The user does not respond to requests',
                          child: Text(
                            'The user does not respond to requests',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'The user does not have the item',
                          child: Text(
                            'The user does not have the item',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedProblem = value;
                        });
                      },
                      dropdownColor: TColors.black, // Set the dropdown background color
                      decoration: InputDecoration(
                        hintText: 'Select a problem',
                        hintStyle: TextStyle(fontSize: 20, color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: otherReasonsController,
                    decoration: InputDecoration(
                      hintText: 'Other reasons',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _submitReport(
                    selectedProblem,
                    otherReasonsController.text,
                  );
                  Navigator.pop(context);
                  Get.snackbar(
                    'Report Submitted',
                    'The Admin will review the problem',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary, // Use TColors.primary for the button
                  foregroundColor: Colors.white, // White text
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit',   style: TextStyle(fontSize: 16),),
              ),
            ],
          );
        });
      },
    );
  }
// ... other imports ...
  Future<void> _submitReport(String? selectedProblem, String otherReasons) async {
    final String productId = widget.product.id;
    final String reportId = DateTime.now().microsecondsSinceEpoch.toString(); // Generate unique ID
    final Map<String, dynamic> reportData = {
      'reportId': reportId,
      'productId': productId,
      'selectedProblem': selectedProblem,
      'otherReasons': otherReasons,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Fetch additional item details
    final itemDetails = await ProductService.fetchProductOwnerDetails(widget.product.id ?? 'default-id');
    if (itemDetails != null && itemDetails.containsKey('itemImageUrl') && itemDetails.containsKey('name')) {
      reportData['itemImageUrl'] = itemDetails['itemImageUrl'];
      reportData['itemName'] = itemDetails['name'];
    }

    try {
      // Send the report to the Shelf backend
      final response = await http.post(
        Uri.parse('http://192.168.10.93:3000/save-report'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reportData),
      );

      if (response.statusCode == 200) {
        print('Report submitted successfully');
        Get.snackbar(
          'Report Submitted',
          'The Admin will review the problem',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Failed to submit report: ${response.body}');
      }
    } catch (e) {
      print('Error submitting report: $e');
      Get.snackbar(
        'Error',
        'Failed to submit report',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


}



void _showBoardSelectionDialog(BuildContext context, String productName) {
  final List<String> boards = [
    'Arduino Mega',
    'Arduino Uno',
    'ESP',
    'Raspberry Pi',
  ];

  // Controller for the custom board input
  final TextEditingController customBoardController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: TColors.black, // Use your app's primary color
        title: const Text(
          'Select a Board :',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display board choices with hover effect
            ...boards.map((board) {
              return InkWell(
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  _fetchConnectionDetails(productName, board); // Fetch connection details
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.primary, // Use TColors.primary for the background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    board,
                    style: const TextStyle(fontSize: 16, color: Colors.white), // White text
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Text field for custom board input
            TextField(
              controller: customBoardController,
              decoration: InputDecoration(
                hintText: 'Enter custom board',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 16),

            // Button to submit custom board
            ElevatedButton(
              onPressed: () {
                final customBoard = customBoardController.text.trim();
                if (customBoard.isNotEmpty) {
                  Navigator.pop(context); // Close the dialog
                  _fetchConnectionDetails(productName, customBoard); // Fetch connection details
                } else {
                  Get.snackbar(
                    'Error',
                    'Please enter a custom board name.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary, // Use TColors.primary for the button
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Use Custom Board',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _fetchConnectionDetails(String productName, String board) async {
  const apiKey = 'AIzaSyBHHsH_64xh54o3k-uRdY273kJww7KPprw'; // Replace with your actual API key
  const apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

  final prompt = 'How to connect $productName with $board? Provide a short answer, and give the answer as a list for every pin when to connect as a short and brief answer, give me response like this : Here is the connection guide: 1. Connect pin A to pin B. 2. Connect pin C to pin D.';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);

      // Extract the text response
      final textResponse = responseData['candidates'][0]['content']['parts'][0]['text'];

      // Show the response (text only)
      _showConnectionDetails(textResponse);
    } else {
      throw Exception('Failed to fetch connection details: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
    Get.snackbar(
      'Error',
      'Failed to fetch connection details. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

void _showConnectionDetails(String details) {
  Get.dialog(
    AlertDialog(
      backgroundColor: TColors.black, // Use TColors.black for the background
      title: const Text(
        'Connection Details',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: TColors.white, // Use TColors.primary for the title
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          details,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white, // Use white for the content text
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          style: TextButton.styleFrom(
            backgroundColor: TColors.primary, // Use TColors.primary for the button background
            foregroundColor: Colors.white, // Use white for the button text
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'OK',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

String _generateChatId(String user1, String user2) {
  final List<String> sortedUsernames = [user1, user2]..sort();
  return sortedUsernames.join('_');
}

Future<void> _createOrUpdateChat(String chatId, String user1, String user2) async {
  final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
  final chatDoc = await chatRef.get();
  if (!chatDoc.exists) {
    await chatRef.set({
      'participants': [user1, user2],
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}