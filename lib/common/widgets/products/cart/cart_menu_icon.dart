/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/shop/screens/cart/cart.dart';

import '../../../../features/shop/screens/cart/cart_controller.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';


class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({
    super.key,
    this.iconColor ,
    this.counterBgColor,
    this.counterTextColor,
    required this.onPressed,
  });

  final VoidCallback onPressed;
  final Color? iconColor, counterBgColor, counterTextColor;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final dark = THelperFunctions.isDarkMode(context);
    return Stack(
      children: [
        IconButton(onPressed: () => Get.to(() => const CartScreen()), icon: Icon(Iconsax.shopping_bag, color: iconColor,)),
        Positioned(
          right: 0,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
                color: counterBgColor ?? (dark ? TColors.white : TColors.black),
                borderRadius: BorderRadius.circular(100)
            ),
            child: Center(
              child: Text('2', style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.white, fontSizeFactor: 0.8),),
            ),
          ),
        ),
      ],
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/shop/screens/cart/cart.dart';
import '../../../../features/shop/screens/cart/cart_controller.dart';
import '../../../../utils/helpers/helper_functions.dart';

class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({
    super.key,
    this.iconColor,
    this.counterBgColor,
    this.counterTextColor,
    required this.onPressed,
  });

  final VoidCallback onPressed;
  final Color? iconColor, counterBgColor, counterTextColor;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final dark = THelperFunctions.isDarkMode(context);

    return Stack(
      children: [
        /// Shopping Cart Icon
        IconButton(
          onPressed: () => Get.to(() => const CartScreen()),
          icon: Icon(Iconsax.shopping_bag, color: iconColor),
        ),

        /// Counter Badge
        Positioned(
          right: 0,
          top: 0,
          child: Obx(() {
            final totalItems = cartController.totalItems.value; // Reactive cart count
            return totalItems > 0
                ? Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              // width: 18,
              // height: 18,
              // decoration: BoxDecoration(
              //   color: dark ? Colors.red : Colors.red,
              //   borderRadius: BorderRadius.circular(100),
              ),


                child: Text(
                  totalItems.toString(), // Display dynamic count
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  // style: Theme.of(context)
                  //     .textTheme
                  //     .labelLarge!
                  //     .apply(color: dark ? TColors.white : TColors.white, fontSizeFactor: 0.8),
                ),
                /*child: Text(
                  totalItems.toString(), // Display dynamic count
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: dark ? TColors.black : TColors.white,
                    fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! * 0.8,
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),*/

            )
                : const SizedBox(); // Don't show counter if 0 items
          }),
        ),
      ],
    );
  }
}
