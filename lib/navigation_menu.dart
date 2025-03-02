import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/personalization/screens/settings/settings.dart';
import 'package:t_store/features/shop/screens/add/AddItem.dart';
import 'package:t_store/features/shop/screens/add/AddProject.dart';
import 'package:t_store/features/shop/screens/home/home.dart';
import 'package:t_store/features/shop/screens/store/store.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import 'config/config.dart';
import 'features/shop/screens/store/projectsStore.dart';

import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;


class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  final controller = Get.put(NavigationController());
  final box = GetStorage();
  late Future<Map<String, dynamic>> futureRange;
  late int _minRange = 0;
  late int _maxRange = 10000; // Initialize with a default large range
  @override
  void initState() {
    super.initState();
    futureRange = fetchRangeData();
  }

  Future<Map<String, dynamic>> fetchRangeData() async {
    final token = box.read('token');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/Range/GetRange'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _minRange = data['min'];
        _maxRange = data['max'];
      });
      return data;
    } else {
      throw Exception('Failed to load range data');
    }
  }

  // Update the showAddMenu to accept a context
  Future<void> _showAddMenu(BuildContext context) async {
    final dark = THelperFunctions.isDarkMode(context);
    final firstThreeNumbers = box.read('firstThreeNumbers');
    print('firstThreeNumbers: $firstThreeNumbers');
    int parsedFirstThreeNumbers = int.tryParse(firstThreeNumbers.toString()) ?? 0;
    bool isWithinRange = true;
    try {
      await futureRange;
      if(firstThreeNumbers != null) {
        isWithinRange = parsedFirstThreeNumbers >= _minRange && parsedFirstThreeNumbers <= _maxRange;
      } else{
        isWithinRange = false;
      }
      print('_minRange: $_minRange');
      print('_maxRange: $_maxRange');
      print('isWithinRange: $isWithinRange');
    } catch (e) {
      // Handle the exception if fetching range failed
      isWithinRange = false;
      print('Error fetching range: $e');
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: THelperFunctions.isDarkMode(context) ? TColors.black : TColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.bubble_chart_outlined, color: dark ? TColors.primary : TColors.primary, size: 28),
                title: Text(
                  'Add Project',
                  style: TextStyle(fontSize: 19, color: dark ? TColors.white : TColors.primary, ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  if (isWithinRange) {
                    Get.to(() => const AddNewProject());
                  } else {
                    _showGradeNotAcceptableDialog(context);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.memory, color: dark ? TColors.primary : TColors.primary, size: 28),
                title: Text(
                  'Add Item',
                  style: TextStyle(fontSize: 20, color: dark ? TColors.white : TColors.primary),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  if (isWithinRange) {
                    Get.to(() => const AddNewItem());
                  } else {
                    _showGradeNotAcceptableDialog(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void _showGradeNotAcceptableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // backgroundColor: Colors.black,
          backgroundColor: TColors.black,
          title: const Text(
            'Grade Year Not Acceptable',
            style: TextStyle(color: Color(0xff799cb0)), // Added style for the title
          ),
          content: const Text(
              'Your grade year is not within the acceptable range.',
              style: TextStyle(color: Color(0xff799cb0)) // Added style for the content
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xff799cb0)) // Added style for the action button
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(() {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            /// Normal NavigationBar
            NavigationBar(
              height: 80,
              elevation: 0,
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) {
                if (index != 2) {
                  controller.selectedIndex.value = index;
                } else {
                  _showAddMenu(context); // Show the Add menu
                }
              },
              backgroundColor: darkMode ? TColors.black : TColors.white,
              indicatorColor: darkMode ? TColors.white.withOpacity(0.1) : TColors.black.withOpacity(0.1),
              destinations: const [
                NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
                NavigationDestination(icon: Icon(Iconsax.building), label: 'Projects'),
                NavigationDestination(icon: SizedBox.shrink(), label: ''), // Placeholder for the center button
                NavigationDestination(icon: Icon(Iconsax.shop), label: 'Store'),
                NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
              ],
            ),

            /// Circular Button in the Center
            Positioned(
              bottom: 35,
              child: GestureDetector(
                onTap: () => _showAddMenu(context),
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: TColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Iconsax.add, color: Colors.white, size: 40),
                ),
              ),
            ),
          ],
        );
      }),
      body: Obx(() {
        return controller.screens[controller.selectedIndex.value];
      }),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const ProjectsStore(),
    Container(), // Placeholder for the center button action
    const StoreScreen(),
    const SettingsScreen(),
  ];
}
