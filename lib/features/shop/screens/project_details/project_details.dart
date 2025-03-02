import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:t_store/features/shop/screens/project_details/slider2.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import '../../../../chatPage.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../data/project_data/project_model.dart';
import '../../../../data/project_data/project_service.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project; // Accept the Project object

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late Future<Map<String, dynamic>> _projectDetailsFuture;
  late Future<String> _ownerUsernameFuture;
  final ProjectService _projectService = ProjectService();



  @override
  void initState() {
    super.initState();
    // Fetch additional details using the project.id
    _projectDetailsFuture = _projectService.fetchProjectDetails(widget.project.id);
    _ownerUsernameFuture = Future.value('');
    //_ownerUsernameFuture = _projectService.fetchOwnerUsername(widget.project.userId);
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final GetStorage storage = GetStorage();
    final String loggedInUsername = storage.read('username') ?? '';

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _projectDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final projectDetails = snapshot.data!;
          final items = projectDetails['items'] as List<dynamic>;

          // Extract userId from project details
          final String userId = projectDetails['userId'];

          // Fetch owner's username using the userId
          _ownerUsernameFuture = _projectService.fetchOwnerUsername(userId);

          return SingleChildScrollView(
            child: Column(
              children: [
                /// 1 - Product Image Slider
                ProjectSlider(project: widget.project), // Use the project object

                /// Project Details
                Padding(
                  padding: const EdgeInsets.only(right: TSizes.defaultSpace, left: TSizes.defaultSpace, bottom: TSizes.defaultSpace,),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      /// Project Name
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.project.name, // Use the project object
                          style: Theme.of(context)
                              .textTheme.headlineSmall?.copyWith(
                              fontSize: 30
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      // /// Rating & Share Button
                      // const TRatingAndShare(),
                      // const SizedBox(height: TSizes.spaceBtwItems),

                      /// Description
                      const TSectionHeading(
                          title: 'Description', showActionButton: false),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      ReadMoreText(
                        widget.project.description, // Use the project object
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' Show more ',
                        trimExpandedText: ' Less ',
                        moreStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800),
                        lessStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 15),

                      /// Components Used Section
                      const Divider(),
                      const SizedBox(height: 15),
                      const TSectionHeading(
                        title: 'Components Used',
                        showActionButton: false,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      SizedBox(
                        height: 120, // Height for the horizontal slider
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: TSizes.spaceBtwItems),
                          itemBuilder: (context, index) {
                            final component = items[index];
                            return _ComponentCard(
                              name: component['name'],
                              image: component['itemImageUrl'],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      //const Divider(),
                      TSectionHeading(title: 'Cost : ${projectDetails['cost']}', showActionButton: false),
                      const SizedBox(height: 12),

                      /// Owner Section
                      FutureBuilder<String>(
                        future: _ownerUsernameFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData) {
                            return const Text('No owner data found');
                          }

                          final ownerUsername = snapshot.data!;
                          /*return Row(
                            children: [
                              TSectionHeading(
                                title: 'Owner: $ownerUsername',
                                showActionButton: false,
                              ),
                              const SizedBox(width: 3),

                              IconButton(
                                icon: const Icon(Iconsax.message, size: 25), // Chat icon
                                onPressed: () {
                                  // Navigate to chat screen or perform any action
                                  Get.to(() => ()); // Example: Navigate to a chat screen
                                },
                              ),
                            ],
                          );*/
                          const SizedBox(height: 4);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                            children: [
                              // Owner's Name
                              TSectionHeading(
                                title: 'Owner: $ownerUsername',
                                showActionButton: false,
                              ),
                              const SizedBox(height: 12), // Add spacing between the name and the underline

                              // Underlined Text with Chat Icon
                              InkWell(
                                onTap: () async {
                                  // Get the logged-in user's username
                                  final String loggedInUsername = storage.read('username') ?? '';

                                  // Get the owner's username
                                  final String ownerUsername = snapshot.data!;

                                  // Create a unique chat ID using the usernames
                                  final String chatId = _generateChatId(loggedInUsername, ownerUsername);

                                  // Navigate to the chat screen
                                  Get.to(() => ChatScreen(
                                    chatId: chatId,
                                    currentUserUsername: loggedInUsername,
                                    otherUserUsername: ownerUsername,
                                  ));

                                  // Create or update the chat in Firebase
                                  await _createOrUpdateChat(chatId, loggedInUsername, ownerUsername);
                                },
                                child: Row(
                                  children: [
                                    // Underlined Text
                                    Text(
                                      'Chat with Owner',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        decoration: TextDecoration.underline,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 4), // Add spacing between text and icon

                                    // Chat Icon
                                    const Icon(Iconsax.message, size: 22,), // Chat icon
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      /// Reviews Section
                      // const Divider(),
                      // const SizedBox(height: 5),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     const TSectionHeading(
                      //         title: 'Reviews (199)', showActionButton: false),
                      //     IconButton(
                      //       icon: const Icon(Iconsax.arrow_right_3, size: 18),
                      //       onPressed: () =>
                      //           Get.to(() => const ProductReviewsScreen()),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: TSizes.spaceBtwSections),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _generateChatId(String user1, String user2) {
  // Sort the usernames to ensure consistency
  final List<String> sortedUsernames = [user1, user2]..sort();
  return sortedUsernames.join('_'); // Combine usernames with an underscore
}

Future<void> _createOrUpdateChat(String chatId, String user1, String user2) async {
  final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

  // Check if the chat already exists
  final chatDoc = await chatRef.get();
  if (!chatDoc.exists) {
    // Create a new chat
    await chatRef.set({
      'participants': [user1, user2],
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

/// Component Card Widget
class _ComponentCard extends StatelessWidget {
  final String name;
  final String image;

  const _ComponentCard({required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          child: Image.network(
            image,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}