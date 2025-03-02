import 'dart:io'; // For File handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../toke.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../config/config.dart';
import '../../../authentication/screens/login/login.dart'; // Import your config file

class AddNewItem extends StatefulWidget {
  const AddNewItem({super.key});

  @override
  _AddNewItemState createState() => _AddNewItemState();
}

class _AddNewItemState extends State<AddNewItem> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // To store the selected image
  int _stock = 1; // Stock starts from 1
  int _timesUsed = 1; // Stock starts from 1
  String? _selectedCategory; // Selected category
  String? _selectedSubCategory; // Selected subcategory
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _timesUsedController = TextEditingController();
  List<Map<String, dynamic>> categories = []; // List of categories
  List<Map<String, dynamic>> subCategories = []; // List of subcategories

  @override
  void initState() {
    super.initState();
    //_stockController.text = 'Stock'; // Default display text
    //_timesUsedController.text = 'Times Used'; // Default display text
    fetchCategories().then((data) {
      setState(() {
        categories = data;
      });
    });
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String?> uploadImage(XFile image) async {
    const url = '${AppConfig.baseUrl}/api/Upload/upload';
    final headers = await getHeaders(); // Get headers with token

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    // Add the image file to the request
    request.files.add(await http.MultipartFile.fromPath('files', image.path));

    // Send the request
    var response = await request.send();

    if (response.statusCode == 200) {
      // Parse the response to get the image URL
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      return jsonResponse['imageUrl'][0]; // Return the first image URL
    } else if (response.statusCode == 401) {
      // Token is invalid or expired
      Get.offAll(() => const LoginScreen()); // Redirect to login screen
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to upload image');
    }
  }

  // Function to fetch categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    const url = '${AppConfig.baseUrl}/api/Category/CategoryItem/All'; // Replace with your backend URL
    final headers = await getHeaders(); // Get headers with token

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else if (response.statusCode == 401) {
      // Token is invalid or expired
      Get.offAll(() => const LoginScreen()); // Redirect to login screen
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Function to fetch subcategories
  Future<void> fetchSubCategories(String categoryId) async {
    final url = '${AppConfig.baseUrl}/api/Category/$categoryId/SubCategories'; // Replace with your backend URL
    final headers = await getHeaders(); // Get headers with token

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        subCategories = data.cast<Map<String, dynamic>>();
      });
    } else if (response.statusCode == 401) {
      // Token is invalid or expired
      Get.offAll(() => const LoginScreen()); // Redirect to login screen
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to load subcategories');
    }
  }


  /*
  Future<void> submitItem({
    required String name,
    required String description,
    required double price,
    required int timesUsed,
    required int count,
    required String? itemImageUrl,
    required String? categoryItemId,
    required String? subCategoryItemId,
  }) async {
    const url = '${AppConfig.baseUrl}/api/Items';
    final headers = await getHeaders(); // Get headers with token

    // Prepare the request body
    final body = jsonEncode([
      {
        "name": name,
        "description": description,
        "price": price,
        "timesUsed": timesUsed,
        "count": count,
        "itemImageUrl": itemImageUrl ?? "",
        "categoryItemId": categoryItemId ?? "",
        "subCategoryItemId": subCategoryItemId ?? "",
      }
    ]);

    // Send the request
    final response = await http.post(
      Uri.parse(url),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      // Item added successfully
      Get.snackbar('Success', 'Item added successfully');
    } else if (response.statusCode == 401) {
      // Token is invalid or expired
      Get.offAll(() => const LoginScreen()); // Redirect to login screen
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to add item: ${response.body}');
    }
  }

   */

  Future<void> submitItem({
    required String name,
    required String description,
    required double price,
    required int timesUsed,
    required int count,
    required String? itemImageUrl,
    required String? categoryItemId,
    required String? subCategoryItemId,
  }) async {
    const url = '${AppConfig.baseUrl}/api/Items';
    final headers = await getHeaders(); // Get headers with token

    // Prepare the request body
    final Map<String, dynamic> itemData = {
      "name": name,
      "description": description,
      "price": price,
      "timesUsed": timesUsed,
      "count": count,
      "itemImageUrl": itemImageUrl ?? "",
      "categoryItemId": categoryItemId ?? "",
    };

    // Only include subCategoryItemId if it is not null or empty
    if (subCategoryItemId != null && subCategoryItemId.isNotEmpty) {
      itemData["subCategoryItemId"] = subCategoryItemId;
    }

    // Encode the request body
    final body = jsonEncode([itemData]);

    // Send the request
    final response = await http.post(
      Uri.parse(url),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      // Item added successfully
      Get.snackbar('Success', 'Item added successfully');
    } else if (response.statusCode == 401) {
      // Token is invalid or expired
      Get.offAll(() => const LoginScreen()); // Redirect to login screen
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to add item: ${response.body}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Add new Item')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.label_important),
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.money),
                    labelText: 'Price',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category),
                    labelText: 'Category',
                  ),
                  value: _selectedCategory,
                  items: categories
                      .map<DropdownMenuItem<String>>((category) => DropdownMenuItem<String>(
                    value: category['id'].toString(), // Ensure the value is a String
                    child: Text(category['name']),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSubCategory = null; // Reset subcategory when category changes

                      // Find the selected category
                      final selectedCategory = categories.firstWhere(
                            (category) => category['id'] == value,
                        orElse: () => {},
                      );

                      // Check if the selected category has subcategories
                      if (selectedCategory.isNotEmpty && selectedCategory['subCategories'] != null) {
                        setState(() {
                          subCategories = List<Map<String, dynamic>>.from(selectedCategory['subCategories']);
                        });
                      } else {
                        setState(() {
                          subCategories = []; // Clear subcategories if none exist
                        });
                      }
                    });
                  },
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // Subcategory Dropdown (if subcategories exist)
                if (subCategories.isNotEmpty)
                  SizedBox(
                    //height: 60, // Adjust height as needed
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category),
                        labelText: 'Subcategory',
                      ),
                      value: _selectedSubCategory,
                      items: subCategories
                          .map<DropdownMenuItem<String>>((subCategory) => DropdownMenuItem<String>(
                        value: subCategory['id'].toString(), // Ensure the value is a String
                        child: Text(subCategory['name'].toString()), // Ensure the text is a String
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubCategory = value;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: TSizes.defaultSpace),

                // Stock Field with Dynamic Design
                TextFormField(
                  controller: _stockController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.numbers),
                    labelText: _stock > 0 ? 'Stock' : null, // Label appears when stock > 1
                    hintText: _stock == 0 ? 'Stock' : null, // Reset hint if stock is 1
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_stock > 0) _stock--; // Minimum value is 1
                              _stockController.text = _stock == 0 ? 'Stock' : '$_stock';
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _stock++;
                              _stockController.text = '$_stock';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // times used Field with Dynamic Design
                TextFormField(
                  controller: _timesUsedController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.numbers),
                    labelText: _timesUsed > 0 ? 'Times Used' : null, // Label appears when stock > 1
                    hintText: _timesUsed == 0 ? 'Times Used' : null, // Reset hint if stock is 1
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_timesUsed > 0) _timesUsed--; // Minimum value is 1
                              _timesUsedController.text = _timesUsed == 0 ? 'Times Used' : '$_timesUsed';
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _timesUsed++;
                              _timesUsedController.text = '$_timesUsed';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // Description Field
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.description),
                    labelText: 'Description',
                  ),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // Image Upload Field
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _image == null
                        ? const Center(
                      child: Text(
                        'Tap to upload image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                        : Image.file(File(_image!.path), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (priceController.text.isEmpty || double.tryParse(priceController.text) == null) {
                        Get.snackbar('Error', 'Please enter a valid price');
                        return;
                      }

                      if (_image == null) {
                        Get.snackbar('Error', 'Please upload an image');
                        return;
                      }

                      // Upload the image and get the URL
                      final imageUrl = await uploadImage(_image!);

                      if (imageUrl == null) {
                        Get.snackbar('Error', 'Failed to upload image');
                        return;
                      }

                      final price = double.parse(priceController.text);

                      // Submit the item data
                      await submitItem(
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        timesUsed: _timesUsed,
                        count: _stock,
                        itemImageUrl: imageUrl,
                        categoryItemId: _selectedCategory,
                        subCategoryItemId: _selectedSubCategory,
                      );

                      // Clear the form after submission
                      setState(() {
                        _image = null;
                        _stock = 0;
                        _timesUsed = 0;
                        _selectedCategory = null;
                        _selectedSubCategory = null;
                        nameController.clear();
                        descriptionController.clear();
                        priceController.clear();
                        _stockController.text = '1';
                        _timesUsedController.text = '1';
                      });
                    },
                    child: const Text('Add'),
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