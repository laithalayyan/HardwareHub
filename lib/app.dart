import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:t_store/features/authentication/screens/onboarding/onboarding.dart';
import 'package:t_store/features/authentication/screens/login/login.dart'; // Import your Login Screen
import 'package:t_store/utils/constants/text_strings.dart';
import 'package:t_store/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: TTexts.appName,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      // initialBinding: GeneralBindings(),
      home: kIsWeb ? const LoginScreen() : const OnBoardingScreen(), // Redirect to LoginScreen if on web
    );
  }
}