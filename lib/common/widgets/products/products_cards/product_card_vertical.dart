import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/widgets/icons/t_circular_icon.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';
import '../../../../data/products_data/product_model.dart';
import '../../../../features/shop/screens/cart/cart_controller.dart';
import '../../../../features/shop/screens/product_details/product_detail.dart';
import '../../../../features/shop/screens/wishlist/WishlistController.dart';
import '../../../styles/shadows.dart';
import '../../../widgets/custom_shapes/containers/rounded_container.dart';
import '../../../widgets/images/t_rounded_image.dart';
import '../../../widgets/products/product_price/product_price_text.dart';
import '../../../widgets/texts/product_title_text.dart';
import '../../../widgets/texts/t_brand_title_text_with_verified_icon.dart';

class TProductCardVertical extends StatelessWidget {
  final String productId;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final bool inStock; // Add inStock
  final int stockQuantity;
  final String description; // Add stockQuantity

  const TProductCardVertical({
    super.key,
    required this.productId,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.inStock,
    required this.stockQuantity,
    required this.description ,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreen(
        product: Product(
          id: productId,
          name: name,
          category: category,
          imageUrl: imageUrl,
          price: price,
          inStock: inStock, // Default value; adjust as needed
          stockQuantity: stockQuantity, // Add stockQuantity
          description: description, // Placeholder
        ),
      )),

      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          children: [
            /// Thumbnail, wishlist button, discount tag
            TRoundedContainer(
              height: 180,
              padding: const EdgeInsets.all(TSizes.sm),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Stack(
                children: [
                  /// -- Thumbnail Image
                  TRoundedImage(
                    imageUrl: imageUrl,
                    applyImageRadius: true,
                      isNetworkImage: true
                  ),

                  /// -- Favorite Icon Button
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Obx(() {
                      final isFav = wishlistController.isFavoriteProduct(productId);
                      return IconButton(
                        icon: TCircularIcon(icon: isFav ? Iconsax.heart5 : Iconsax.heart, color: isFav ? Colors.red : Colors.grey,),
                        onPressed: () {
                          final product = Product(
                            id: productId,
                            name: name,
                            category: category,
                            imageUrl: imageUrl,
                            price: price,
                            inStock: inStock,
                            stockQuantity: stockQuantity,
                            description: description,
                          );
                          wishlistController.toggleFavoriteProduct(product);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),


            /// -- Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.sm), // Ensure consistent horizontal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align everything to the left
                children: [
                  /// Product Title
                  Align(
                    alignment: Alignment.centerLeft, // Explicitly align to the left
                    child: TProductTitleText(
                      title: name,
                      smallSize: true,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),

                  /// Category
                  Align(
                    alignment: Alignment.centerLeft, // Explicitly align to the left
                    child: TBrandTitleWithVerifiedIcon(
                      title: category,
                      image: 'assets/icons/brands/motor3.png',
                    ),
                  ),
                ],
              ),
            ),


            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Price
                Padding(
                  padding: const EdgeInsets.only(left: TSizes.sm),
                  child: TProductPriceText(
                    price: price.toString(),
                    isLarge: true,
                  ),
                ),

                /// Add to cart button
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
                              category: category,
                              imageUrl: imageUrl,
                              price: price,
                              inStock: inStock,
                              stockQuantity: stockQuantity,
                              description: description ,
                            );
                            cartController.addToCart(product, 1);
                            //Get.snackbar('Cart', '$name added to cart!');
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
    );
  }
}
