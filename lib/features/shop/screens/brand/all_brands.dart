import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/brands/brand_card.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../data/project_data/project_service.dart';
import 'brand_products_proj.dart';

class AllBrandsScreen extends StatelessWidget {
  const AllBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch categories and project counts
    final ProjectService projectService = ProjectService();

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Categories'),
        showBackArrow: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCategoriesWithCount(projectService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          } else {
            final categories = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    /// Heading
                    const TSectionHeading(
                      title: 'Projects Categories',
                      showActionButton: false,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// -- Categories Grid
                    TGridLayout(
                      itemCount: categories.length,
                      mainAxisExtent: 80,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return TBrandCard(
                          showBorder: true,
                          onTap: () {
                            // Navigate to a screen showing projects for this category
                            Get.to(() => BrandProductsProj(categoryId: category['id']));
                            //Get.to(() => const BrandProducts());
                          },
                          categoryName: category['name'],
                          count: category['projectCount'],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Helper function to fetch categories with project counts
  Future<List<Map<String, dynamic>>> _fetchCategoriesWithCount(ProjectService projectService) async {
    try {
      final categories = await projectService.fetchCategories();
      final List<Map<String, dynamic>> categoriesWithCount = [];

      for (var category in categories) {
        final projects = await projectService.fetchProjectsByCategory(category['id']);
        categoriesWithCount.add({
          'id': category['id'],
          'name': category['name'],
          'projectCount': projects.length,
        });
      }

      return categoriesWithCount;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}