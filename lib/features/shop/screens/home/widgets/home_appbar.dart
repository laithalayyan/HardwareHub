/*import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../chatHomePage.dart';
import '../../../../../chatPage.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/products/cart/cart_menu_icon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';


class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final String? username = storage.read('username'); // Retrieve the username from storage
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TTexts.homeAppbarTitle, style: Theme.of(context).textTheme.labelMedium!.apply(color: TColors.grey)),
          Text(username!,  style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white))
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat, color: TColors.white),
          onPressed: () {
            final email = GetStorage().read('email'); // Fetch email from storage
            if (email != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatHomePage(currentUserUsername: username,), // Pass the email to ChatScreen
                ),
              );
            } else {
              // Handle error if email is not found
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User email not found. Please log in again.'),
                ),
              );
            }
          },
        ),
        TCartCounterIcon(onPressed: () {}, iconColor: TColors.white, )
      ],
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../NotificationsPage.dart';
import '../../../../../NotificationsService.dart';
import '../../../../../chatHomePage.dart';
import '../../../../../chat_service.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/products/cart/cart_menu_icon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final String? username = storage.read('username'); // Retrieve the username from storage
    final ChatService chatService = ChatService();
    final NotificationsService notificationsService = NotificationsService();

    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TTexts.homeAppbarTitle, style: Theme.of(context).textTheme.labelMedium!.apply(color: TColors.grey)),
          Text(username!, style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white)),
        ],
      ),
      actions: [
        // Notifications Icon with Unread Count
        StreamBuilder<int>(
          stream: Stream.periodic(const Duration(seconds: 1), (_) async {
            return await notificationsService.getUnreadNotificationCountForUser(username!);
          }).asyncMap((event) => event),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Icon(Icons.notifications, color: TColors.white); // Show loading state
            } else if (snapshot.hasError) {
              return const Icon(Icons.notifications, color: TColors.white); // Show error state
            } else {
              final unreadCount = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: TColors.white),
                    onPressed: () {
                      // Navigate to the Notifications Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      ).then((_) {
                        // Mark all notifications as read when returning from the Notifications Page
                        notificationsService.markAllAsReadForUser(username!);
                      });
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),

        // Chat Icon with Unread Message Count
        StreamBuilder<int>(
          stream: chatService.getUnreadMessageCountStream(username), // Fetch unread message count
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Icon(Icons.chat, color: TColors.white); // Show loading state
            } else if (snapshot.hasError) {
              return const Icon(Icons.chat, color: TColors.white); // Show error state
            } else {
              final unreadCount = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat, color: TColors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatHomePage(currentUserUsername: username),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
        TCartCounterIcon(onPressed: () {}, iconColor: TColors.white),
      ],
    );
  }
}

