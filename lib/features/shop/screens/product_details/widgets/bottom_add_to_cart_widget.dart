import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../data/products_data/product_model.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../cart/cart_controller.dart';

class TBottomAddToCart extends StatefulWidget {
  final Product product; // Pass the product object
  const TBottomAddToCart({super.key, required this.product});

  @override
  State<TBottomAddToCart> createState() => _TBottomAddToCartState();
}

class _TBottomAddToCartState extends State<TBottomAddToCart> {
  final CartController _cartController = Get.find<CartController>();
  int _quantity = 1; // Initial quantity

  void _incrementQuantity() {
    setState(() {
      if (_quantity < widget.product.stockQuantity) {
        _quantity++;
      } else {
        Get.snackbar(
          'Stock Limit',
          'Only ${widget.product.stockQuantity} items available.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) _quantity--;
    });
  }

  void _addToCart() {
    _cartController.addToCart(widget.product, _quantity);
    Get.snackbar(
      'Added to Cart',
      '${widget.product.name} x $_quantity added!',
      snackPosition: SnackPosition.BOTTOM,
      //backgroundColor: TColors.darkGrey,
    );
  }


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.defaultSpace,
        vertical: TSizes.defaultSpace / 2,
      ),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusLg),
          topRight: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Minus Button
              GestureDetector(
                onTap: _decrementQuantity,
                child: const TCircularIcon(
                  icon: Iconsax.minus,
                  backgroundColor: TColors.darkGrey,
                  width: 40,
                  height: 40,
                  color: TColors.white,
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),

              // Quantity Text
              Text(
                '$_quantity',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),

              // Add Button
              GestureDetector(
                onTap: _incrementQuantity,
                child: const TCircularIcon(
                  icon: Iconsax.add,
                  backgroundColor: TColors.primary,
                  width: 40,
                  height: 40,
                  color: TColors.white,
                ),
              ),
            ],
          ),

          // Add to Cart Button
          ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: TColors.primary,
              //side: const BorderSide(color: TColors.black),
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
