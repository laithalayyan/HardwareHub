import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../common/widgets/products/products_cards/product_card_horizontal.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../config/config.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/login/login.dart';

class SubCategoriesScreen extends StatelessWidget {
  final String categoryId;

  const SubCategoriesScreen({super.key, required this.categoryId});

  Future<Map<String, String>> getHeaders() async {
    final storage = GetStorage();
    final String? token = storage.read('token'); // Retrieve the token

    if (token != null) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Add the token to the headers
      };
    } else {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
      };
    }
  }

  Future<Map<String, dynamic>> fetchCategoryData(String categoryId) async {
    final url = '${AppConfig.baseUrl}/api/Category/CategoryItem/$categoryId'; // Replace with your backend URL
    final headers = await getHeaders(); // Get headers with token
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token is invalid or expired
      Get.offAll(() => const LoginScreen()); // Redirect to login screen
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to load category data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(title: Text('Products'), showBackArrow: true),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchCategoryData(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final categoryData = snapshot.data!;
          final subCategories = categoryData['subCategories'] as List<dynamic>;
          final items = categoryData['items'] as List<dynamic>;
          final categoryName = categoryData['name']; // Get the category name

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// Banner
                  const TRoundedImage(
                    width: double.infinity,
                    imageUrl: TImages.promoBanner3,
                    applyImageRadius: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Check if there are subcategories
                  if (subCategories.isNotEmpty)
                    Column(
                      children: [
                        /// Heading
                        TSectionHeading(
                          title: 'Sub Categories',
                          onPressed: () {},
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),

                        /// Sub-Category List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subCategories.length,
                          itemBuilder: (context, index) {
                            final subCategory = subCategories[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subCategory['name'],
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: TSizes.spaceBtwItems / 2),

                                /// Items for Sub-Category
                                if (subCategory['items'] != null)
                                  SizedBox(
                                    height: 120,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: subCategory['items'].length,
                                      separatorBuilder: (context, index) =>
                                      const SizedBox(width: TSizes.spaceBtwItems),
                                      itemBuilder: (context, index) {
                                        final item = subCategory['items'][index];
                                        return TProductCardHorizontal(
                                          productId: item['id'],
                                          name: item['name'],
                                          imageUrl: item['itemImageUrl'],
                                          price: item['price'].toString(),
                                          categoryName: subCategory['name'], // Pass subcategory name
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: TSizes.spaceBtwSections),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

                  /// If there are no subcategories, display items directly
                  if (subCategories.isEmpty && items.isNotEmpty)
                    Column(
                      children: [
                        /// Heading
                        TSectionHeading(
                          title: 'Products',
                          onPressed: () {},
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),

                        /// Items List
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(width: TSizes.spaceBtwItems),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return TProductCardHorizontal(
                                productId: item['id'],
                                name: item['name'],
                                imageUrl: item['itemImageUrl'],
                                price: item['price'].toString(),
                                categoryName: categoryName, // Pass main category name
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}