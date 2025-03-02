import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:t_store/utils/constants/text_strings.dart';

import '../../../../config/config.dart';
import '../../../../utils/constants/sizes.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
//import 'path_to_your_config_file/config.dart'; // Import the config file

class ForgetPassword extends StatelessWidget {
  ForgetPassword({super.key});

  final TextEditingController _emailController = TextEditingController(); // Add this line

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim(); // Get the email from the controller

    if (email.isEmpty) {
      // Show an error if the email field is empty
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    const url = '${AppConfig.baseUrl}/api/Auth/ForgotPassword'; // Use the base URL from config

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      // If the request is successful, navigate to the ResetPassword screen
      Get.off(() => const ResetPassword());
    } else {
      // If the request fails, show an error message
      Get.snackbar(
        'Error',
        'Failed to send reset password request: ${response.body}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Headings
            Text(TTexts.forgetPasswordTitle, style: Theme.of(context).textTheme.headlineMedium,),
            const SizedBox(height: TSizes.spaceBtwItems,),
            Text(TTexts.forgetPasswordSubTitle, style: Theme.of(context).textTheme.labelMedium,),
            const SizedBox(height: TSizes.spaceBtwSections * 2,),

            /// Text Field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: TTexts.email, prefixIcon: Icon(Iconsax.direct_right)),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Submit Button
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _forgotPassword, child: const Text(TTexts.submit)),
            ),
          ],
        ),
      ),
    );
  }
}


