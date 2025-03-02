import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:t_store/features/authentication/screens/signup/signup.dart';
import 'package:t_store/navigation_menu.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../NotificationsService.dart';
import '../../../../../config/config.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../admin.dart';
//import 'path_to_your_config_file/config.dart'; // Import the config file


class TLoginForm extends StatefulWidget {
  const TLoginForm({super.key});

  @override
  State<TLoginForm> createState() => _TLoginFormState();
}

class _TLoginFormState extends State<TLoginForm> {
  final NotificationsService _notificationsService = NotificationsService();

  final _formKey = GlobalKey<FormState>();

  // Controllers for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  Future<void> _login() async {
    const url = '${AppConfig.baseUrl}/api/Auth/Login'; // Use the base URL from config

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _emailController.text, // Use email as username
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Parse the response body to get the token
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String token = responseData['jwtToken']; // Assuming the token is in the response
      final String username = _emailController.text;

      // Store the token in GetStorage
      final storage = GetStorage();
      storage.write('token', token);
      storage.write('username', username); // Store the username
      // Fetch user data after successful login
      await _fetchUserData(token);


      if (username == 'Admin') {
        Get.offAll(() => const AdminDashboard());
      } else {
        Get.offAll(() => const NavigationMenu());
      }
    } else {
      // Show an error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _fetchUserData(String token) async {
    const url = '${AppConfig.baseUrl}/api/Auth';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String email = responseData['email']; // Assuming email is in the response
        final String id = responseData['id'];
        // Extract the first three numbers after 's'
        final RegExp regex = RegExp(r'^s(\d{3})');
        final match = regex.firstMatch(email);
        if (match != null) {
          final String extractedNumbers = match.group(1)!;
          final storage = GetStorage();
          storage.write('firstThreeNumbers', extractedNumbers);
          storage.write('id', id);
          print('id: $id');
          print('Extracted numbers and stored: $extractedNumbers');
        }else {
          print('Could not find or extract first three numbers.');
        }
      } else {
        print('Failed to fetch user data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            /// Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: TTexts.username,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'username is required';
                }
                // if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                //   return 'Enter a valid email';
                // }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Password
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: TTexts.password,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            /// Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Remember me
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text(TTexts.rememberMe),
                  ],
                ),

                /// Forget Password
                TextButton(
                  onPressed: () => Get.to(() => ForgetPassword()),
                  child: const Text(TTexts.forgetPassword),
                )
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _login(); // Call the login function
                  } else {
                    // Show a SnackBar if the form is invalid
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please correct the errors in the form'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(TTexts.signIn),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignupScreen()),
                child: const Text(TTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}