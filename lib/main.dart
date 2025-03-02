import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'features/shop/screens/cart/cart_controller.dart';
import 'features/shop/screens/wishlist/WishlistController.dart';
import 'package:get_storage/get_storage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'NotificationsService.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {

  // Register WishlistController globally
  Get.put(WishlistController());
  Get.put(CartController()); // Initialize CartController globally
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/logo');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}