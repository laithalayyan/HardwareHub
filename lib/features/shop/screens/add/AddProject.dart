import 'dart:convert';
import 'dart:io'; // For File handling
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../config/config.dart';
import '../../../../navigation_menu.dart';
import '../../../../toke.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/login/login.dart';
import 'AddItemToProject.dart';
import 'package:http/http.dart' as http;



class AddNewProject extends StatefulWidget {
  const AddNewProject({super.key});

  @override
  _AddNewProjectState createState() => _AddNewProjectState();
}

class _AddNewProjectState extends State<AddNewProject> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  String? _selectedCategory;
  List<Map<String, dynamic>> items = []; // List to store added items

  List<Map<String, dynamic>> projectCategories = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProjectCategories().then((data) {
      setState(() {
        projectCategories = data;
      });
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage();
      setState(() {
        _images.addAll(pickedImages); // Append new images to the existing list
      });
        } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<void> _addItem() async {
    final item = await Get.to(() => const AddItemToProject());
    if (item != null) {
      setState(() {
        items.add(item);
      });
    }
  }

  void _editItem(int index) async {
    final updatedItem = await Get.to(
          () => const AddItemToProject(),
      arguments: items[index], // Pass the existing item data to the edit screen
    );
    if (updatedItem != null) {
      setState(() {
        items[index] = updatedItem; // Update the item in the list
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index); // Remove the item from the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Add new Project')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.label_important),
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category),
                    labelText: 'Category',
                  ),
                  value: _selectedCategory,
                  items: projectCategories
                      .map((category) => DropdownMenuItem(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: TSizes.defaultSpace),

                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.money),
                    labelText: 'Cost',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.description),
                    labelText: 'Description',
                  ),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: TSizes.defaultSpace),

                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _images.isEmpty
                        ? const Center(
                      child: Text(
                        'Tap to upload images',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : ListView(
                      scrollDirection: Axis.horizontal,
                      children: _images
                          .map(
                            (image) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // Display added items
                if (items.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Added Items:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      ...items.asMap().entries.map(
                            (entry) => ListTile(
                          title: Text(entry.value['name']),
                          subtitle: Text('Price: \$${entry.value['price']}, Times Used: ${entry.value['timesUsed']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editItem(entry.key),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteItem(entry.key),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                // Button to add items
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addItem,
                    child: const Text('Add Item to Project'),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_images.isEmpty) {
                        Get.snackbar('Error', 'Please upload at least one image');
                        return;
                      }

                      final List<String> imageUrls = await uploadImages(_images);


                      // Upload images and get URLs
                      //final List<String> imageUrls = [];
                      // for (var image in _images) {
                      //   final url = await uploadImage(image);
                      //   if (url != null) {
                      //     imageUrls.add(url);
                      //   }
                      // }

                      if (imageUrls.isEmpty) {
                        Get.snackbar('Error', 'Failed to upload images');
                        return;
                      }

                      // Prepare the project data
                      final projectData = {
                        "name": _nameController.text,
                        "description": _descriptionController.text,
                        "cost": double.parse(_costController.text),
                        "projectImageUrl": imageUrls,
                        "categoryProjectId": _selectedCategory,
                        "items": items,
                      };

                      // Submit the project data to the backend
                      await submitProject(projectData);
                    },
                    child: const Text('Add Project'),
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

Future<void> submitProject(Map<String, dynamic> projectData) async {
  const url = '${AppConfig.baseUrl}/api/Projects';
  final headers = await getHeaders();

  final response = await http.post(
    Uri.parse(url),
    headers: {...headers, 'Content-Type': 'application/json'},
    body: jsonEncode(projectData),
  );

  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 201 || response.statusCode == 200) {
    // Handle success (200 OK or 201 Created)
    Get.snackbar('Success', 'Project added successfully');
    Get.offAll(() => const NavigationMenu());
  } else if (response.statusCode == 401) {
    // Handle unauthorized error
    Get.offAll(() => const LoginScreen());
    throw Exception('Unauthorized: Please log in again');
  } else {
    // Handle other errors
    throw Exception('Failed to add project: ${response.body}');
  }
}

Future<List<Map<String, dynamic>>> fetchProjectCategories() async {
  const url = '${AppConfig.baseUrl}/api/Category/CategoryProject/All';
  final headers = await getHeaders();

  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else if (response.statusCode == 401) {
    Get.offAll(() => const LoginScreen());
    throw Exception('Unauthorized: Please log in again');
  } else {
    throw Exception('Failed to load project categories');
  }
}

Future<List<String>> uploadImages(List<XFile> images) async {
  const url = '${AppConfig.baseUrl}/api/Upload/upload';
  final headers = await getHeaders();

  var request = http.MultipartRequest('POST', Uri.parse(url));
  request.headers.addAll(headers);

  // Add all images to the request
  for (var image in images) {
    request.files.add(await http.MultipartFile.fromPath('files', image.path));
  }

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);
    return List<String>.from(jsonResponse['imageUrl']); // Return all image URLs
  } else if (response.statusCode == 401) {
    Get.offAll(() => const LoginScreen());
    throw Exception('Unauthorized: Please log in again');
  } else {
    throw Exception('Failed to upload images');
  }
}