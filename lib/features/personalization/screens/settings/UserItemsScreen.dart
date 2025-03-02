import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../config/config.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';


class UserItemsScreen extends StatefulWidget {
  const UserItemsScreen({super.key});

  @override
  _UserItemsScreenState createState() => _UserItemsScreenState();
}

class _UserItemsScreenState extends State<UserItemsScreen> {
  final box = GetStorage();
  late Future<List<dynamic>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = fetchUserItems();
  }

  Future<List<dynamic>> fetchUserItems() async {
    final token = box.read('token');
    final userId = box.read('id');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Items'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> allItems = json.decode(response.body);
      final userItems =
      allItems.where((item) => item['userId'] == userId).toList();
      return userItems;
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final token = box.read('token');

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/Items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
        setState(() {
          futureItems = fetchUserItems();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item : ${response.body}')),
        );
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      throw Exception('An error occurred');
    }
  }

  Future<void> _editItem(BuildContext context, dynamic item) async {
    final token = box.read('token');
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item['name']);
    final priceController =
    TextEditingController(text: item['price'].toString());
    final countController =
    TextEditingController(text: item['count'].toString());
    final ImagePicker picker = ImagePicker();
    XFile? pickedImage;
    String? imageUrl = item['itemImageUrl'];
    const textColor = Color(0xffffffff);

    void pickImage() async{
      pickedImage = await picker.pickImage(source: ImageSource.gallery);
    }

    Future<void> uploadImage() async{
      if (pickedImage != null) {
        final uri = Uri.parse('${AppConfig.baseUrl}/api/Upload/upload');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath('files', pickedImage!.path));

        try {
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);
          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData = json.decode(response.body);
            imageUrl = responseData['imageUrl'];

          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to upload image ${response.body}',
                  style: TextStyle(color: Colors.white)),
            ));
            throw Exception('Failed to upload image');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(
              content: Text('An error occurred while uploading image: $e',
                  style: TextStyle(color: Colors.white))));
          throw Exception('An error occurred while uploading image: $e');
        }
      }
    }


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Edit Item', style: TextStyle(color: Colors.white)),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name',
                      labelStyle: const TextStyle(color: textColor)),
                  style: const TextStyle(color: textColor),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                      labelText: 'Price', labelStyle: TextStyle(color: textColor)),
                  style: const TextStyle(color: textColor),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Price is required'
                      : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: countController,
                  decoration: const InputDecoration(
                      labelText: 'Count', labelStyle: TextStyle(color: textColor)),
                  style: const TextStyle(color: textColor),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Count is required'
                      : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                    ),
                    child: const Text('   Pick Image from gallery   ',
                        style: TextStyle(color: Colors.white))
                ),
                const SizedBox(height: 10),
                if(imageUrl != null )
                  CachedNetworkImage(
                    imageUrl: imageUrl ?? '',
                    width: 100,
                    height: 100,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await uploadImage();

                  final response = await http.put(
                    Uri.parse('${AppConfig.baseUrl}/api/Items/${item['id']}'),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: json.encode({
                      'name': nameController.text,
                      'price': double.parse(priceController.text),
                      'timesUsed': item['timesUsed'],
                      'count': int.parse(countController.text),
                      'itemImageUrl': imageUrl
                    }),
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Item updated successfully',
                            style: TextStyle(color: Colors.white))));
                    setState(() {
                      futureItems = fetchUserItems();
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to update item : ${response.body}',
                            style: TextStyle(color: Colors.white))));
                    throw Exception('Failed to update item');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('An error occurred: $e',
                          style: TextStyle(color: Colors.white))));
                  throw Exception('An error occurred');
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const TAppBar(
        title: Text('My Items'),
        showBackArrow: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: darkMode ? Colors.grey[800] : Colors.white,
                  elevation: 4,
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: item['itemImageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Count: ${item['count']}',
                      style: TextStyle(
                        color: darkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Iconsax.edit, color: darkMode ? Colors.green : Colors.green ),
                          onPressed: () => _editItem(context, item),
                        ),
                        IconButton(
                          icon: Icon(Iconsax.trash, color: darkMode ? Colors.red : Colors.red),
                          onPressed: () => _deleteItem(item['id']),
                        ),
                      ],
                    ),
                    onTap: (){
                      _showItemDetailsDialog(context, item);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showItemDetailsDialog(BuildContext context, dynamic item) {
    final darkMode = THelperFunctions.isDarkMode(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
          title: Text(item['name'], style: TextStyle(color: darkMode ? Colors.white : Colors.black)),
          content: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: item['itemImageUrl'] ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Description: ${item['description']}',
                    style: TextStyle(color: darkMode ? Colors.white : Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text('Price: ${item['price']}',
                    style: TextStyle(color: darkMode ? Colors.white : Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text('Times Used: ${item['timesUsed']}',
                    style: TextStyle(color: darkMode ? Colors.white : Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text('Count: ${item['count']}',
                    style: TextStyle(color: darkMode ? Colors.white : Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text('Date: ${item['date']}',
                    style: TextStyle(color: darkMode ? Colors.white : Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

}