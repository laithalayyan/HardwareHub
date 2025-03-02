import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../../../../common/widgets/products/ratings/rating_indicator.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

/*
class UserReviewCard extends StatelessWidget {
  const UserReviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundImage: AssetImage(TImages.userProfileImage2),),
                const SizedBox(width: TSizes.spaceBtwItems),
                Text('Laith Alayyan', style: Theme.of(context).textTheme.titleLarge,),
              ],
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert),),
          ],
        ),
        const SizedBox(width: TSizes.spaceBtwItems),

        /// Review
        const Row(
          children: [
            TRatingBarIndicator(rating: 4),
            SizedBox(width: TSizes.spaceBtwItems),
            //Text('16 Dec, 2024', style: Theme.of(context).textTheme.bodyMedium,),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        const ReadMoreText(
          'Laith laith laith laith laith laith laith laith laith laith laith Laith laith laith laith laith laith laith laith laith laith laith Laith laith laith laith laith laith laith laith laith laith laith Laith laith laith laith laith laith laith laith laith laith laith',
          trimLines: 1,
          trimMode: TrimMode.Line,
          trimCollapsedText: ' show more ',
          trimExpandedText: ' show less ',
          moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TColors.primary,),
          lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TColors.primary,),
        ),
        const SizedBox(height: TSizes.spaceBtwItems,),
      ],
    );
  }
}
*/
class UserReviewCard extends StatelessWidget {
  const UserReviewCard({
    super.key,
    required this.comment,
    required this.grade,
    required this.username,
  });

  final String comment;
  final int grade;
  final String username;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundImage: AssetImage(TImages.userProfileImage2)),
                const SizedBox(width: TSizes.spaceBtwItems),
                Text(username, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        const SizedBox(width: TSizes.spaceBtwItems),

        /// Review
        Row(
          children: [
            TRatingBarIndicator(rating: grade.toDouble()),
            const SizedBox(width: TSizes.spaceBtwItems),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        ReadMoreText(
          comment,
          trimLines: 1,
          trimMode: TrimMode.Line,
          trimCollapsedText: ' show more ',
          trimExpandedText: ' show less ',
          moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TColors.primary),
          lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TColors.primary),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
      ],
    );
  }
}