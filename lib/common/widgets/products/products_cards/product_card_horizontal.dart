import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../data/products_data/product_model.dart';
import '../../../../features/shop/screens/cart/cart_controller.dart';
import '../../../../features/shop/screens/wishlist/WishlistController.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../styles/shadows.dart';
import '../../custom_shapes/containers/rounded_container.dart';
import '../../icons/t_circular_icon.dart';
import '../../images/t_rounded_image.dart';
import '../../texts/product_title_text.dart';
import '../../texts/t_brand_title_text_with_verified_icon.dart';
import '../product_price/product_price_text.dart';

class TProductCardHorizontal extends StatelessWidget {
  final String productId;
  final String name;
  final String imageUrl;
  final String price;
  final String categoryName;

  const TProductCardHorizontal({
    super.key,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    return Container(
      width: 310,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        boxShadow: [TShadowStyle.horizontalProductShadow],
        borderRadius: BorderRadius.circular(TSizes.productImageRadius),
        color: dark ? TColors.darkerGrey : TColors.lightContainer,
      ),
      child: Row(
        children: [
          /// Thumbnail
          TRoundedContainer(
            height: 120,
            padding: const EdgeInsets.all(TSizes.sm),
            backgroundColor: dark ? TColors.dark : TColors.white,
            child: Stack(
              children: [
                /// -- Thumbnail Image
                SizedBox(
                  height: 120,
                  width: 120,
                  child: TRoundedImage(
                      isNetworkImage:true ,
                      imageUrl: imageUrl,
                      applyImageRadius: true,
                      backgroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                ),

                /// -- Favourite Icon Button
                Positioned(
                  top: 0,
                  right: 0,
                  child: Obx(() {
                    final isFav = wishlistController.isFavoriteProduct(productId);
                    return TCircularIcon(
                      icon: isFav ? Iconsax.heart5 : Iconsax.heart,
                      color: isFav ? Colors.red : Colors.grey,
                      onPressed: () {
                        final product = Product(
                          id: productId,
                          name: name,
                          category: categoryName,
                          imageUrl: imageUrl,
                          price: double.parse(price),
                          inStock: true, // Adjust as needed
                          stockQuantity: 10, // Adjust as needed
                          description: 'This is a description for $name.',
                        );
                        wishlistController.toggleFavoriteProduct(product);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          /// Details
          SizedBox(
            width: 172,
            child: Padding(
              padding: const EdgeInsets.only(top: TSizes.sm, left: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TProductTitleText(title: name, smallSize: true),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      TBrandTitleWithVerifiedIcon(
                        title: categoryName,
                        image: 'assets/icons/brands/motor3.png',
                      ),
                    ],
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Pricing
                      Flexible(child: TProductPriceText(price: price)),

                      /// Add to cart button
                      Container(
                        decoration: const BoxDecoration(
                          color: TColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(TSizes.cardRadiusMd),
                            bottomRight: Radius.circular(TSizes.productImageRadius),
                          ),
                        ),
                        child: SizedBox(
                          width: TSizes.iconLg * 1.2,
                          height: TSizes.iconLg * 1.2,
                          child: Center(
                            child: Obx(() {
                              final quantityInCart = cartController.getProductQuantity(productId);
                              return IconButton(
                                icon: Text(
                                  quantityInCart > 0 ? '$quantityInCart' : '+',
                                  style: const TextStyle(
                                    color: TColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  final product = Product(
                                    id: productId,
                                    name: name,
                                    category: categoryName,
                                    imageUrl: imageUrl,
                                    price: double.parse(price),
                                    inStock: true, // Adjust as needed
                                    stockQuantity: 10, // Adjust as needed
                                    description: 'This is a description for $name.',
                                  );
                                  cartController.addToCart(product, 1);
                                  Get.snackbar('Cart', '$name added to cart!');
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}