import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/screens/order/widgets/orders_list.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../cart/cart_controller.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    // Fetch purchases when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.fetchPurchases();
    });

    return Scaffold(
      //backgroundColor: const Color(0xfff3feff),
      /// -- AppBar
      appBar: TAppBar(title: Text('My Orders', style: Theme.of(context).textTheme.headlineSmall,), showBackArrow: true,),
      body: const Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),

        /// -- Orders
        child: TOrderListItems(),
      ),
    );
  }
}
