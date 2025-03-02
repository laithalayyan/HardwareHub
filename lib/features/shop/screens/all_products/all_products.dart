import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'dart:convert';

import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/products_cards/product_card_vertical.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../data/products_data/product_model.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../config/config.dart'; // Ensure this import points to your config file

class AllProducts extends StatelessWidget {
  const AllProducts({super.key});

  // Function to fetch all products without a count parameter
  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    //const baseUrl = '${AppConfig.baseUrl}/api/Recommendations'; // Base URL without query parameters
    const baseUrl = '${AppConfig.baseUrl}/api/items'; // Base URL without query parameters

    // Initialize GetStorage
    final storage = GetStorage();

    // Retrieve the token from GetStorage
    final token = storage.read('token');
    if (token == null) {
      throw Exception('Token not found in GetStorage');
    }

    // Construct the URL without the count parameter
    final url = Uri.parse(baseUrl);

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
      throw Exception('Failed to load products');
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
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Popular Products'),
        showBackArrow: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllProducts(), // Fetch all products
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Show error message
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.')); // Show empty state
          } else {
            final products = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: TSortableProducts(products: products), // Pass the fetched products
              ),
            );
          }
        },
      ),
    );
  }
}


class TSortableProducts extends StatefulWidget {
  const TSortableProducts({
    super.key,
    required this.products,
  });

  final List<Map<String, dynamic>> products;

  @override
  State<TSortableProducts> createState() => _TSortableProductsState();
}

class _TSortableProductsState extends State<TSortableProducts> {
  String _selectedSortOption = 'Name'; // Default sort option
  List<Product> _sortedProducts = []; // Use List<Product> instead of List<Map<String, dynamic>>

  @override
  void initState() {
    super.initState();
    // Convert List<Map<String, dynamic>> to List<Product>
    _sortedProducts = widget.products.map((product) {
      return Product(
        id: product['id'] ?? '',
        name: product['name'] ?? '',
        category: product['category'] ?? 'Uncategorized',
        imageUrl: product['itemImageUrl'] ?? '',
        price: product['price']?.toDouble() ?? 0.0,
        inStock: product['count'] > 0,
        stockQuantity: product['count'] ?? 0,
        description: product['description'] ?? '',
      );
    }).toList();
    _sortProducts(); // Sort products initially
  }

  void _sortProducts() {
    setState(() {
      switch (_selectedSortOption) {
        case 'Name':
          _sortedProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Higher Price':
          _sortedProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Lower Price':
          _sortedProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        default:
          _sortedProducts = List.from(_sortedProducts);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Dropdown for Sorting
        DropdownButtonFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.sort),
          ),
          value: _selectedSortOption,
          onChanged: (value) {
            setState(() {
              _selectedSortOption = value.toString();
              _sortProducts(); // Sort products when the dropdown value changes
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