import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/config.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../toke.dart';
import '../../../../utils/constants/sizes.dart';

import '../../../authentication/screens/login/login.dart';

/*
class AddItemToProject extends StatefulWidget {
  const AddItemToProject({Key? key}) : super(key: key);

  @override
  _AddItemToProjectState createState() => _AddItemToProjectState();
}

class _AddItemToProjectState extends State<AddItemToProject> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  int _stock = 1;
  int _timesUsed = 1;
  String? _selectedCategory;
  String? _selectedSubCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _timesUsedController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subCategories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories().then((data) {
      setState(() {
        categories = data;
      });
    });
  }



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
    final url = '${AppConfig.baseUrl}/api/Upload/upload';
    final headers = await getHeaders();

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('files', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      return jsonResponse['imageUrl'][0];
    } else if (response.statusCode == 401) {
      Get.offAll(() => const LoginScreen());
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final url = '${AppConfig.baseUrl}/api/Category/CategoryItem/All';
    final headers = await getHeaders();

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else if (response.statusCode == 401) {
      Get.offAll(() => const LoginScreen());
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> fetchSubCategories(String categoryId) async {
    final url = '${AppConfig.baseUrl}/api/Category/$categoryId/SubCategories';
    final headers = await getHeaders();

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        subCategories = data.cast<Map<String, dynamic>>();
      });
    } else if (response.statusCode == 401) {
      Get.offAll(() => const LoginScreen());
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to load subcategories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Add Item to Project')),
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

                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.money),
                    labelText: 'Price',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category),
                    labelText: 'Category',
                  ),
                  value: _selectedCategory,
                  items: categories
                      .map<DropdownMenuItem<String>>((category) => DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSubCategory = null;
                      fetchSubCategories(value!);
                    });
                  },
                ),
                const SizedBox(height: TSizes.defaultSpace),

                if (subCategories.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category),
                      labelText: 'Subcategory',
                    ),
                    value: _selectedSubCategory,
                    items: subCategories
                        .map<DropdownMenuItem<String>>((subCategory) => DropdownMenuItem<String>(
                      value: subCategory['id'].toString(),
                      child: Text(subCategory['name'].toString()),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubCategory = value;
                      });
                    },
                  ),
                const SizedBox(height: TSizes.defaultSpace),

                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.numbers),
                    labelText: _stock > 0 ? 'Stock' : null,
                    hintText: _stock == 0 ? 'Stock' : null,
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_stock > 0) _stock--;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _stock++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),

                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.numbers),
                    labelText: _timesUsed > 0 ? 'Times Used' : null,
                    hintText: _timesUsed == 0 ? 'Times Used' : null,
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_timesUsed > 0) _timesUsed--;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _timesUsed++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),

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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
                        Get.snackbar('Error', 'Please enter a valid price');
                        return;
                      }

                      if (_image == null) {
                        Get.snackbar('Error', 'Please upload an image');
                        return;
                      }

                      final imageUrl = await uploadImage(_image!);

                      if (imageUrl == null) {
                        Get.snackbar('Error', 'Failed to upload image');
                        return;
                      }

                      final item = {
                        "name": _nameController.text,
                        "description": _descriptionController.text,
                        "price": double.parse(_priceController.text),
                        "timesUsed": _timesUsed,
                        "count": _stock,
                        "itemImageUrl": imageUrl,
                        "categoryItemId": _selectedCategory,
                        "subCategoryItemId": _selectedSubCategory,
                      };

                      // Return the item data to the previous screen
                      Get.back(result: item);
                    },
                    child: const Text('Add Item'),
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

class AddItemToProject extends StatefulWidget {
  const AddItemToProject({super.key});

  @override
  _AddItemToProjectState createState() => _AddItemToProjectState();
}

class _AddItemToProjectState extends State<AddItemToProject> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _selectedCategory;
  String? _selectedSubCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _timesUsedController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> subCategories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories().then((data) {
      setState(() {
        categories = data;
      });
    });
  }

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
    final headers = await getHeaders();

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('files', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      return jsonResponse['imageUrl'][0];
    } else if (response.statusCode == 401) {
      Get.offAll(() => const LoginScreen());
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    const url = '${AppConfig.baseUrl}/api/Category/CategoryItem/All';
    final headers = await getHeaders();

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else if (response.statusCode == 401) {
      Get.offAll(() => const LoginScreen());
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Add Item to Project')),
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

                TextFormField(
                  controller: _priceController,
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
                    value: category['id'].toString(),
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
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category),
                      labelText: 'Subcategory',
                    ),
                    value: _selectedSubCategory,
                    items: subCategories
                        .map<DropdownMenuItem<String>>((subCategory) => DropdownMenuItem<String>(
                      value: subCategory['id'].toString(),
                      child: Text(subCategory['name'].toString()),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubCategory = value;
                      });
                    },
                  ),
                const SizedBox(height: TSizes.defaultSpace),

                TextFormField(
                  controller: _timesUsedController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.numbers),
                    labelText: 'Times Used',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: TSizes.defaultSpace),

                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.numbers),
                    labelText: 'Stock',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: TSizes.defaultSpace),

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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
                        Get.snackbar('Error', 'Please enter a valid price');
                        return;
                      }

                      if (_timesUsedController.text.isEmpty || int.tryParse(_timesUsedController.text) == null) {
                        Get.snackbar('Error', 'Please enter a valid times used value');
                        return;
                      }

                      if (_stockController.text.isEmpty || int.tryParse(_stockController.text) == null) {
                        Get.snackbar('Error', 'Please enter a valid stock value');
                        return;
                      }

                      if (_image == null) {
                        Get.snackbar('Error', 'Please upload an image');
                        return;
                      }

                      final imageUrl = await uploadImage(_image!);

                      if (imageUrl == null) {
                        Get.snackbar('Error', 'Failed to upload image');
                        return;
                      }

                      final item = {
                        "name": _nameController.text,
                        "description": _descriptionController.text,
                        "price": double.parse(_priceController.text),
                        "timesUsed": int.parse(_timesUsedController.text),
                        "count": int.parse(_stockController.text),
                        "itemImageUrl": imageUrl,
                        "categoryItemId": _selectedCategory,
                        "subCategoryItemId": _selectedSubCategory,
                      };

                      // Return the item data to the previous screen
                      Get.back(result: item);
                    },
                    child: const Text('Add Item'),
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
