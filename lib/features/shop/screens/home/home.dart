import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/products_cards/product_card_vertical.dart';
import 'package:t_store/features/shop/screens/all_products/all_products.dart';
import 'package:t_store/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:t_store/features/shop/screens/home/widgets/home_categories.dart';
import 'package:t_store/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:t_store/utils/constants/sizes.dart';

import '../../../../ChatBotScreen.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/products/products_cards/project_card_vertical.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../config/config.dart';
import '../../../../data/products_data/product_service.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../data/project_data/project_service.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /*
  Future<List<Map<String, dynamic>>> fetchRecommendedProducts() async {
    const baseUrl = '${AppConfig.baseUrl}/api/Recommendations'; // Base URL without query parameters
    //const baseUrl = '${AppConfig.baseUrl}/api/items';
    const count = 4; // Number of recommendations to fetch

    // Initialize GetStorage
    final storage = GetStorage();

    // Retrieve the token from GetStorage
    final token = storage.read('token');
    if (token == null) {
      throw Exception('Token not found in GetStorage');
    }

    // Construct the URL with the query parameter
    final url = Uri.parse('$baseUrl?count=$count');

    // Make the HTTP request with authorization header
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Decode the JSON response and explicitly cast it to List<Map<String, dynamic>>
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> products = data.cast<Map<String, dynamic>>();

      // Fetch the list of categories
      final categories = await fetchCategories(token);

      // Replace categoryItemId with category name
      final productsWithCategoryNames = products.map((product) {
        final categoryItemId = product['categoryItemId'];
        final category = categories.firstWhere(
              (category) => category['id'] == categoryItemId,
          orElse: () => {'name': 'Unknown'}, // Default if category not found
        );
        return {
          ...product,
          'category': category['name'], // Replace categoryItemId with category name
        };
      }).toList();

      return productsWithCategoryNames;
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load recommended products');
    }
  }
  */

  Future<List<Map<String, dynamic>>> fetchRecommendedProducts() async {
    //const baseUrl = '${AppConfig.baseUrl}/api/Recommendations'; // Base URL without query parameters
    const baseUrl = '${AppConfig.baseUrl}/api/items';

    // Initialize GetStorage
    final storage = GetStorage();

    // Retrieve the token from GetStorage
    final token = storage.read('token');
    if (token == null) {
      throw Exception('Token not found in GetStorage');
    }

    // Construct the URL with the query parameter
    final url = Uri.parse('$baseUrl');

    // Make the HTTP request with authorization header
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Decode the JSON response and explicitly cast it to List<Map<String, dynamic>>
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> products = data.cast<Map<String, dynamic>>();

      // Fetch the list of categories
      final categories = await fetchCategories(token);

      // Replace categoryItemId with category name
      final productsWithCategoryNames = products.map((product) {
        final categoryItemId = product['categoryItemId'];
        final category = categories.firstWhere(
              (category) => category['id'] == categoryItemId,
          orElse: () => {'name': 'Unknown'}, // Default if category not found
        );
        return {
          ...product,
          'category': category['name'], // Replace categoryItemId with category name
        };
      }).toList();

      return productsWithCategoryNames;
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load recommended products');
    }
  }

  // Fetch categories from the API
  Future<List<Map<String, dynamic>>> fetchCategories(String token) async {
    const categoriesUrl = '${AppConfig.baseUrl}/api/Category/CategoryItem/All';

    final response = await http.get(
      Uri.parse(categoriesUrl),
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    if (response.statusCode == 200) {
      // Decode the JSON response and explicitly cast it to List<Map<String, dynamic>>
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Failed to fetch categories: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to fetch categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final projects = ProjectService.getProjects();
    // Fetch products from ProductService
    final products = ProductService.getProducts();

    return Scaffold(
      //backgroundColor: const Color(0xfff3f8fa),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                /// Header Section
                TPrimaryHeaderContainer(
                  child: Column(
                    children: [
                      /// Appbar
                      const SizedBox(height: 10),
                      const THomeAppBar(),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Searchbar
                      const TSearchContainer(text: 'Search in Store'),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Categories & Heading
                      Padding(
                        padding: const EdgeInsets.only(left: TSizes.defaultSpace),
                        child: Column(
                          children: [
                            /// Heading
                            const TSectionHeading(title: 'Popular Categories', showActionButton: false, textColor: Colors.white,),
                            const SizedBox(height: TSizes.spaceBtwItems),

                            /// Categories
                            THomeCatigories(),
                          ],
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                    ],
                  ),
                ),

                /// Body Section
                Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    children: [
                      /// Promo Slider
                      const TPromoSlider(
                        banners: [
                          TImages.promoBanner1,
                          TImages.promoBanner2,
                          TImages.promoBanner3
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Heading - Popular Products
                      TSectionHeading(title: 'Products You Might Like', onPressed: () => Get.to(() => const AllProducts())),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Popular Products Grid
                      /// Recommended Products Grid
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchRecommendedProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // Show error message
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No recommended products found.'); // Show empty state
                          } else {
                            final recommendedProducts = snapshot.data!;
                            return TGridLayout(
                              itemCount: 4,
                              itemBuilder: (_, index) {
                                final product = recommendedProducts[index];
                                return TProductCardVertical(
                                  productId: product['id'],
                                  name: product['name'],
                                  category: product['category'] ?? 'Uncategorized', // Use 'category' instead of 'categoryItemId'
                                  imageUrl: product['itemImageUrl'],
                                  price: product['price']?.toDouble() ?? 0.0,
                                  inStock: product['count'] > 0,
                                  stockQuantity: product['count'],
                                  description: product['description'] ?? '',
                                );
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Heading - Popular Projects
                      TSectionHeading(title: 'Projects You Might Like', onPressed: () {}),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Popular Projects
                      /// Popular Projects
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: ProjectService().fetchProjects(), // Fetch projects from backend
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // Show error message
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No projects found.'); // Show empty state
                          } else {
                            final projects = snapshot.data!;
                            return TGridLayout(
                              itemCount: 4,
                              itemBuilder: (_, index) {
                                final project = projects[index];
                                final List<String> imageUrls = (project['projectImageUrl'] as List<dynamic>).cast<String>();

                                return TProjectCardVertical(
                                  project: Project(
                                    id: project['id'],
                                    name: project['name'],
                                    category: project['category'] ?? 'Uncategorized',
                                    imageUrls: imageUrls,
                                    description: project['description'] ?? '',
                                    cost: project['cost']?.toDouble() ?? 0.0,
                                  ),
                                );
                              },
                              mainAxisExtent: 255,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Fixed Chat Icon
          Positioned(
            right: 16.0, // Adjust the left position as needed
            bottom: 16.0, // Adjust the bottom position as needed
            child: GestureDetector(
              onTap: () {
                // Navigate to the ChatBotScreen
                Get.to(const ChatBotScreen());
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3), // Shadow color
                      spreadRadius: 1, // Spread radius
                      blurRadius: 16, // Blur radius
                      offset: const Offset(0, 4), // Shadow position
                    ),
                  ],
                  borderRadius: BorderRadius.circular(35), // Adjust for circular shadow
                ),
                child: Image.asset(
                  TImages.chatBot, // Path to your custom icon
                  width: 60, // Adjust the size as needed
                  height: 60, // Adjust the size as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/products_cards/product_card_vertical.dart';
import 'package:t_store/features/shop/screens/all_products/all_products.dart';
import 'package:t_store/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:t_store/features/shop/screens/home/widgets/home_categories.dart';
import 'package:t_store/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:t_store/utils/constants/sizes.dart';

import '../../../../ChatBotScreen.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/products/products_cards/project_card_vertical.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../config/config.dart';
import '../../../../data/products_data/product_service.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../data/project_data/project_service.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../../authentication/screens/login/login.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  Future<List<Map<String, dynamic>>> fetchRecommendedProducts() async {
    const baseUrl = '${AppConfig.baseUrl}/api/Recommendations'; // Base URL without query parameters
    const count = 4; // Number of recommendations to fetch

    // Initialize GetStorage
    final storage = GetStorage();

    // Retrieve the token from GetStorage
    final token = storage.read('token');
    if (token == null) {
      throw Exception('Token not found in GetStorage');
    }

    // Construct the URL with the query parameter
    final url = Uri.parse('$baseUrl?count=$count');

    // Make the HTTP request with authorization header
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Decode the JSON response and explicitly cast it to List<Map<String, dynamic>>
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> products = data.cast<Map<String, dynamic>>();

      // Fetch the list of categories
      final categories = await fetchCategories(token);

      // Replace categoryItemId with category name
      final productsWithCategoryNames = products.map((product) {
        final categoryItemId = product['categoryItemId'];
        final category = categories.firstWhere(
              (category) => category['id'] == categoryItemId,
          orElse: () => {'name': 'Unknown'}, // Default if category not found
        );
        return {
          ...product,
          'category': category['name'], // Replace categoryItemId with category name
        };
      }).toList();

      return productsWithCategoryNames;
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load recommended products');
    }
  }

  // Fetch categories from the API
  Future<List<Map<String, dynamic>>> fetchCategories(String token) async {
    const categoriesUrl = '${AppConfig.baseUrl}/api/Category/CategoryItem/All';

    final response = await http.get(
      Uri.parse(categoriesUrl),
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    if (response.statusCode == 200) {
      // Decode the JSON response and explicitly cast it to List<Map<String, dynamic>>
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Failed to fetch categories: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to fetch categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final projects = ProjectService.getProjects();
    // Fetch products from ProductService
    final products = ProductService.getProducts();

    return Scaffold(
      //backgroundColor: const Color(0xfff3f8fa),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                /// Header Section
                TPrimaryHeaderContainer(
                  child: Column(
                    children: [
                      /// Appbar
                      const SizedBox(height: 10),
                      const THomeAppBar(),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Searchbar
                      const TSearchContainer(text: 'Search in Store'),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Categories & Heading
                      Padding(
                        padding: const EdgeInsets.only(left: TSizes.defaultSpace),
                        child: Column(
                          children: [
                            /// Heading
                            const TSectionHeading(title: 'Popular Categories', showActionButton: false, textColor: Colors.white,),
                            const SizedBox(height: TSizes.spaceBtwItems),

                            /// Categories
                            THomeCatigories(),
                          ],
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                    ],
                  ),
                ),

                /// Body Section
                Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    children: [
                      /// Promo Slider
                      const TPromoSlider(
                        banners: [
                          TImages.promoBanner1,
                          TImages.promoBanner2,
                          TImages.promoBanner3
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Heading - Popular Products
                      TSectionHeading(title: 'Products You Might Like', onPressed: () => Get.to(() => const AllProducts())),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Popular Products Grid
                      /// Recommended Products Grid
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchRecommendedProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // Show error message
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No recommended products found.'); // Show empty state
                          } else {
                            final recommendedProducts = snapshot.data!;
                            return TGridLayout(
                              itemCount: recommendedProducts.length,
                              itemBuilder: (_, index) {
                                final product = recommendedProducts[index];
                                return TProductCardVertical(
                                  productId: product['id'],
                                  name: product['name'],
                                  category: product['category'] ?? 'Uncategorized', // Use 'category' instead of 'categoryItemId'
                                  imageUrl: product['itemImageUrl'],
                                  price: product['price']?.toDouble() ?? 0.0,
                                  inStock: product['count'] > 0,
                                  stockQuantity: product['count'],
                                  description: product['description'] ?? '',
                                );
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Heading - Popular Projects
                      TSectionHeading(title: 'Projects You Might Like', onPressed: () {}),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Popular Projects
                      /// Popular Projects
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: ProjectService().fetchProjects(), // Fetch projects from backend
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // Show error message
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No projects found.'); // Show empty state
                          } else {
                            final projects = snapshot.data!;
                            return TGridLayout(
                              itemCount: projects.length,
                              itemBuilder: (_, index) {
                                final project = projects[index];
                                final List<String> imageUrls = (project['projectImageUrl'] as List<dynamic>).cast<String>();

                                return TProjectCardVertical(
                                  project: Project(
                                    id: project['id'],
                                    name: project['name'],
                                    category: project['category'] ?? 'Uncategorized',
                                    imageUrls: imageUrls,
                                    description: project['description'] ?? '',
                                    cost: project['cost']?.toDouble() ?? 0.0,
                                  ),
                                );
                              },
                              mainAxisExtent: 255,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Fixed Chat Icon
          Positioned(
            right: 16.0, // Adjust the left position as needed
            bottom: 16.0, // Adjust the bottom position as needed
            child: GestureDetector(
              onTap: () {
                // Navigate to the ChatBotScreen
                Get.to(const ChatBotScreen());
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3), // Shadow color
                      spreadRadius: 1, // Spread radius
                      blurRadius: 16, // Blur radius
                      offset: const Offset(0, 4), // Shadow position
                    ),
                  ],
                  borderRadius: BorderRadius.circular(35), // Adjust for circular shadow
                ),
                child: Image.asset(
                  TImages.chatBot, // Path to your custom icon
                  width: 60, // Adjust the size as needed
                  height: 60, // Adjust the size as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/

/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:t_store/features/shop/screens/home/widgets/home_appbar.dart';

import 'package:t_store/features/shop/screens/home/widgets/home_categories.dart';
import 'package:t_store/features/shop/screens/home/widgets/promo_slider.dart';

import '../../../../ChatBotScreen.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/products_cards/product_card_vertical.dart';
import '../../../../common/widgets/products/products_cards/project_card_vertical.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../config/config.dart';
import '../../../../data/products_data/product_service.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../data/project_data/project_service.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/login/login.dart';
import '../all_products/all_products.dart';

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../ChatBotScreen.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/products_cards/product_card_vertical.dart';
import '../../../../common/widgets/products/products_cards/project_card_vertical.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../config/config.dart';
import '../../../../data/products_data/product_service.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../data/project_data/project_service.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/login/login.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // To store the selected image

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
        final uploadId = await uploadImage(pickedImage); // Upload the image
        if (uploadId != null) {
          await searchWithImage(uploadId); // Search with the uploaded image ID
        } else {
          Get.snackbar('Error', 'Failed to upload image.');
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String?> uploadImage(XFile image) async {
    const apiKey = 'acc_1fd57db5b0cb777'; // Replace with your Imagga API key
    const apiSecret = '2e0cb69fc45a40371764ac41b757afc4'; // Replace with your Imagga API secret
    final url = Uri.parse('https://api.imagga.com/v2/uploads');

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}'
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response to get the upload ID
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['result']['upload_id']; // Return the upload ID
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> searchWithImage(String uploadId) async {
    const apiKey = 'acc_1fd57db5b0cb777'; // Replace with your Imagga API key
    const apiSecret = '2e0cb69fc45a40371764ac41b757afc4'; // Replace with your Imagga API secret
    final url = Uri.parse('https://api.imagga.com/v2/tags?image_upload_id=$uploadId');

    // Predefined list of hardware-related keywords
    final hardwareKeywords = {
      'ultrasonic','motor', 'stepper', 'servo', 'dc motor', 'driver', 'sensor',
      'actuator', 'encoder', 'relay', 'ultrasonic sensor', 'circuit',
      'electric motor', 'stepper motor', 'servo motor', 'dc motor driver',
      'sensor module', 'circuit board', 'electronics', 'hardware',
    };

    const confidenceThreshold = 00.0; // Only include tags with confidence >= 50%

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tags = data['result']['tags'] as List?;
        if (tags != null && tags.isNotEmpty) {
          // Filter tags based on confidence and hardware keywords
          final hardwareTags = tags
              .where((item) =>
          hardwareKeywords.contains(item['tag']['en'].toLowerCase()) &&
              item['confidence'] >= confidenceThreshold)
              .map((item) => item['tag']['en'] as String)
              .toList();

          if (hardwareTags.isNotEmpty) {
            _showSearchResults(hardwareTags);
          } else {
            Get.snackbar('Info', 'No hardware-related tags found.');
          }
        } else {
          Get.snackbar('Info', 'No tags found for the image.');
        }
      } else {
        throw Exception('Failed to fetch tags: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to search for tags.');
    }
  }

  Future<void> analyzeImage(String imageUrl) async {
    final apiUrl = 'https://your-computer-vision-api.com/analyze';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image_url': imageUrl}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final labels = data['labels']; // Assuming the API returns labels
      print('Identified Objects: $labels');
    } else {
      print('Failed to analyze image');
    }
  }

  void testSearchWithImage() async {
    const testImageUrl = 'https://graduation-project-v1.s3.us-east-1.amazonaws.com/images/1d22f4a8-a3fe-4eca-a886-fd1247eea6c5.webp'; // Replace with a valid image URL
    await analyzeImage(testImageUrl);
  }

  void _showSearchResults(List<String> tags) {
    print('Tags: $tags'); // Debug log
    Get.dialog(
      AlertDialog(
        title: const Text('Search Results'),
        content: SingleChildScrollView(
          child: Column(
            children: tags.map((tag) {
              return ListTile(
                title: Text(tag),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>> getHeaders() async {
    final storage = GetStorage();
    final token = storage.read('token'); // Retrieve token from GetStorage

    if (token == null) {
      Get.offAll(() => const LoginScreen()); // Redirect to login screen if token is missing
      throw Exception('Token not found.');
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> fetchRecommendedProducts() async {
    const baseUrl = '${AppConfig.baseUrl}/api/Recommendations'; // Base URL without query parameters
    const count = 4; // Number of recommendations to fetch

    // Initialize GetStorage
    final storage = GetStorage();

    // Retrieve the token from GetStorage
    final token = storage.read('token');
    if (token == null) {
      throw Exception('Token not found in GetStorage');
    }

    // Construct the URL with the query parameter
    final url = Uri.parse('$baseUrl?count=$count');

    // Make the HTTP request with authorization header
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Decode the JSON response and explicitly cast it to List<Map<String, dynamic>>
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> products = data.cast<Map<String, dynamic>>();

      // Fetch the list of categories
      final categories = await fetchCategories(token);

      // Replace categoryItemId with category name
      final productsWithCategoryNames = products.map((product) {
        final categoryItemId = product['categoryItemId'];
        final category = categories.firstWhere(
              (category) => category['id'] == categoryItemId,
          orElse: () => {'name': 'Unknown'}, // Default if category not found
        );
        return {
          ...product,
          'category': category['name'], // Replace categoryItemId with category name
        };
      }).toList();

      return productsWithCategoryNames;
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load recommended products');
    }
  }

  // Fetch categories from the API
  Future<List<Map<String, dynamic>>> fetchCategories(String token) async {
    const categoriesUrl = '${AppConfig.baseUrl}/api/Category/CategoryItem/All';

    final response = await http.get(
      Uri.parse(categoriesUrl),
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    if (response.statusCode == 200) {
      // Decode the JSON response and explicitly cast it to List<Map<String, dynamic>>
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Failed to fetch categories: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to fetch categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch products from ProductService
    final products = ProductService.getProducts();

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                /// Header Section
                TPrimaryHeaderContainer(
                  child: Column(
                    children: [
                      /// Appbar
                      const SizedBox(height: 10),
                      const THomeAppBar(),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Searchbar
                      const TSearchContainer(text: 'Search in Store'),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Categories & Heading
                      Padding(
                        padding: const EdgeInsets.only(left: TSizes.defaultSpace),
                        child: Column(
                          children: [
                            /// Heading
                            const TSectionHeading(title: 'Popular Categories', showActionButton: false, textColor: Colors.white,),
                            const SizedBox(height: TSizes.spaceBtwItems),

                            /// Categories
                            THomeCatigories(),
                          ],
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                    ],
                  ),
                ),

                /// Body Section
                Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    children: [
                      /// Promo Slider
                      const TPromoSlider(
                        banners: [
                          TImages.promoBanner1,
                          TImages.promoBanner2,
                          TImages.promoBanner3
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      /// Heading - Popular Products
                      TSectionHeading(title: 'Products You Might Like', onPressed: () => Get.to(() => const AllProducts())),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Popular Products Grid
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchRecommendedProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // Show error message
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No recommended products found.'); // Show empty state
                          } else {
                            final recommendedProducts = snapshot.data!;
                            return TGridLayout(
                              itemCount: recommendedProducts.length,
                              itemBuilder: (_, index) {
                                final product = recommendedProducts[index];
                                return TProductCardVertical(
                                  productId: product['id'],
                                  name: product['name'],
                                  category: product['category'] ?? 'Uncategorized', // Use 'category' instead of 'categoryItemId'
                                  imageUrl: product['itemImageUrl'],
                                  price: product['price']?.toDouble() ?? 0.0,
                                  inStock: product['count'] > 0,
                                  stockQuantity: product['count'],
                                  description: product['description'] ?? '',
                                );
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Heading - Popular Projects
                      TSectionHeading(title: 'Projects You Might Like', onPressed: () {}),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Popular Projects
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: ProjectService().fetchProjects(), // Fetch projects from backend
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // Show error message
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No projects found.'); // Show empty state
                          } else {
                            final projects = snapshot.data!;
                            return TGridLayout(
                              itemCount: projects.length,
                              itemBuilder: (_, index) {
                                final project = projects[index];
                                final List<String> imageUrls = (project['projectImageUrl'] as List<dynamic>).cast<String>();

                                return TProjectCardVertical(
                                  project: Project(
                                    id: project['id'],
                                    name: project['name'],
                                    category: project['category'] ?? 'Uncategorized',
                                    imageUrls: imageUrls,
                                    description: project['description'] ?? '',
                                    cost: project['cost']?.toDouble() ?? 0.0,
                                  ),
                                );
                              },
                              mainAxisExtent: 255,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Fixed Chat Icon
          Positioned(
            right: 16.0, // Adjust the left position as needed
            bottom: 16.0, // Adjust the bottom position as needed
            child: GestureDetector(
              onTap: () {
                // Navigate to the ChatBotScreen
                Get.to(const ChatBotScreen());
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3), // Shadow color
                      spreadRadius: 1, // Spread radius
                      blurRadius: 16, // Blur radius
                      offset: const Offset(0, 4), // Shadow position
                    ),
                  ],
                  borderRadius: BorderRadius.circular(35), // Adjust for circular shadow
                ),
                child: Image.asset(
                  TImages.chatBot, // Path to your custom icon
                  width: 60, // Adjust the size as needed
                  height: 60, // Adjust the size as needed
                ),
              ),
            ),
          ),
          Positioned(
            left: 16.0, // Adjust the left position as needed
            bottom: 16.0, // Adjust the bottom position as needed
            child: GestureDetector(
              onTap: () {
                testSearchWithImage();
                //_pickImage(); // Open gallery to pick an image
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3), // Shadow color
                      spreadRadius: 1, // Spread radius
                      blurRadius: 16, // Blur radius
                      offset: const Offset(0, 4), // Shadow position
                    ),
                  ],
                  borderRadius: BorderRadius.circular(35), // Adjust for circular shadow
                ),
                child: const Icon(
                  Icons.image, // Image icon
                  size: 60, // Adjust the size as needed
                  color: TColors.primary, // Use your app's primary color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/