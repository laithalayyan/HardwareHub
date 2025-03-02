
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'config/config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart';

class NotificationsService {
  // Define notification channel details
  static const AndroidNotificationDetails purchaseRequestDetails =
  AndroidNotificationDetails(
    'purchase_requests', // Channel ID
    'Purchase Requests', // Channel Name
    channelDescription: 'Notifications related to purchase requests received', // Channel Description
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  static const NotificationDetails purchaseRequestNotificationDetails = NotificationDetails(
    android: purchaseRequestDetails,
  );

  static const AndroidNotificationDetails chatMessageDetails =
  AndroidNotificationDetails(
    'chat_messages', // Channel ID
    'Chat Messages', // Channel Name
    channelDescription: 'Notifications for direct messages', // Channel Description
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  static const NotificationDetails chatNotificationDetails = NotificationDetails(
    android: chatMessageDetails,
  );
  static const AndroidNotificationDetails orderReceivedDetails =
  AndroidNotificationDetails(
    'order_received', // Channel ID
    'Order Received', // Channel Name
    channelDescription: 'Notifications when an order is marked as received', // Channel Description
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  static const NotificationDetails orderReceivedNotificationDetails = NotificationDetails(
    android: orderReceivedDetails,
  );
  // Get the local file path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get the file reference for a specific user
  Future<File> _getUserNotificationFile(String userName) async {
    final path = await _localPath;
    return File('$path/notifications_$userName.json');
  }

  // Get the unread notification count for a specific user
  Future<int> getUnreadNotificationCountForUser(String userName) async {
    final notifications = await readNotificationsForUser(userName);
    return notifications.where((notification) => !notification['isRead']).length;
  }

  // Mark all notifications as read for a specific user
  Future<void> markAllAsReadForUser(String userName) async {
    final notifications = await readNotificationsForUser(userName);
    for (var notification in notifications) {
      notification['isRead'] = true;
    }
    await writeNotificationsForUser(userName, notifications);
  }

  // Mark a single notification as read by its ID
  Future<void> markNotificationAsRead(String userName, String notificationId) async {
    final notifications = await readNotificationsForUser(userName);
    final notification = notifications.firstWhere(
          (n) => n['id'] == notificationId,
      orElse: () => {},
    );
    if (notification.isNotEmpty) {
      notification['isRead'] = true;
      await writeNotificationsForUser(userName, notifications);
    }
  }

  // Write a notification for a specific user
  Future<void> writeNotificationForUser(String userName, Map<String, dynamic> notification) async {
    try {
      final file = await _getUserNotificationFile(userName);
      List<Map<String, dynamic>> notifications = [];

      // Read existing notifications
      if (await file.exists()) {
        final contents = await file.readAsString();
        notifications = List<Map<String, dynamic>>.from(jsonDecode(contents));
      }

      // Add the new notification with a unique ID
      notification['id'] = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID
      notification['isRead'] = false; // Default to unread
      notifications.add(notification);

      // Write back to the file
      await file.writeAsString(jsonEncode(notifications));
      // Show local notification
      _showNotification(notification);

    } catch (e) {
      debugPrint('Error writing notification for user $userName: $e');
    }
  }
  Future<void> _showNotification(Map<String, dynamic> notification) async {
    NotificationDetails notificationDetails;
    if (notification['type'] == 'request') {
      notificationDetails = purchaseRequestNotificationDetails;
    }else if (notification['type'] == 'chat') {
      notificationDetails = chatNotificationDetails;
    }else if (notification['title'] == 'Order Received')
    {
      notificationDetails = orderReceivedNotificationDetails;
    }
    else{
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('general_notifications', 'General Notifications',
          channelDescription: 'General app-related notifications', importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
      notificationDetails = const NotificationDetails(
        android: androidNotificationDetails,
      );
    }

    await flutterLocalNotificationsPlugin.show(
      0,
      notification['title'] ?? 'No Title',
      notification['message'] ?? 'No Message',
      notificationDetails,
    );

  }

  // Read notifications for a specific user
  Future<List<Map<String, dynamic>>> readNotificationsForUser(String userName) async {
    try {
      final file = await _getUserNotificationFile(userName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        return List<Map<String, dynamic>>.from(jsonDecode(contents));
      }
    } catch (e) {
      debugPrint('Error reading notifications for user $userName: $e');
    }
    return [];
  }

  // Fetch the latest notifications (e.g., last 5 notifications)
  Future<List<Map<String, dynamic>>> fetchLatestNotifications(String userName, {int limit = 5}) async {
    final notifications = await readNotificationsForUser(userName);
    notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp'])); // Sort by timestamp
    return notifications.take(limit).toList();
  }

  // Delete a specific notification by its ID
  Future<void> deleteNotification(String userName, String notificationId) async {
    final notifications = await readNotificationsForUser(userName);
    notifications.removeWhere((n) => n['id'] == notificationId);
    await writeNotificationsForUser(userName, notifications);
  }

  // Clear all notifications for a specific user
  Future<void> clearAllNotifications(String userName) async {
    final file = await _getUserNotificationFile(userName);
    if (await file.exists()) {
      await file.writeAsString(jsonEncode([])); // Clear the file
    }
  }

  // Write notifications for a specific user
  Future<void> writeNotificationsForUser(String userName, List<Map<String, dynamic>> notifications) async {
    try {
      final file = await _getUserNotificationFile(userName);
      await file.writeAsString(jsonEncode(notifications));
    } catch (e) {
      debugPrint('Error writing notifications for user $userName: $e');
    }
  }

  Future<String?> fetchItemName(String itemId) async {
    final token = GetStorage().read('token');
    const url = AppConfig.baseUrl;
    try {
      final response = await http.get(
        Uri.parse('$url/api/Items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);
        return item['name'];
      } else {
        throw Exception('Failed to fetch item details for ID $itemId: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching item name for ID $itemId: $e');
      return null;
    }
  }
}



