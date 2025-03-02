import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/appbar/tabbar.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/cart/cart_menu_icon.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/brands/brand_card.dart';
import '../../../../common/widgets/products/products_cards/project_card_vertical.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../data/project_data/project_service.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../brand/all_brands.dart';

class ProjectsStore extends StatefulWidget {
  const ProjectsStore({super.key});

  @override
  State<ProjectsStore> createState() => _ProjectsStoreState();
}

class _ProjectsStoreState extends State<ProjectsStore> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProjectService _projectService = ProjectService();
  List<Map<String, dynamic>> categories = [];
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories first
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _projectService.fetchCategories();
      final List<Map<String, dynamic>> categoriesWithCount = [];
      for (var category in response) {
        final projects = await _projectService.fetchProjectsByCategory(category['id']);
        categoriesWithCount.add({
          'id': category['id'],
          'name': category['name'],
          'projectCount': projects.length,
        });
      }
      setState(() {
        categories = categoriesWithCount;
        // Initialize the TabController with the correct length
        _tabController = TabController(
          length: categories.length,
          vsync: this,
        );
        _isLoading = false; // Data fetched, stop loading
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e');
      setState(() {
        _isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text('Projects', style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          TCartCounterIcon(onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : NestedScrollView(
        headerSliverBuilder: (_, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              floating: true,
              backgroundColor: THelperFunctions.isDarkMode(context) ? TColors.black : TColors.white,
              expandedHeight: 440,
              flexibleSpace: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    /// --- Search bar
                    const SizedBox(height: TSizes.spaceBtwItems),
                    const TSearchContainer(
                      text: 'Search',
                      //showBorder: true,
                      showBackground: true,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    // -- Featured Brands
                    TSectionHeading(
                      title: 'Featured Projects Types',
                      onPressed: () => Get.to(() => const AllBrandsScreen()),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 1.5),

                    TGridLayout(
                      itemCount: categories.length,
                      mainAxisExtent: 80,
                      itemBuilder: (_, index) {
                        final category = categories[index];
                        return TBrandCard(
                          showBorder: true,
                          categoryName: category['name'],
                          count: category['projectCount'],
                        );
                      },
                    ),
                  ],
                ),
              ),


              /// Tabs --
              bottom: TTabBar(
                tabController: _tabController,
                tabs: categories.map((category) {
                  return Tab(child: Text(category['name']));
                }).toList(),
              ),
            ),
          ];
        },

        /// -- Body
        body: TabBarView(
          controller: _tabController,
          children: categories.map((category) {
            return TCategoryTabProj(categoryId: category['id']);
          }).toList(),
        ),
      ),
    );
  }
}


class TCategoryTabProj extends StatefulWidget {
  final String categoryId;

  const TCategoryTabProj({super.key, required this.categoryId});

  @override
  State<TCategoryTabProj> createState() => _TCategoryTabProjState();
}

class _TCategoryTabProjState extends State<TCategoryTabProj> {
  final ProjectService _projectService = ProjectService();
  List<Map<String, dynamic>> projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final response = await _projectService.fetchProjectsByCategory(widget.categoryId);
      setState(() {
        projects = response.take(4).toList(); // response is already List<Map<String, dynamic>>
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch projects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Grid Layout for Projects
              TGridLayout(
                itemCount: projects.length,
                itemBuilder: (_, index) {
                  final project = projects[index];
                  final List<String> imageUrls = (project['projectImageUrl'] as List<dynamic>).cast<String>();

                  return TProjectCardVertical(
                    project: Project(
                      id: project['id'],
                      name: project['name'],
                      category: widget.categoryId,
                      imageUrls: imageUrls,
                      description: project['description'] ?? '',
                      cost: project['cost']?.toDouble() ?? 0.0,
                    ),
                  );
                },
                mainAxisExtent: 255,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ],
    );
  }
}

