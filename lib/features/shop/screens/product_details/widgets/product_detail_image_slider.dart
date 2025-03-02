import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import '../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../data/products_data/product_model.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../wishlist/WishlistController.dart';


class TProductImageSlider extends StatelessWidget {
  const TProductImageSlider({
    super.key,required this.product
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final wishlistController = Get.find<WishlistController>();

    return TCurveEdgeWidget(
      child: Container(
        color: dark ? TColors.darkerGrey : TColors.light,
        child: Stack(
          children: [
            /// Blurred Background Image
            Positioned.fill(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // Adjust blur intensity
                child: Container(
                  color: dark
                      ? Colors.black.withOpacity(0)
                      : Colors.white.withOpacity(0), // Subtle color overlay
                ),
              ),
            ),

            /// Main Large Image
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(TSizes.productImageRadius * 2),
                child: Center(
                  //child: Image(image: AssetImage(product.imageUrl)),
                  child: Image.network(product.imageUrl, fit: BoxFit.contain,),
                ),
              ),
            ),

            /// Image Slider

          /*
            Positioned(
              right: 0,
              bottom: 30,
              left: TSizes.defaultSpace,
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  itemCount: 6,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: TSizes.spaceBtwItems),
                  itemBuilder: (_, index) => TRoundedImage(
                    width: 80,
                    height: 80,
                    backgroundColor: dark ? TColors.dark : TColors.white,
                    border: Border.all(color: TColors.primary),
                    padding: const EdgeInsets.all(TSizes.sm),
                    imageUrl: TImages.productImage1,
                  ),
                ),
              ),
            ),
         */

            /// Appbar Icons

            /*
            const TAppBar(
              showBackArrow: true,
              actions: [TCircularIcon(icon: Iconsax.heart5, color: Colors.red,)],
            )*/

        TAppBar(
          showBackArrow: true,
          actions: [
            Obx(() {
              final isFav = wishlistController.isFavoriteProduct(product.id);

              return TCircularIcon(
                onPressed: () {
                  wishlistController.toggleFavoriteProduct(product);
                },
                icon:
                  isFav ? Iconsax.heart5 : Iconsax.heart, // Heart filled or outlined
                  color: isFav ? Colors.red : Colors.grey, // Red if favorite
              );
            }),
            ],
           ),
          ],
        ),
      ),
    );
  }
}
