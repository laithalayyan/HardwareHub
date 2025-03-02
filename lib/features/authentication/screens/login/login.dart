import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/features/authentication/screens/login/widgets/login_form.dart';
import 'package:t_store/features/authentication/screens/login/widgets/login_header.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import '../../../../common/styles/spacing_styles.dart';
import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/social_buttons.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final bool isWeb = MediaQuery.of(context).size.width > 600; // Check if the screen is wide enough for web layout

    return Scaffold(
      body: SingleChildScrollView(
        child: isWeb
            ? Center(
          child: Container(
            width: 600, // Fixed width for the login form on web
            padding: TSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              children: [
                /// Logo, Title & Sub-Title
                const TLoginHeader(),

                /// Form
                const TLoginForm(),

                /// Divider
                TFormDivider(dividerText: TTexts.orSignInWith.capitalize!),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Footer
                const TSocialButtons(),
              ],
            ),
          ),
        )
            : Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title & Sub-Title
              const TLoginHeader(),

              /// Form
              const TLoginForm(),

              /// Divider
              TFormDivider(dividerText: TTexts.orSignInWith.capitalize!),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Footer
              const TSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}