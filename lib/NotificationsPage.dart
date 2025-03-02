import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/shop/screens/order/order.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'IcomingRequestsPage.dart';
import 'NotificationsService.dart';
import 'chatPage.dart';
import 'common/widgets/appbar/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

/*
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsService _notificationsService = NotificationsService();
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Get the logged-in user (recipient user)
    final loggedInUser = GetStorage().read('username');

    // Fetch notifications for the logged-in user
    final notifications = await _notificationsService.readNotificationsForUser(loggedInUser);
    setState(() {
      _notifications = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(title: Text('Notifications'), showBackArrow: true,),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff3e6275),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(
                  Icons.notifications,
                  color: Colors.white
                ),
                title: Text(
                  notification['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] ?? 'No Message',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['timestamp'] ?? 'No Timestamp',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
                trailing: !notification['isRead']
                    ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
*/



class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsService _notificationsService = NotificationsService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    // Get the logged-in user (recipient user)
    final loggedInUser = GetStorage().read('username');

    // Fetch notifications for the logged-in user
    final notifications = await _notificationsService.readNotificationsForUser(loggedInUser);
    notifications.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp']))); // Sort by timestamp
    // Fetch item names for purchase requests
    await _fetchItemNames(notifications);
    setState(() {
      _notifications = notifications;
      _isLoading= false;
    });
  }

  Future<void> _fetchItemNames(List<Map<String, dynamic>> notifications) async {
    for (var notification in notifications) {
      if (notification['type'] == 'request') {
        final message = notification['message'];
        // Extract item ID from the message
        final RegExp itemIdRegex = RegExp(r'items of (\d+)');
        final match = itemIdRegex.firstMatch(message);
        if (match != null) {
          final itemId = match.group(1);
          // Fetch item details
          final itemName = await _fetchItemName(itemId!);
          if (itemName != null) {
            notification['message'] = message.replaceAll(itemId, itemName); // replace the id with the name
          }
        }
      }
    }
  }

  Future<String?> _fetchItemName(String itemId) async {
    try {
      final notificationsService = NotificationsService();
      final itemName = await notificationsService.fetchItemName(itemId);
      return itemName;
    } catch (e) {
      debugPrint("Error fetching item name: $e");
      return null;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(title: Text('Notifications'), showBackArrow: true,),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('No Notifications'))
          :ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.parse(notification['timestamp']));
          final String senderUsername = notification['message'].split(' has requested to buy ')[0];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(
                    Icons.notifications,
                    color: Colors.white
                ),
                title: Text(
                  notification['title'] ?? 'No Title',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] ?? 'No Message',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDateTime,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white
                      ),
                    ),
                    // Button only if notification type is 'request'
                    if (notification['title'] == 'Order Accepted')
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Get.to(() => const OrderScreen());
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white, // text color
                            backgroundColor: Colors.blueGrey,
                            side: const BorderSide(color: Colors.white),// border color
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Order', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    // Button only if notification type is 'request'
                    if (notification['type'] == 'request')
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0,),
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Get.to(() => const IncomingRequestsPage());
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white, // text color
                                backgroundColor: Colors.blueGrey,
                                side: const BorderSide(color: Colors.white),// border color
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('View Request', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 22),
                            OutlinedButton(
                              onPressed: () async {
                                // Get the logged-in user's username
                                final String loggedInUsername = GetStorage().read('username') ?? '';

                                // Create a unique chat ID using the usernames
                                final String chatId = _generateChatId(loggedInUsername, senderUsername);

                                // Create or update the chat (Firebase)
                                await _createOrUpdateChat(chatId, loggedInUsername, senderUsername);

                                // Navigate to the chat screen (replace with your actual chat screen)
                                Get.to(() => ChatScreen(
                                  chatId: chatId,
                                  currentUserUsername: loggedInUsername,
                                  otherUserUsername: senderUsername,
                                ));
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueGrey,
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:  Text('Chat with $senderUsername', style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: !notification['isRead']
                    ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
