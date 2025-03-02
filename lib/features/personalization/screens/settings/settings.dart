import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/IcomingRequestsPage.dart';
import 'package:t_store/features/personalization/screens/profile/profile.dart';
import 'package:t_store/features/shop/screens/cart/cart.dart';
import 'package:t_store/features/shop/screens/order/order.dart';
import 'package:t_store/features/shop/screens/wishlist/wishlist.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/list_styles/settings_menu_title.dart';
import '../../../../common/widgets/list_styles/user_profile_title.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/login/login.dart';
import 'UserItemsScreen.dart';
import 'UserProjectScreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// AppBar
                  TAppBar(title: Text('Account', style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white),),),

                  /// User Profile Card
                  TUserProfileTile(onPressed: () => Get.to(() => const ProfileScreen() ),),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            /// -- Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// -- Account Settings
                  const TSectionHeading(title: 'Account Settings', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  //TSettingsMenuTile(icon: Iconsax.safe_home, title: 'My Addresses', subTitle: 'Set shopping delivery address' ,onTap: () => Get.to(() => const UserAddressScreen())),
                  TSettingsMenuTile(icon: Iconsax.shopping_cart, title: 'My Cart', subTitle: 'Add, remove products and move to checkout' ,onTap: () => Get.to(() => const CartScreen())),
                  TSettingsMenuTile(icon: Iconsax.bag_tick, title: 'My Orders', subTitle: 'In-progress and Completed Orders' ,onTap: () => Get.to(() => const OrderScreen())),
                  TSettingsMenuTile(icon: Icons.request_page_outlined, title: 'Incoming Requests', subTitle: 'Your items request' ,onTap: () => Get.to(() => const IncomingRequestsPage())),
                  TSettingsMenuTile(icon: Iconsax.heart4, title: 'Wish List', subTitle: 'Your favorite products and projects' ,onTap: () => Get.to(() => const FavouriteScreen())),
                  TSettingsMenuTile(icon: Icons.memory, title: 'My Items', subTitle: 'Your published items' ,onTap: () => Get.to(() => const UserItemsScreen())),
                  TSettingsMenuTile(icon: Icons.bubble_chart_outlined, title: 'My Projects', subTitle: 'Your published projects' ,onTap: () => Get.to(() => const UserProjectsScreen())),
                  //const TSettingsMenuTile(icon: Iconsax.discount_shape, title: 'My Coupons', subTitle: 'List of all the discounted coupons'),
                  //const TSettingsMenuTile(icon: Iconsax.notification, title: 'Notifications', subTitle: 'Set any kind of notification message'),
                  //const TSettingsMenuTile(icon: Iconsax.security_card, title: 'Account Privacy', subTitle: 'Manage data usage and connected accounts'),

                  /// -- App Settings
                  /*
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(title: 'App Settings', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const TSettingsMenuTile(icon: Iconsax.document_upload, title: 'Load Data', subTitle: 'Upload Data to your Cloud Firebase'),

                  TSettingsMenuTile(icon: Iconsax.location, title: 'GeoLocation', subTitle: 'Set recommendation based on location', trailing: Switch(value: true, onChanged: (value) {})),
                  TSettingsMenuTile(icon: Iconsax.security_user, title: 'Safe Mode', subTitle: 'Search result is safe for all ages', trailing: Switch(value: false, onChanged: (value) {}),),
                  TSettingsMenuTile(icon: Iconsax.image, title: 'HD Image Quality', subTitle: 'Set image quality to be seen', trailing: Switch(value: false, onChanged: (value) {})),
                  */

                  /// -- Logout Button
                  const SizedBox(height: TSizes.spaceBtwSections,),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.to(() => const LoginScreen()),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.red, // Set the background color to red
                        foregroundColor: Colors.white, // Set the text color to white
                        side: const BorderSide(color: Colors.red), // Set the border color to red
                        padding: const EdgeInsets.all(16), // Add some padding to the button
                      ),
                      child: const Text('Logout'),
                    ),
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections * 2.5,)
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}



