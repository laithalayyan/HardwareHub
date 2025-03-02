import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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

class UserProjectsScreen extends StatefulWidget {
  const UserProjectsScreen({super.key});

  @override
  _UserProjectsScreenState createState() => _UserProjectsScreenState();
}

class _UserProjectsScreenState extends State<UserProjectsScreen> {
  final box = GetStorage();
  late Future<List<dynamic>> futureProjects;

  @override
  void initState() {
    super.initState();
    futureProjects = fetchUserProjects();
  }

  Future<List<dynamic>> fetchUserProjects() async {
    final token = box.read('token');
    final userId = box.read('id');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Projects'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> allProjects = json.decode(response.body);
      final userProjects =
      allProjects.where((project) => project['userId'] == userId).toList();
      return userProjects;
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<void> _deleteProject(String projectId) async {
    final token = box.read('token');

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/Projects/$projectId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deleted successfully')),
        );
        setState(() {
          futureProjects = fetchUserProjects();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete project: ${response.body}')),
        );
        throw Exception('Failed to delete project');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      throw Exception('An error occurred');
    }
  }

  Future<void> _editProject(BuildContext context, dynamic project) async {
    final token = box.read('token');
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: project['name']);
    final costController =
    TextEditingController(text: project['cost'].toString());
    final ImagePicker picker = ImagePicker();
    List<XFile>? pickedImages = [];
    List<String> imageUrls = List<String>.from(project['projectImageUrl']);
    const textColor = Color(0xffffffff);
    int currentImageIndex = 0; // Add this line

    void pickImages() async{
      pickedImages = await picker.pickMultiImage();
    }

    Future<void> uploadImages() async{
      if (pickedImages!.isNotEmpty) {
        final uri = Uri.parse('${AppConfig.baseUrl}/api/Upload/upload');
        final request = http.MultipartRequest('POST', uri);
        for (XFile image in pickedImages!){
          request.files.add(await http.MultipartFile.fromPath('files', image.path));
        }


        try {
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);
          if (response.statusCode == 200) {
            final List<dynamic> responseData = json.decode(response.body);
            imageUrls = responseData.map((item) => item['imageUrl'] as String).toList();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to upload images ${response.body}',
                    style: const TextStyle(color: Colors.white))));
            throw Exception('Failed to upload image');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('An error occurred while uploading images: $e',
                  style: const TextStyle(color: Colors.white))));
          throw Exception('An error occurred while uploading image: $e');
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                  backgroundColor: Colors.grey[900],
                  child: Padding(
                  padding: const EdgeInsets.all(16.0),
              child: Form(
              key: _formKey,
              child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
              controller: nameController,
              decoration: InputDecoration(
              labelText: 'Name', labelStyle: const TextStyle(color: textColor)),
              style: const TextStyle(color: textColor),
              validator: (value) =>
              value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
              controller: costController,
              decoration: InputDecoration(
              labelText: 'Cost', labelStyle: const TextStyle(color: textColor)),
              style: const TextStyle(color: textColor),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty
              ? 'Cost is required'
                  : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
              onPressed: pickImages,
              style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              ),
              child: const Text('   Pick Images from gallery   ',
              style: TextStyle(color: Colors.white)),
              ),
              if (imageUrls.isNotEmpty)
              Column(
              children: [
              Text('${currentImageIndex+1} of ${imageUrls.length} Images',
              style: const TextStyle(color: Colors.white)),
              CarouselSlider(
              items: imageUrls.map((url) => CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              ).toList(),
              options: CarouselOptions(
              height: 200,
              enlargeCenterPage: true,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              disableCenter: true,
              padEnds: false,
              onPageChanged: (index, reason) {
              setState(() {
              currentImageIndex = index;
              });
              },
              ),
              ),
              ],
              ),
              Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
              onPressed: () async {
              if (_formKey.currentState!.validate()) {
              try {
              await uploadImages();

              final response = await http.put(
              Uri.parse('${AppConfig.baseUrl}/api/Projects/${project['id']}'),
              headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              },
              body: json.encode({
              'name': nameController.text,
              'description': project['description'],
              'cost': double.parse(costController.text),
              'projectImageUrl': imageUrls,
              }),
              );

              if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Project updated successfully',
              style: TextStyle(color: Colors.white))));
              setState(() {
              futureProjects = fetchUserProjects();
              });
              Navigator.pop(context);
              } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to update project: ${response.body}',
              style: const TextStyle(color: Colors.white))));
              throw Exception('Failed to update project');
              }
              } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('An error occurred: $e',
              style: const TextStyle(color: Colors.white))));
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
              ],
              ),
              ),
              ),
              ),
              );
            }
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const TAppBar(
        title: Text('My Projects'),
        showBackArrow: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No projects available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final project = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: darkMode ? Colors.grey[800] : Colors.white,
                  elevation: 4,
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: project['projectImageUrl'] != null && project['projectImageUrl'].isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: project['projectImageUrl'][0],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                          :  const Icon(Iconsax.image, size: 30,),
                    ),
                    title: Text(
                      project['name'],
                      style: const TextStyle(
                          color:  Color(0xffffffff)),
                    ),
                    subtitle: Text(
                      'Cost: ${project['cost']}',
                      style: const TextStyle(
                          color: Color(0xffffffff)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editProject(context, project),
                          icon: const Icon(Iconsax.edit, color: Colors.green,),
                        ),
                        IconButton(
                            onPressed: () => _deleteProject(project['id']),
                            icon: const Icon(Iconsax.trash, color: Colors.red)
                        ),
                      ],
                    ),
                    onTap: (){
                      _showProjectDetailsDialog(context, project);
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


  void _showProjectDetailsDialog(BuildContext context, dynamic project) async {
    final darkMode = THelperFunctions.isDarkMode(context);
    final token = box.read('token');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Projects/${project['id']}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final projectDetails = json.decode(response.body);
      int currentImageIndex = 0;

      // Debug: Print the structure of projectDetails['items']
      debugPrint('projectDetails: ${projectDetails.toString()}');
      debugPrint('projectDetails[items]: ${projectDetails['items'].toString()}');

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState){
              return Dialog(
                backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                      if (projectDetails['projectImageUrl'] != null &&
                      projectDetails['projectImageUrl'].isNotEmpty)
                      Column(
                    children: [
                    Text('${currentImageIndex + 1} of ${projectDetails['projectImageUrl'].length} Images',
                      style: const TextStyle(color: Colors.white),),
                    CarouselSlider(
                      items: projectDetails['projectImageUrl'].map<Widget>((url) => CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                      ).toList(),
                      options: CarouselOptions(
                        height: 200,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        viewportFraction: 1,
                        enableInfiniteScroll: false,
                        disableCenter: true,
                        padEnds: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentImageIndex = index;
                          });
                        },
                      ),
                    ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Description: ${projectDetails['description']}',
                      style: const TextStyle(color: Color(0xffffffff)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Cost: ${projectDetails['cost']}',
                      style: const TextStyle(color: Color(0xffffffff)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Date: ${projectDetails['date']}',
                      style: const TextStyle(color: Color(0xffffffff)),
                    ),
                    const SizedBox(height: 10),
                    if (projectDetails['items'] != null && projectDetails['items'].isNotEmpty)
                Text(
                'Items:',
                style: const TextStyle(color: Color(0xffffffff), fontSize: 20),
              ),
              const SizedBox(height: 10),
              if (projectDetails['items'] != null && projectDetails['items'].isNotEmpty)
              Column(
              children: projectDetails['items'].map<Widget>((item) => ListTile(
              leading: CachedNetworkImage(
              imageUrl: item['itemImageUrl'] ?? '',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error)
              ),
              title: Text(item['name']?? '',
              style: const TextStyle(color: Color(0xffffffff)),
              ),
              ),
              ).toList(),
              ),
              if (projectDetails['items'] != null && projectDetails['items'].isEmpty)
              const Text('This project has no items', style: TextStyle(color: Colors.white),),
              Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
              ],
              ),
              ],
              ),
              ),
              ),
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get the project details')),
      );
    }
  }

}