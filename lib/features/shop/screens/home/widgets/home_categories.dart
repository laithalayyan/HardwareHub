import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/screens/sub_category/sub_categories.dart';

import '../../../../../common/widgets/image_text_widgets/vertical_image_text.dart';
import '../../../../../utils/constants/image_strings.dart';


class THomeCatigories extends StatelessWidget {
  THomeCatigories({
    super.key,
  });

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'fc332ef6-b7f0-40ce-8bae-6545c41c2085',
      'title': 'Motors',
      'icon': TImages.motor, // Replace with your motor icon
    },
    {
      'id': 'd9088091-e39a-4de9-98bf-32feda09fc4a',
      'title': 'Sensors',
      'icon': TImages.sensors, // Replace with your sensor icon
    },
    {
      'id': '977da370-7b40-476f-81a0-439b09ea14c3',
      'title': 'Arduino',
      'icon': TImages.arduino, // Replace with your Arduino icon
    },
    {
      'id': '9c7d62ce-592f-4755-bdb3-5cf1531531a3',
      'title': 'Tyres',
      'icon': TImages.tyres, // Replace with your tyre icon
    },
    {
      'id': '4b5c8cf2-459d-4fa1-830a-6d667bfbf0ca',
      'title': 'ESP',
      'icon': TImages.esp, // Replace with your ESP icon
    },
    {
      'id': '1446de1a-6430-45cf-b9c9-dc59450fd5d7',
      'title': 'Raspberry',
      'icon': TImages.rass, // Replace with your Raspberry icon
    },
    {
      'id': '1da9fca6-6ae7-4394-ba2b-01c770f3ae35',
      'title': 'Drivers',
      'icon': TImages.driver, // Replace with your driver icon
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final category = categories[index];
          return TVerticalImageText(
            image: category['icon'],
            title: category['title'],
            //onTap: () => Get.to(() => const SubCategoriesScreen()),
            onTap: () {
              Get.to(() => SubCategoriesScreen(categoryId: category['id']));
              /*
              if (category['hasSubCategories']) {
                // Navigate to subcategories screen if the category has subcategories
                Get.to(() => SubCategoriesScreen(categoryId: category['id']));
              } else {
                // Handle categories without subcategories (e.g., show a message or navigate to a product list)
                Get.snackbar(
                  category['title'],
                  'No subcategories available for ${category['title']}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }*/
            },
          );
        },
      ),
    );
  }
}
