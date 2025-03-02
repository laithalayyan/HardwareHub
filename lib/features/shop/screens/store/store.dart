import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/appbar/tabbar.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:t_store/features/shop/screens/store/widgets/category_tab.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/brands/brand_card.dart';
import '../../../../common/widgets/products/products_cards/product_card_vertical.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../config/config.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;



class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryService categoryService = CategoryService();

    return FutureBuilder<List<dynamic>>(
      future: categoryService.fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(body: Center(child: Text('No categories found.')));
        } else {
          final categories = snapshot.data!;

          // Extract main category names for tabs
          final List<Widget> tabs = categories.map((category) {
            return Tab(child: Text(category['name']));
          }).toList();

          // Extract subcategories (or main categories if no subcategories exist) for featured items
          final List<Widget> featuredItems = [];
          for (var category in categories) {
            if (category['subCategories'].isEmpty) {
              // If no subcategories, use the main category
              featuredItems.add(
                FutureBuilder<Map<String, dynamic>>(
                  future: categoryService.fetchCategoryDetails(category['id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No category details found.'));
                    } else {
                      final categoryDetails = snapshot.data!;
                      final itemCount = (categoryDetails['items'] ?? []).length;

                      return TBrandCard(
                        showBorder: true,
                        categoryName: category['name'],
                        count: itemCount, // Pass the item count
                        label: 'Items',
                      );
                    }
                  },
                ),
              );
            } else {
              // If subcategories exist, use them
              for (var subCategory in category['subCategories']) {
                featuredItems.add(
                  FutureBuilder<Map<String, dynamic>>(
                    future: categoryService.fetchSubcategoryDetails(subCategory['id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No subcategory details found.'));
                      } else {
                        final subCategoryDetails = snapshot.data!;
                        final itemCount = (subCategoryDetails['items'] ?? []).length;

                        return TBrandCard(
                          showBorder: true,
                          categoryName: subCategory['name'],
                          count: itemCount, // Pass the item count
                          label: 'Items',
                        );
                      }
                    },
                  ),
                );
              }
            }
          }

          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              appBar: TAppBar(
                title: Text('Items', style: Theme.of(context).textTheme.headlineMedium),
                actions: [
                  TCartCounterIcon(onPressed: () {}),
                ],
              ),
              body: NestedScrollView(
                headerSliverBuilder: (_, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: true,
                      floating: true,
                      backgroundColor: THelperFunctions.isDarkMode(context) ? TColors.black : TColors.white,
                      expandedHeight: 420,
                      flexibleSpace: Padding(
                        padding: const EdgeInsets.all(TSizes.defaultSpace),
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: TSizes.spaceBtwItems),
                            const TSearchContainer(text: 'Search',showBackground: true, padding: EdgeInsets.zero,),
                            const SizedBox(height: TSizes.spaceBtwSections),

                            // Featured Items Types Section
                            TSectionHeading(
                              title: 'Featured Items Types',
                              onPressed: () => Get.to(() => const AllCategoriesScreen()),
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 1.5),

                            // Featured Items Grid
                            TGridLayout(
                              itemCount: featuredItems.length,
                              mainAxisExtent: 80,
                              itemBuilder: (_, index) {
                                return featuredItems[index];
                              },
                            ),
                          ],
                        ),
                      ),
                      bottom: TTabBar(tabs: tabs),
                    ),
                  ];
                },
                body: TabBarView(
                  children: categories.map((category) {
                    return TCategoryTab(categoryId: category['id']);
                  }).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class CategoryService {
  final String baseUrl = AppConfig.baseUrl;
  final GetStorage _storage = GetStorage();

  Future<List<dynamic>> fetchCategories() async {
    final String token = _storage.read('token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/Category/CategoryItem/All'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> fetchCategoryDetails(String categoryId) async {
    final String token = _storage.read('token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/Category/CategoryItem/$categoryId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load category details');
    }
  }

  Future<Map<String, dynamic>> fetchSubcategoryDetails(String subcategoryId) async {
    final String token = _storage.read('token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/Category/SubCategoryItem/$subcategoryId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load subcategory details');
    }
  }
}

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryService categoryService = CategoryService();

    return Scaffold(
      appBar: const TAppBar(
        title: Text('All Categories'),
        showBackArrow: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: categoryService.fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found.'));
          } else {
            final categories = snapshot.data!;
            final List<Widget> categoryCards = [];

            for (var category in categories) {
              if (category['subCategories'].isEmpty) {
                // If no subcategories, use the main category
                categoryCards.add(
                  FutureBuilder<Map<String, dynamic>>(
                    future: categoryService.fetchCategoryDetails(category['id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No category details found.'));
                      } else {
                        final categoryDetails = snapshot.data!;
                        final itemCount = (categoryDetails['items'] ?? []).length;

                        return TBrandCard(
                          showBorder: true,
                          categoryName: category['name'],
                          count: itemCount, // Pass the item count
                          label: 'Items',
                          onTap: () {
                            Get.to(() => CategoryItemsScreen(categoryId: category['id']));
                          },
                        );
                      }
                    },
                  ),
                );
              } else {
                // If subcategories exist, use them
                for (var subCategory in category['subCategories']) {
                  categoryCards.add(
                    FutureBuilder<Map<String, dynamic>>(
                      future: categoryService.fetchSubcategoryDetails(subCategory['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No subcategory details found.'));
                        } else {
                          final subCategoryDetails = snapshot.data!;
                          final itemCount = (subCategoryDetails['items'] ?? []).length;

                          return TBrandCard(
                            showBorder: true,
                            categoryName: subCategory['name'],
                            count: itemCount, // Pass the item count
                            label: 'Items',
                            onTap: () {
                              Get.to(() => CategoryItemsScreen(subcategoryId: subCategory['id']));
                            },
                          );
                        }
                      },
                    ),
                  );
                }
              }
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    const TSectionHeading(
                      title: 'All Categories',
                      showActionButton: false,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    // Categories Grid
                    TGridLayout(
                      itemCount: categoryCards.length,
                      mainAxisExtent: 80,
                      itemBuilder: (context, index) {
                        return categoryCards[index];
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
}

class CategoryItemsScreen extends StatelessWidget {
  final String? categoryId;
  final String? subcategoryId;

  const CategoryItemsScreen({
    super.key,
    this.categoryId,
    this.subcategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Category Items'), // Placeholder title
        showBackArrow: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCategoryOrSubcategoryDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No details found.'));
          } else {
            final data = snapshot.data!;
            final title = data['name'];
            final items = (data['items'] as List<dynamic>).cast<Map<String, dynamic>>(); // Cast to List<Map<String, dynamic>>
            final itemCount = items.length;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    /// Category/Subcategory Detail
                    TBrandCard(
                      showBorder: true,
                      categoryName: title,
                      count: itemCount,
                      label: 'Items',
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Sortable Products Section
                    TSortableProducts(
                      products: items.map((item) {
                        return Product(
                          id: item['id'],
                          name: item['name'],
                          category: title, // Use the category/subcategory name
                          imageUrl: item['itemImageUrl'],
                          price: (item['price'] as num).toDouble(), // Ensure price is double
                          inStock: item['count'] > 0,
                          stockQuantity: item['count'],
                          description: item['description'],
                        );
                      }).toList(),
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

  /// Helper function to fetch category or subcategory details
  Future<Map<String, dynamic>> _fetchCategoryOrSubcategoryDetails() async {
    final GetStorage storage = GetStorage();
    final String token = storage.read('token');
    const String baseUrl = AppConfig.baseUrl;

    try {
      final Uri uri;
      if (categoryId != null) {
        uri = Uri.parse('$baseUrl/api/Category/CategoryItem/$categoryId');
      } else if (subcategoryId != null) {
        uri = Uri.parse('$baseUrl/api/Category/SubCategoryItem/$subcategoryId');
      } else {
        throw Exception('No categoryId or subcategoryId provided');
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch details: $e');
    }
  }
}

/// Product model for TSortableProducts
class Product {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final bool inStock;
  final int stockQuantity;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.inStock,
    required this.stockQuantity,
    required this.description,
  });
}

class TSortableProducts extends StatefulWidget {
  const TSortableProducts({
    super.key,
    required this.products,
  });

  final List<Product> products;

  @override
  State<TSortableProducts> createState() => _TSortableProductsState();
}

class _TSortableProductsState extends State<TSortableProducts> {
  late List<Product> _sortedProducts;
  String _selectedSortOption = 'Name'; // Default sorting option

  @override
  void initState() {
    super.initState();
    _sortedProducts = List.from(widget.products); // Initialize with the original list
    _sortProducts(); // Sort products initially
  }

  void _sortProducts() {
    setState(() {
      switch (_selectedSortOption) {
        case 'Name':
          _sortedProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Higher Price':
          _sortedProducts.sort((a, b) => b.price.compareTo(a.price)); // Descending order
          break;
        case 'Lower Price':
          _sortedProducts.sort((a, b) => a.price.compareTo(b.price)); // Ascending order
          break;
        default:
          _sortedProducts = List.from(widget.products); // Reset to original list
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Dropdown for sorting
        DropdownButtonFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.sort),
          ),
          value: _selectedSortOption,
          onChanged: (value) {
            setState(() {
              _selectedSortOption = value!; // Update the selected sort option
              _sortProducts(); // Sort products based on the new option
            });
          },
          items: [
            'Name',
            'Higher Price',
            'Lower Price',
          ]
              .map(
                (option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        /// Products Grid
        TGridLayout(
          itemCount: _sortedProducts.length,
          itemBuilder: (_, index) {
            final product = _sortedProducts[index];
            return TProductCardVertical(
              productId: product.id,
              name: product.name,
              category: product.category,
              imageUrl: product.imageUrl,
              price: product.price,
              inStock: product.inStock,
              stockQuantity: product.stockQuantity,
              description: product.description,
            );
          },
        ),
      ],
    );
  }
}


