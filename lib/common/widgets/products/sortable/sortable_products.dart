import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/sizes.dart';
import '../../layouts/grid_layout.dart';
import '../products_cards/project_card_vertical.dart'; // Import TProjectCardVertical
import '../../../../data/project_data/project_model.dart'; // Import Project model

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
  List<Project> _sortedProjects = []; // Use List<Project> instead of List<Map<String, dynamic>>

  @override
  void initState() {
    super.initState();
    // Convert List<Map<String, dynamic>> to List<Project>
    _sortedProjects = widget.products.map((project) {
      return Project(
        id: project['id'] ?? '',
        name: project['name'] ?? '',
        category: project['category'] ?? '',
        imageUrls: (project['projectImageUrl'] as List<dynamic>).cast<String>() ?? [],
        description: project['description'] ?? '',
        cost: project['cost']?.toDouble() ?? 0.0,
      );
    }).toList();
    _sortProjects(); // Sort projects initially
  }

  void _sortProjects() {
    setState(() {
      switch (_selectedSortOption) {
        case 'Name':
          _sortedProjects.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Higher Price':
        // Assuming you have a 'price' field in your Project model
          _sortedProjects.sort((a, b) => b.cost.compareTo(a.cost));
          break;
        case 'Lower Price':
        // Assuming you have a 'price' field in your Project model
          _sortedProjects.sort((a, b) => a.cost.compareTo(b.cost));
          break;
        default:
          _sortedProjects = List.from(_sortedProjects);
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
              _sortProjects(); // Sort projects when the dropdown value changes
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

        /// Projects Grid
        TGridLayout(
          itemCount: _sortedProjects.length,
          itemBuilder: (_, index) {
            final project = _sortedProjects[index];
            return TProjectCardVertical(
              project: project, // Pass the Project object
            );
          },
        ),
      ],
    );
  }
}