import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store/common/widgets/images/t_rounded_image.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import '../../../../data/project_data/project_model.dart';
import '../../../../features/shop/screens/project_details/project_details.dart';
import '../../../../features/shop/screens/wishlist/WishlistController.dart';
import '../../../styles/shadows.dart';
import '../../icons/t_circular_icon.dart';
import '../../texts/product_title_text.dart';

class TProjectCardVertical extends StatelessWidget {
  final Project project; // Accept a project as input
  const TProjectCardVertical({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final dark = THelperFunctions.isDarkMode(context);
    /// Container with side paddings, color, edges, radius and shadow
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(project: project),
          ),
        );
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            TRoundedContainer(
              height: 180,
              padding: const EdgeInsets.all(TSizes.sm),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Stack(
                children: [
                  /// -- Blur Background
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(TSizes.productImageRadius),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            project.imageUrls.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // Image loaded successfully
                              }
                              return Container(
                                color: Colors.grey.shade300, // Placeholder color while loading
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300, // Fallback for errors
                                child: const Icon(Icons.error, color: Colors.red), // Error icon
                              );
                            },
                          ),
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), // Adjust blur intensity
                            child: Container(
                              color: dark ? Colors.white.withOpacity(0) : Colors.white.withOpacity(0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// -- Thumbnail Image
                  Center(
                    child: TRoundedImage(
                      imageUrl: project.imageUrls.isNotEmpty ? project.imageUrls.first : '', // Handle empty list
                      applyImageRadius: true,
                      isNetworkImage: true,
                    ),
                  ),

                  /// -- Favorite Icon Button
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Obx(() {
                      final isFav = wishlistController.isFavoriteProject(project.id);
                      return IconButton(
                        icon: TCircularIcon(
                          icon: isFav ? Iconsax.heart5 : Iconsax.heart,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          wishlistController.toggleFavoriteProject(project);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            /*
            TRoundedContainer(
              height: 180,
              padding: const EdgeInsets.all(TSizes.sm),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Stack(
                children: [
                  /// -- Blur Background
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(TSizes.productImageRadius),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            project.imageUrls.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // Image loaded successfully
                              }
                              return Container(
                                color: Colors.grey.shade300, // Placeholder color while loading
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300, // Fallback for errors
                                child: const Icon(Icons.error, color: Colors.red), // Error icon
                              );
                            },
                          ),
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), // Adjust blur intensity
                            child: Container(
                              color: dark ? Colors.white.withOpacity(0) : Colors.white.withOpacity(0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  /// -- Thumbnail Image
                  Center(
                    child: TRoundedImage(
                      imageUrl: project.imageUrls.isNotEmpty ? project.imageUrls.first : '', // Handle empty list
                      applyImageRadius: true,
                    ),
                  ),

                  /// -- Favorite Icon Button
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Obx(() {
                      final isFav = wishlistController.isFavoriteProject(project.id);
                      return IconButton(
                        icon: TCircularIcon(
                          icon: isFav ? Iconsax.heart5 : Iconsax.heart,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          wishlistController.toggleFavoriteProject(project);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

            */
            const SizedBox(height: TSizes.spaceBtwItems / 2,),

            /// --Details
            Padding(
              padding:const EdgeInsets.only(left: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TProductTitleText(title: project.name, smallSize: true),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// View Details
                   Container(
                    decoration: const BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(TSizes.cardRadiusMd),
                        topRight: Radius.circular(TSizes.cardRadiusMd),
                        bottomRight: Radius.circular(TSizes.productImageRadius),
                        bottomLeft: Radius.circular(TSizes.productImageRadius),
                      ),
                    ),
                    child: const SizedBox(
                      width: TSizes.iconLg * 5.6,
                      height: TSizes.iconLg * 1.2,
                      child: Center(
                        child: Text(
                          'View Details',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
