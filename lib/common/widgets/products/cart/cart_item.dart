
import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../images/t_rounded_image.dart';
import '../../texts/product_title_text.dart';
import '../../texts/t_brand_title_text_with_verified_icon.dart';

class TCartItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final VoidCallback onRemove;
  final bool showDeleteButton;
  final String cat;

  const TCartItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.onRemove,
    this.showDeleteButton = true,
    this.cat = ''
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Image
        TRoundedImage(
          isNetworkImage: true,
          imageUrl: imageUrl,
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(2),
          backgroundColor: THelperFunctions.isDarkMode(context)
              ? TColors.darkerGrey
              : TColors.light,
        ),
        const SizedBox(width: TSizes.spaceBtwItems),

        /// Title, Price, & Size
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TBrandTitleWithVerifiedIcon(
                title: cat, // Placeholder for category
                image: 'assets/icons/brands/motor3.png',
              ),
              TProductTitleText(title: name),
              Text('${price.toStringAsFixed(2)}\₪',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),


        /// Remove Button
        if(showDeleteButton)... {
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onRemove,
          ),
        }

      ],
    );
  }
}
