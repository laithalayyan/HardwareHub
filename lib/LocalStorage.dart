import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  // Get the local file path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get the file reference
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notifications.json');
  }

  // Read notifications from the file
  Future<List<Map<String, dynamic>>> readNotifications() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        return jsonList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error reading notifications: $e');
    }
    return [];
  }

  // Write notifications to the file
  Future<void> writeNotifications(List<Map<String, dynamic>> notifications) async {
    try {
      final file = await _localFile;
      final jsonString = jsonEncode(notifications);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error writing notifications: $e');
    }
  }
}