import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/personalization/screens/profile/widgets/profile_menu.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../config/config.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import 'package:flutter/services.dart'; // For clipboard
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final GetStorage _storage = GetStorage();
  File? _image;

  // User data
  String _name = '';
  String _username = '';
  String _userId = '';
  String _email = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the screen loads
  }

  Future<void> _fetchUserData() async {
    final String token = _storage.read('token');
    const String url = '${AppConfig.baseUrl}/api/Auth';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        setState(() {
          _name = '${userData['firstName']} ${userData['lastName']}';
          _username = userData['username'];
          _userId = userData['id'];
          _email = userData['email'];
          _phoneNumber = userData['phoneNumber'];
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateUserData(Map<String, dynamic> updatedData) async {
    final String token = _storage.read('token');
    const String url = '${AppConfig.baseUrl}/api/Auth';

    try {
      // Prepare the full user data object
      final Map<String, dynamic> fullUserData = {
        'id': _userId,
        'firstName': _name.split(' ')[0],
        'lastName': _name.split(' ').length > 1 ? _name.split(' ')[1] : '',
        'username': _username,
        'email': _email,
        'phoneNumber': _phoneNumber,
        ...updatedData, // Override with updated fields
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(fullUserData),
      );

      if (response.statusCode == 200) {
        // Update the UI with the new data
        _fetchUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update user data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: const Text('Choose a source to select a new profile picture:'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() {
                    _image = File(pickedImage.path);
                  });
                }
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(String title, String currentValue, Function(String) onSave) async {
    final TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your $title',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newValue = controller.text;
                if (newValue.isNotEmpty) {
                  // Prepare the updated data
                  Map<String, dynamic> updatedData = {};

                  if (title == 'Name') {
                    // Split the name into firstName and lastName
                    final names = newValue.split(' ');
                    updatedData['firstName'] = names[0];
                    updatedData['lastName'] = names.length > 1 ? names[1] : '';
                  } else if (title == 'Username') {
                    updatedData['username'] = newValue;
                  } else if (title == 'E-mail') {
                    updatedData['email'] = newValue;
                  } else if (title == 'Phone Number') {
                    updatedData['phoneNumber'] = newValue;
                  }

                  // Send the updated data to the API
                  await _updateUserData(updatedData);

                  // Update the UI
                  onSave(newValue);
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    _image != null
                        ? CircleAvatar(
                      backgroundImage: FileImage(_image!),
                      radius: 40,
                    )
                        : const TCircularImage(image: TImages.user, width: 80, height: 80),
                    TextButton(
                      onPressed: _showImagePickerDialog,
                      child: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Profile Info
              const TSectionHeading(title: 'Profile Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                title: 'Name',
                value: _name,
                onPressed: () {
                  _showEditDialog('Name', _name, (newValue) {
                    setState(() {
                      _name = newValue;
                    });
                  });
                },
              ),
              TProfileMenu(
                title: 'Username',
                value: _username,
                onPressed: () {
                  _showEditDialog('Username', _username, (newValue) {
                    setState(() {
                      _username = newValue;
                    });
                  });
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Personal Info
              const TSectionHeading(title: 'Personal Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                title: 'User ID',
                value: _userId,
                icon: Iconsax.copy,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _userId)); // Copy User ID to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User ID copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              TProfileMenu(
                title: 'E-mail',
                value: _email,
                onPressed: () {
                  _showEditDialog('E-mail', _email, (newValue) {
                    setState(() {
                      _email = newValue;
                    });
                  });
                },
              ),
              TProfileMenu(
                title: 'Phone Number',
                value: _phoneNumber,
                onPressed: () {
                  _showEditDialog('Phone Number', _phoneNumber, (newValue) {
                    setState(() {
                      _phoneNumber = newValue;
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: const Text('Choose a source to select a new profile picture:'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() {
                    _image = File(pickedImage.path);
                  });
                }
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(String title, String currentValue, Function(String) onSave) async {
    final TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your $title',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text); // Save the new value
                Navigator.pop(context); // Close the dialog
                // Show a SnackBar to notify the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title updated successfully!'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green, // Success color
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    _image != null
                        ? CircleAvatar(
                      backgroundImage: FileImage(_image!),
                      radius: 40,
                    )
                        : const TCircularImage(image: TImages.user, width: 80, height: 80),
                    TextButton(
                      onPressed: _showImagePickerDialog,
                      child: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Profile Info
              const TSectionHeading(title: 'Profile Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                title: 'Name',
                value: 'Coding with T',
                onPressed: () {
                  _showEditDialog('Name', 'Coding with T', (newValue) {
                    // Update logic for Name
                  });
                },
              ),
              TProfileMenu(
                title: 'Username',
                value: 'coding_with_t',
                onPressed: () {
                  _showEditDialog('Username', 'coding_with_t', (newValue) {
                    // Update logic for Username
                  });
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Personal Info
              const TSectionHeading(title: 'Personal Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                title: 'User ID',
                value: '45689',
                icon: Iconsax.copy,
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: '45689')); // Copy User ID to clipboard
                  ScaffoldMessenger.of(context).showSnackBar( // Show confirmation message
                    //const SnackBar(content: Text('User ID copied to clipboard!')),
                    const SnackBar(
                      content: Text('User ID copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              TProfileMenu(
                title: 'E-mail',
                value: 'coding_with_t',
                onPressed: () {
                  _showEditDialog('E-mail', 'coding_with_t', (newValue) {
                    // Update logic for Email
                  });
                },
              ),
              TProfileMenu(
                title: 'Phone Number',
                value: '+92-317-8095528',
                onPressed: () {
                  _showEditDialog('Phone Number', '+92-317-8095528', (newValue) {
                    // Update logic for Phone Number
                  });
                },
              ),
              TProfileMenu(
                title: 'Gender',
                value: 'Male',
                onPressed: () async {
                  // Show the gender selection dialog
                  String? selectedGender = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      String gender = 'Male'; // Default gender value
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('Select Gender'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<String>(
                                  title: const Text('Male'),
                                  value: 'Male',
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                ),
                                RadioListTile<String>(
                                  title: const Text('Female'),
                                  value: 'Female',
                                  groupValue: gender,
                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Cancel and close dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, gender); // Save the selected gender
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );

                  // If a gender was selected, update the value and notify the user
                  if (selectedGender != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gender updated to: $selectedGender'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),

              /*TProfileMenu(
                title: 'Gender',
                value: 'Male',
                onPressed: () {
                  _showEditDialog('Gender', 'Male', (newValue) {
                    // Update logic for Gender
                  });
                },
              ),*/
              TProfileMenu(
                title: 'Date of Birth',
                value: '10 Oct, 1994',
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1994, 10, 10),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    String formattedDate = "${pickedDate.day} ${_getMonthName(pickedDate.month)}, ${pickedDate.year}";
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Date of Birth updated to: $formattedDate'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Centered Close Account Button
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Close Account',
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/