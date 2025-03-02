import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import '../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../data/project_data/project_model.dart';
import '../wishlist/WishlistController.dart';

class ProjectSlider extends StatefulWidget {
  const ProjectSlider({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  _ProjectSliderState createState() => _ProjectSliderState();
}

class _ProjectSliderState extends State<ProjectSlider> {
  int _currentImageIndex = 0; // Track the currently selected image

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final wishlistController = Get.find<WishlistController>();

    return TCurveEdgeWidget(
      child: Stack(
        children: [
          /// Blurred Background Image
          Positioned.fill(
            child: Image.network(
              widget.project.imageUrls[_currentImageIndex],
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7), // Adjust blur intensity
              child: Container(
                color: dark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.white.withOpacity(0.4), // Subtle color overlay
              ),
            ),
          ),

          /// Content
          Container(
            child: Stack(
              children: [
                /// Main Large Image
                Center(
                  child: SizedBox(
                    height: 400,
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Image.network(
                        widget.project.imageUrls[_currentImageIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                /// Image Slider
                Positioned(
                  right: 0,
                  bottom: 30,
                  left: TSizes.defaultSpace,
                  child: SizedBox(
                    height: 80,
                    child: ListView.separated(
                      itemCount: widget.project.imageUrls.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: TSizes.spaceBtwItems),
                      itemBuilder: (_, index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentImageIndex = index; // Update the selected image
                          });
                        },
                        child: TRoundedImage(
                          isNetworkImage: true,
                          width: 80,
                          height: 80,
                          backgroundColor:
                          dark ? TColors.dark : TColors.white,
                          border: Border.all(
                            color: _currentImageIndex == index
                                ? TColors.primary
                                : Colors.transparent,
                          ), // Highlight the selected image
                          padding: const EdgeInsets.all(TSizes.sm),
                          imageUrl: widget.project.imageUrls[index],
                        ),
                      ),
                    ),
                  ),
                ),

                /// Appbar Icons
                TAppBar(
                  showBackArrow: true,
                  actions: [
                    Obx(() {
                      final isFav =
                      wishlistController.isFavoriteProject(widget.project.id);

                      return TCircularIcon(
                        onPressed: () {
                          wishlistController.toggleFavoriteProject(widget.project);
                        },
                        icon: isFav ? Iconsax.heart5 : Iconsax.heart,
                        color: isFav ? Colors.red : Colors.grey,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
