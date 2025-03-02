/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/products/products_cards/product_card_vertical.dart';
import '../../../../utils/constants/sizes.dart';
import 'WishlistController.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();

    return Scaffold(
      //backgroundColor: const Color(0xfff3feff),
      appBar: TAppBar(
        title: Text(
          'Wishlist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
      ),
      body: Obx(() {
        // Fetch favorite products list
        final favoriteProducts = wishlistController.favoriteProducts;
        final favoriteProjects = wishlistController.favoriteProjects;

        if (favoriteProducts.isEmpty && favoriteProjects.isEmpty) {
          return const Center(child: Text('No items in your wishlist.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: TSizes.spaceBtwItems,
            mainAxisSpacing: TSizes.spaceBtwItems,
            childAspectRatio: 0.65,
          ),
          itemCount: favoriteProducts.length,
          itemBuilder: (_, index) {
            final product = favoriteProducts[index];
            final project = favoriteProjects[index];

            return TProductCardVertical(
              productId: product.id,
              name: product.name,
              category: product.category,
              imageUrl: product.imageUrl,
              price: product.price,
              inStock: product.inStock,
              stockQuantity: product.stockQuantity,
            );
          },
        );
      }),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/products/products_cards/product_card_vertical.dart';
import '../../../../common/widgets/products/products_cards/project_card_vertical.dart';
import '../../../../data/products_data/product_model.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../utils/constants/sizes.dart';
import 'WishlistController.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Wishlist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
      ),
      body: Obx(() {
        // Fetch favorite products and projects
        final favoriteProducts = wishlistController.favoriteProducts;
        final favoriteProjects = wishlistController.favoriteProjects;

        // Combine both lists
        final combinedFavorites = [
          ...favoriteProducts.map((product) => {'type': 'product', 'data': product}),
          ...favoriteProjects.map((project) => {'type': 'project', 'data': project}),
        ];

        if (combinedFavorites.isEmpty) {
          return const Center(child: Text('No items in your wishlist.'));
        }



        return GridView.builder(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: TSizes.spaceBtwItems,
            mainAxisSpacing: TSizes.spaceBtwItems,
            childAspectRatio: 0.65 ,
          ),
          itemCount: combinedFavorites.length,
          itemBuilder: (_, index) {
            final Map<String, dynamic> favorite = combinedFavorites[index]; // Explicitly define type
            final String type = favorite['type']; // Ensure the type is a String
            final dynamic data = favorite['data']; // Use dynamic for the data field

            // Check the type and return the appropriate card
            if (type == 'product' && data is Product) {
              final product = data;
              return TProductCardVertical(
                productId: product.id,
                name: product.name,
                category: product.category,
                imageUrl: product.imageUrl,
                price: product.price,
                inStock: product.inStock,
                stockQuantity: product.stockQuantity, description: '',
              );
            } else if (type == 'project' && data is Project) {
              final project = data; // Cast `data` as `Project`
              return TProjectCardVertical(
                project: project, // Pass the project
              );
            }
            return const SizedBox(); // Fallback widget for invalid types
          },

        );
      }),
    );
  }
}
