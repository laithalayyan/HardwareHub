import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/features/authentication/screens/signup/widgets/terms_conditions_checkbox.dart';
import '../../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../login/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TSignupForm extends StatefulWidget {
  const TSignupForm({super.key});

  @override
  State<TSignupForm> createState() => _TSignupFormState();
}

class _TSignupFormState extends State<TSignupForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError; // State to store the email error

  bool _isPasswordVisible = false; // For toggling password visibility
  bool _isAgreed = false; // For checkbox state

  Future<void> _signup() async {
    const url = 'https://appserver-cjhhfkd0czg4f8ec.canadacentral-01.azurewebsites.net/api/Auth/Register';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'phoneNumber': _phoneController.text,
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, navigate to the verify email screen
      Get.to(() => SuccessScreen(
        image: TImages.animation7,
        title: TTexts.yourAccountCreatedTitle,
        subTitle: TTexts.yourAccountCreatedSubTitle,
        onPressed: () => Get.to(() => const LoginScreen()),
      ));
    } else {
      // If the server did not return a 200 OK response, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up: ${response.body}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  bool _validateEmail(String email) {
    final RegExp regex = RegExp(r'^s\d{8}@stu\.najah\.edu$');
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// First Name & Last Name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: TTexts.firstName, prefixIcon: Icon(Iconsax.user)),
                  validator: (value) => value == null || value.isEmpty ? 'First name is required' : null,
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: TTexts.lastName, prefixIcon: Icon(Iconsax.user)),
                  validator: (value) => value == null || value.isEmpty ? 'Last name is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Username
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: TTexts.username, prefixIcon: Icon(Iconsax.user_edit)),
            validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: TTexts.email, prefixIcon: Icon(Iconsax.direct)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                setState(() {
                  _emailError = 'Email is required';
                });
                return '';
              }
              if(!_validateEmail(value)){
                setState(() {
                  _emailError = 'Email must follow the format: s[8 numbers]@stu.najah.edu';
                });
                return '';
              }
              setState(() {
                _emailError = null;
              });
              return null;
            },
            onChanged: (value) {
              setState(() {
                _emailError = null; // Clear error message when typing
              });
            },
          ),
          if (_emailError != null)
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 4.0), // Add some left margin and top padding
              child: Text(
                _emailError!,
                style: const TextStyle(color: Colors.red, fontSize: 12.0,),
              ),
            ),
          const SizedBox(height: TSizes.spaceBtwInputFields),


          /// Phone Number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: TTexts.phoneNo, prefixIcon: Icon(Iconsax.call)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              if (!value.startsWith('05') || value.length != 10 || !RegExp(r'^\d+$').hasMatch(value)) {
                return 'Phone number must start with "05" and be exactly 10 digits long';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible, // Toggle visibility
            decoration: InputDecoration(
              labelText: TTexts.password,
              prefixIcon: const Icon(Iconsax.password_check),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash),
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
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Terms and Conditions Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _isAgreed,
                onChanged: (value) {
                  setState(() {
                    _isAgreed = value ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAgreed = !_isAgreed;
                    });
                  },
                  child: const TTermsAndConditionsCheckbox(),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          /// Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (!_isAgreed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You must agree to the Terms & Conditions'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (_formKey.currentState?.validate() ?? false) {
                  _signup();
                  //Get.to(() => const VerifyEmailScreen());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please correct the errors in the form'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(TTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}

