/*
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../config/config.dart';
import '../../../../data/products_data/product_model.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../features/shop/screens/product_details/product_detail.dart';
import '../../../../features/shop/screens/project_details/project_details.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helpers/helper_functions.dart';

class TSearchContainer extends StatefulWidget {
  const TSearchContainer({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
    this.showBackground = true,
    this.padding = const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
  });

  final String text;
  final IconData? icon;
  final bool showBackground;
  final EdgeInsetsGeometry padding;

  @override
  _TSearchContainerState createState() => _TSearchContainerState();
}

class _TSearchContainerState extends State<TSearchContainer> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> items = [];
  List<dynamic> projects = [];
  final box = GetStorage();
  OverlayEntry? _overlayEntry;
  List<dynamic> categories = [];


  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final token = box.read('token');
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Category'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load categories data');
    }

  }


  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    final token = box.read('token');
    final headers = {'Authorization': 'Bearer $token'};

    final itemsResponse = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Items/$query'),
      headers: headers,
    );

    final projectsResponse = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Projects/$query'),
      headers: headers,
    );

    if (itemsResponse.statusCode == 200) {
      setState(() {
        items = json.decode(itemsResponse.body);
      });
    }

    if (projectsResponse.statusCode == 200) {
      setState(() {
        projects = json.decode(projectsResponse.body);
      });
    }

    _showOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 8,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: THelperFunctions.isDarkMode(context) ? TColors.dark : TColors.light,
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (items.isNotEmpty) ...[
                  const Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...items.map((item) => ListTile(
                    title: Text(item['name']),
                    subtitle: Text('\$${item['price']}'),
                    onTap: () {
                      _removeOverlay();
                      String categoryName = '';
                      if(categories.isNotEmpty){
                        final category = categories.firstWhere((element) => element['id'] == item['categoryItemId'], orElse: () => null);
                        categoryName = category != null ? category['name'] : '';
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: Product(
                              id: item['id'],
                              name: item['name'],
                              category: categoryName,
                              imageUrl: item['itemImageUrl'],
                              price: item['price'].toDouble(),
                              inStock: item['count'] > 0,
                              stockQuantity: item['count'],
                              description: item['description'],
                            ),
                          ),
                        ),
                      );
                    },
                  )).toList(),
                ],
                if (projects.isNotEmpty) ...[
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const Text('Projects:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...projects.map((project) => ListTile(
                    title: Text(project['name']),
                    subtitle: Text('\$${project['cost']}'),
                    onTap: () {
                      _removeOverlay();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsScreen(
                            project: Project(
                              id: project['id'],
                              name: project['name'],
                              category: project['category'],
                              imageUrls: (project['projectImageUrl'] as List<dynamic>?)
                                  ?.map((e) => e?.toString())
                                  .whereType<String>()
                                  .toList() ?? [],
                              description: project['description'] ?? '',
                              cost: project['cost'].toDouble(),
                              userId: project['userId'] ?? '',
                            ),
                          ),
                        ),
                      );
                    },
                  )).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final textColor = dark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Padding(
        padding: widget.padding,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 0.7),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            color: widget.showBackground ? dark ? TColors.dark : TColors.light : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(TSizes.sm),
            child: Row(
              children: [
                const SizedBox(width: TSizes.spaceBtwItems),
                Icon(widget.icon, color: TColors.darkerGrey),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: widget.text,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                    onChanged: _search,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../config/config.dart';
import '../../../../data/products_data/product_model.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../features/shop/screens/product_details/product_detail.dart';
import '../../../../features/shop/screens/project_details/project_details.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helpers/helper_functions.dart';

class TSearchContainer extends StatefulWidget {
  const TSearchContainer({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
    this.showBackground = true,
    this.padding = const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
  });

  final String text;
  final IconData? icon;
  final bool showBackground;
  final EdgeInsetsGeometry padding;

  @override
  _TSearchContainerState createState() => _TSearchContainerState();
}

class _TSearchContainerState extends State<TSearchContainer> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> items = [];
  List<dynamic> projects = [];
  final box = GetStorage();
  OverlayEntry? _overlayEntry;
  List<dynamic> categories = [];


  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final token = box.read('token');
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Category'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load categories data');
    }

  }


  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    final token = box.read('token');
    final headers = {'Authorization': 'Bearer $token'};

    // Fetch all projects first
    final allProjectsResponse = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Projects'),
      headers: headers,
    );

    if (allProjectsResponse.statusCode == 200) {
      List<dynamic> allProjects = json.decode(allProjectsResponse.body);
      List<dynamic> matchingProjects = [];

      // Iterate through each project and check its items
      for (var project in allProjects) {
        final projectId = project['id'];

        // Fetch project details with items
        final projectDetailsResponse = await http.get(
          Uri.parse('${AppConfig.baseUrl}/api/Projects/$projectId'),
          headers: headers,
        );

        if (projectDetailsResponse.statusCode == 200) {
          final projectDetails = json.decode(projectDetailsResponse.body);

          // Check if the project has items
          if (projectDetails.containsKey('items') && projectDetails['items'] is List) {
            List<dynamic> projectItems = projectDetails['items'];

            // Check if any item's name contains the search query
            bool itemMatch = projectItems.any((item) =>
                item['name'].toLowerCase().contains(query.toLowerCase()));

            if (itemMatch) {
              matchingProjects.add(projectDetails);
            }
          }
        } else {
          print('Failed to load project details for project ID: $projectId');
        }
      }

      setState(() {
        projects = matchingProjects;
      });
    } else {
      print('Failed to load all projects.');
    }



    final itemsResponse = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Items/$query'),
      headers: headers,
    );



    if (itemsResponse.statusCode == 200) {
      setState(() {
        items = json.decode(itemsResponse.body);
      });
    }


    _showOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 8,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: THelperFunctions.isDarkMode(context) ? TColors.dark : TColors.light,
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (items.isNotEmpty) ...[
                  const Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...items.map((item) => ListTile(
                    title: Text(item['name']),
                    subtitle: Text('\$${item['price']}'),
                    onTap: () {
                      _removeOverlay();
                      String categoryName = '';
                      if(categories.isNotEmpty){
                        final category = categories.firstWhere((element) => element['id'] == item['categoryItemId'], orElse: () => null);
                        categoryName = category != null ? category['name'] : '';
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: Product(
                              id: item['id'],
                              name: item['name'],
                              category: categoryName,
                              imageUrl: item['itemImageUrl'],
                              price: item['price'].toDouble(),
                              inStock: item['count'] > 0,
                              stockQuantity: item['count'],
                              description: item['description'],
                            ),
                          ),
                        ),
                      );
                    },
                  )).toList(),
                ],
                if (projects.isNotEmpty) ...[
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const Text('Projects:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...projects.map((project) => ListTile(
                    title: Text(project['name']),
                    subtitle: Text('\$${project['cost']}'),
                    onTap: () {
                      _removeOverlay();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsScreen(
                            project: Project(
                              id: project['id'],
                              name: project['name'],
                              category: project['category'],
                              imageUrls: (project['projectImageUrl'] as List<dynamic>?)
                                  ?.map((e) => e?.toString())
                                  .whereType<String>()
                                  .toList() ?? [],
                              description: project['description'] ?? '',
                              cost: project['cost'].toDouble(),
                              userId: project['userId'] ?? '',
                            ),
                          ),
                        ),
                      );
                    },
                  )).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final textColor = dark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Padding(
        padding: widget.padding,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 0.7),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            color: widget.showBackground ? dark ? TColors.dark : TColors.light : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(TSizes.sm),
            child: Row(
              children: [
                const SizedBox(width: TSizes.spaceBtwItems),
                Icon(widget.icon, color: TColors.darkerGrey),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: widget.text,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                    onChanged: _search,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}