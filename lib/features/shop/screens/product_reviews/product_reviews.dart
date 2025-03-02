import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/features/shop/screens/product_reviews/widgets/rating_progress_indicator.dart';
import 'package:t_store/features/shop/screens/product_reviews/widgets/review_details_card.dart';
import '../../../../common/widgets/products/ratings/rating_indicator.dart';
import '../../../../config/config.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ReviewService {
  static Future<Map<String, dynamic>> fetchReviewData(String itemId) async {
    final box = GetStorage();
    final token = box.read('token');
    final url = '${AppConfig.baseUrl}/api/Review/Item/$itemId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle case where averageGrade is an int or double
        final averageGrade = data['averageGrade'] is int
            ? (data['averageGrade'] as int).toDouble() // Convert int to double
            : data['averageGrade'] as double; // Use as double if already a double

        final reviews = data['reviews'] as List; // Get reviews array
        final reviewCount = reviews.length; // Count reviews

        return {
          'averageGrade': averageGrade,
          'reviews': reviews,
        };
      } else {
        throw Exception('Failed to load review data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<String> fetchUsername(String userId) async {
    final box = GetStorage();
    final token = box.read('token');
    final url = '${AppConfig.baseUrl}/api/Auth/$userId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['username'] ?? 'Unknown User'; // Return the username or a fallback
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}


class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  late Future<Map<String, dynamic>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewService.fetchReviewData(widget.itemId);
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = ReviewService.fetchReviewData(widget.itemId);
    });
  }

  void _showReviewBottomSheet() {
    double userRating = 0;
    final TextEditingController commentController = TextEditingController();

    void submitReview() async {
      if (commentController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter a comment.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (userRating == 0) {
        Get.snackbar(
          'Error',
          'Please select a rating.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final box = GetStorage();
      final token = box.read('token');
      const url = '${AppConfig.baseUrl}/api/Review';

      // Prepare the request body
      final Map<String, dynamic> body = {
        'comment': commentController.text, // lowercase 'comment'
        'grade': userRating.toInt(), // lowercase 'grade'
        'itemId': widget.itemId, // lowercase 'itemId'
      };

      // Debugging: Print the token and request body
      print('Token: $token');
      print('Request Body: $body');
      final requestBody = json.encode(body);
      print('Serialized Request Body: $requestBody');

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        );

        // Debugging: Print the response status code and body
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 201) {
          // Review submitted successfully
          Get.snackbar(
            'Success',
            'Review submitted successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Navigator.pop(context); // Close the bottom sheet
          _refreshReviews(); // Refresh the reviews
        } else {
          // Handle API error
          final errorResponse = json.decode(response.body);
          final errorMessage = errorResponse['errors'] ?? 'Failed to submit review. Please try again.';
          Get.snackbar(
            'Error',
            errorMessage.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        // Handle network or other errors
        print('Error: $e');
        Get.snackbar(
          'Error',
          'An error occurred. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "What is your rate?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Star Rating
              Center(
                child: RatingBar(
                  initialRating: userRating,
                  minRating: 0.5,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                    full: const Icon(Icons.star, color: TColors.primary),
                    half: const Icon(Icons.star_half, color: TColors.primary),
                    empty: const Icon(Icons.star_border, color: TColors.primary),
                  ),
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  onRatingUpdate: (rating) {
                    userRating = rating;
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Please share your opinion about the product",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Comment Input Field
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: "Your review",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitReview, // Call the submitReview function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Send Review",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Reviews & Ratings'),
        showBackArrow: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No review data found'));
          } else {
            final reviewData = snapshot.data!;
            final averageGrade = reviewData['averageGrade'] as double;
            final reviews = reviewData['reviews'] as List<dynamic>;

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: TSizes.defaultSpace,
                          right: TSizes.defaultSpace,
                          top: TSizes.defaultSpace / 2,
                          bottom: 80,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ratings and reviews are verified and are from people who use the same type of device that you use.",
                            ),
                            const SizedBox(height: 16.0),

                            // Overall Product Rating
                            TOverallProductRating(averageGrade: averageGrade),
                            TRatingBarIndicator(rating: averageGrade),
                            Text(
                              "${reviews.length} reviews",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 24.0),


                            // User Reviews
                            ...reviews.map((review) {
                              return FutureBuilder<String>(
                                future: ReviewService.fetchUsername(review['userId']),
                                builder: (context, usernameSnapshot) {
                                  if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (usernameSnapshot.hasError) {
                                    return Text('Error: ${usernameSnapshot.error}');
                                  } else {
                                    final username = usernameSnapshot.data ?? 'Unknown User';
                                    return UserReviewCard(
                                      comment: review['comment'] ?? 'No comment',
                                      grade: review['grade'] ?? 0,
                                      username: username,
                                    );
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Write a Review Button
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.defaultSpace,
                      vertical: TSizes.defaultSpace / 2,
                    ),
                    decoration: BoxDecoration(
                      color: dark ? TColors.darkerGrey : TColors.light,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showReviewBottomSheet,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Write a Review", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
