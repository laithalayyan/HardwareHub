import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../custom_shapes/containers/rounded_container.dart';
import 'brand_card.dart';

/*
class TBrandShowcase extends StatelessWidget {
  const TBrandShowcase({
    super.key,
    required this.images,
    required this.categoryName,
    required this.projectCount,
  });

  final List<String> images;
  final String categoryName;
  final int projectCount;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      showBorder: true,
      borderColor: TColors.darkGrey,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.all(TSizes.md),
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Column(
        children: [
          /// Brand with Products Count
          TBrandCard(
            showBorder: false,
            categoryName: categoryName,
            count: projectCount,
            label: 'Items',
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Brand Top Product Images
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the images horizontally
              children: images.map((image) {
                return Container(
                  margin: const EdgeInsets.only(right: TSizes.sm),
                  child: TRoundedContainer(
                    height: 100,
                    width: 100, // Fixed width for each image container
                    padding: const EdgeInsets.all(TSizes.md),
                    backgroundColor: THelperFunctions.isDarkMode(context)
                        ? TColors.darkerGrey
                        : TColors.light,
                    child: Image.network(
                      image,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
*/

class TBrandShowcase extends StatelessWidget {
  final List<String> images;
  final String categoryName;
  final int projectCount;

  const TBrandShowcase({
    super.key,
    required this.images,
    required this.categoryName,
    required this.projectCount,
  });

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      showBorder: true,
      borderColor: TColors.darkGrey,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.all(TSizes.md),
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Column(
        children: [
          /// Brand with Products Count
          TBrandCard(
            showBorder: false,
            categoryName: categoryName,
            count: projectCount,
            label: 'Items',
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Brand Top 3 Product Images
          Row(
            children: images.map((image) => brandTopProductImageWidget(image, context)).toList(),
          ),
        ],
      ),
    );
  }

  Widget brandTopProductImageWidget(String image, BuildContext context) {
    return Expanded(
      child: TRoundedContainer(
        height: 100,
        //width: 50,
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.only(right: TSizes.sm),
        backgroundColor: THelperFunctions.isDarkMode(context) ? TColors.white : TColors.light,
        child: Image.network(
          image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/*
class TBrandShowcase extends StatelessWidget {
  const TBrandShowcase({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      showBorder: true,
      borderColor: TColors.darkGrey,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.all(TSizes.md),
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Column(
        children: [
          /// Brand with Products Count
          const TBrandCard(showBorder: false, categoryName: '', projectCount: 1 ,),
          const SizedBox(height: TSizes.spaceBtwItems,),

          /// Brand Top 3 Product Images
          Row(children: images.map((image) => brandTopProductImageWidget(image, context)).toList(),),
        ],
      ),
    );
  }
  Widget brandTopProductImageWidget(String image, context) {
    return Expanded(
      child: TRoundedContainer(
        height: 100,
        padding: const EdgeInsets.all(TSizes.md),
        margin: const EdgeInsets.only(right: TSizes.sm),
        backgroundColor: THelperFunctions.isDarkMode(context) ? TColors.darkerGrey : TColors.light,
        child: Image(fit: BoxFit.contain, image: AssetImage(image)),
      ),
    );
  }
}

 */