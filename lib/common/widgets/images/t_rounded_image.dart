// import 'package:flutter/material.dart';
// import '../../../utils/constants/sizes.dart';
//
// class TRoundedImage extends StatelessWidget {
//   const TRoundedImage({
//     super.key,
//     this.border,
//     this.padding,
//     this.onPressed,
//     this.width,
//     this.height,
//     this.applyImageRadius = true,
//     required this.imageUrl,
//     this.fit = BoxFit.contain,
//     this.backgroundColor,
//     this.isNetworkImage = false,
//     this.borderRadius = TSizes.md,
//   });
//
//   final double? width, height;
//   final String imageUrl;
//   final bool applyImageRadius;
//   final BoxBorder? border;
//   final Color? backgroundColor;
//   final BoxFit? fit;
//   final EdgeInsetsGeometry? padding;
//   final bool isNetworkImage;
//   final VoidCallback? onPressed;
//   final double borderRadius;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         width: width,
//         height: height,
//         padding: padding,
//         decoration: BoxDecoration(
//             border: border,
//             color: backgroundColor,
//             borderRadius: BorderRadius.circular(borderRadius)),
//         child: ClipRRect(
//           borderRadius: applyImageRadius ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
//           child: Image(fit: fit, image: isNetworkImage ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';

class TRoundedImage extends StatelessWidget {
  const TRoundedImage({
    super.key,
    this.border,
    this.padding,
    this.onPressed,
    this.width,
    this.height,
    this.applyImageRadius = true,
    required this.imageUrl,
    this.fit = BoxFit.cover, // Changed to BoxFit.cover for better image display
    this.backgroundColor,
    this.isNetworkImage = false,
    this.borderRadius = TSizes.md,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color? backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
          child: isNetworkImage
              ? Image.network(
            imageUrl,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error); // Show an error icon if the image fails to load
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child; // Return the image if fully loaded
              return const Center(
                child: CircularProgressIndicator(), // Show a loading indicator while the image is loading
              );
            },
          )
              : Image.asset(
            imageUrl,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error); // Show an error icon if the asset fails to load
            },
          ),
        ),
      ),
    );
  }
}
