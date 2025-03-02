import 'package:flutter/material.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/brands/brand_card.dart';
import '../../../../common/widgets/products/sortable/sortable_products.dart';
import '../../../../data/project_data/project_service.dart'; // Import ProjectService
import '../../../../utils/constants/sizes.dart';

class BrandProductsProj extends StatelessWidget {
  final String categoryId;

  const BrandProductsProj({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final ProjectService projectService = ProjectService();

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Category Details'), // Placeholder title
        showBackArrow: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCategoryDetails(projectService, categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No category details found.'));
          } else {
            final category = snapshot.data!;
            final categoryName = category['name'];
            final projectCount = category['projectCount'];
            final projects = category['projects'];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    /// Brand Detail
                    TBrandCard(
                      showBorder: true,
                      categoryName: categoryName,
                      count: projectCount,
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Sortable Products Section
                    TSortableProducts(products: projects),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Helper function to fetch category details and projects
  Future<Map<String, dynamic>> _fetchCategoryDetails(
      ProjectService projectService, String categoryId) async {
    try {
      // Fetch category details
      final categories = await projectService.fetchCategories();
      final category = categories.firstWhere(
            (cat) => cat['id'] == categoryId,
        orElse: () => throw Exception('Category not found'),
      );

      // Fetch projects for the category
      final projects = await projectService.fetchProjectsByCategory(categoryId);

      return {
        'id': category['id'],
        'name': category['name'],
        'projectCount': projects.length,
        'projects': projects,
      };
    } catch (e) {
      throw Exception('Failed to fetch category details: $e');
    }
  }
}