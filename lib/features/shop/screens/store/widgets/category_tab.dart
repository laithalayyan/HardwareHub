/*import 'package:flutter/material.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/products_cards/product_card_vertical.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';

import '../../../../../common/widgets/brands/brand_show_case.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';

class TCategoryTab extends StatelessWidget {
  const TCategoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated product IDs
    final productIds = ['prod5', 'prod6', 'prod7', 'prod8'];

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// -- Brands
              const TBrandShowcase(
                images: [
                  TImages.productImage1,
                  TImages.productImage1,
                  TImages.productImage1
                ],
              ),
              const TBrandShowcase(
                images: [
                  TImages.productImage1,
                  TImages.productImage1,
                  TImages.productImage1
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// -- Products
              TSectionHeading(title: 'You might like', onPressed: () {}),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Grid Layout for Products
              TGridLayout(
                itemCount: productIds.length,
                itemBuilder: (_, index) => TProductCardVertical(
                  productId: productIds[index], // Pass unique product ID
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ],
    );
  }
}*/ //old code


import 'package:flutter/material.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/products_cards/product_card_vertical.dart';

import '../../../../../common/widgets/brands/brand_show_case.dart';
import '../../../../../utils/constants/sizes.dart';
import '../store.dart';

class TCategoryTab extends StatelessWidget {
  final String categoryId;

  const TCategoryTab({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final CategoryService categoryService = CategoryService();

    return FutureBuilder<Map<String, dynamic>>(
      future: categoryService.fetchCategoryDetails(categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No category details found.'));
        } else {
          final category = snapshot.data!;
          final List<dynamic> subCategories = category['subCategories'] ?? [];
          final List<dynamic> items = category['items'] ?? [];

          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    /// -- Subcategories (Brands)
                    if (subCategories.isNotEmpty)
                      Column(
                        children: subCategories.map((subCategory) {
                          final List<dynamic> subCategoryItems = subCategory['items'] ?? [];
                          final List<String> images = subCategoryItems
                              .take(3)
                              .map((item) => item['itemImageUrl'] as String)
                              .toList();

                          return TBrandShowcase(
                            images: images,
                            categoryName: subCategory['name'],
                            projectCount: subCategoryItems.length,
                          );
                        }).toList(),
                      ),

                    //const SizedBox(height: TSizes.spaceBtwItems),

                    /// -- Products
                    //TSectionHeading(title: 'You might like', onPressed: () {}),
                    //const SizedBox(height: TSizes.spaceBtwItems),

                    /// Grid Layout for Products
                    /*TGridLayout(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return TProductCardVertical(
                          productId: item['id'],
                          name: item['name'],
                          description: item['description'],
                          price: item['price'].toDouble(),
                          stockQuantity: item['count'],
                          inStock: item['count'] > 0,
                          imageUrl: item['itemImageUrl'],
                          category: '',
                        );
                      },
                    ), */
                    TGridLayout(
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];
                        final subcategoryName = subCategories
                            .firstWhere(
                              (subCat) => subCat['items'].any((i) => i['id'] == item['id']),
                          orElse: () => {'name': 'Uncategorized'},
                        )['name'];

                        return TProductCardVertical(
                          productId: item['id'],
                          name: item['name'],
                          description: item['description'],
                          price: item['price'].toDouble(),
                          stockQuantity: item['count'],
                          inStock: item['count'] > 0,
                          imageUrl: item['itemImageUrl'],
                          category: category['name'], // Main category name
                          //subcategory: subcategoryName, // Subcategory name
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
