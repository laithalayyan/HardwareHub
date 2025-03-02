import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:t_store/features/shop/screens/checkout/checkout.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/colors.dart';
import 'cart_controller.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    return Scaffold(
      //backgroundColor: const Color(0xfff3feff),
      appBar: TAppBar(showBackArrow: true, title: Text('Cart', style: Theme.of(context).textTheme.headlineSmall),),
      body: const Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),

        /// -- Items in Cart
        child: TCartItems(),
      ),

      bottomNavigationBar: Obx(() => Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () {
            if (cartController.totalPrice > 0) {
              Get.to(() => CheckoutScreen( totalPrice: cartController.totalPrice,));
            } else {
              Get.snackbar(
                'Empty Cart',
                'Add items to the cart before proceeding to checkout.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withOpacity(0.8),
                colorText: Colors.white,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: cartController.totalPrice > 0
                ? TColors.primary
                : Colors.grey, // Change color if cart is empty
          ),
          child: Text(
            cartController.totalPrice > 0
                ? 'Request items: ${cartController.totalPrice.toStringAsFixed(2)}\₪'
                : 'Cart is Empty',
          ),
        ),
      )),

    );
  }
}

