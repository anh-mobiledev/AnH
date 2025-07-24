import 'package:flutter/material.dart';
import 'package:pam_app/components/large_heading_widget.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/forms/register_form.dart';

class RegisterScreen extends StatefulWidget {
  static const screenId = 'register_screen';
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: _body(),
    );
  }
}

_body() {
  return SingleChildScrollView(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LargeHeadingWidget(
        heading: 'Create Account',
        headingTextColor: AppColors.secondaryColor,
        subHeading: 'Enter your Name, Email and Password for sign up.',
        subheadingTextColor: AppColors.paraColor,
        anotherTaglineText: '\n \n Already have an account ?',
        anotherTaglineColor: AppColors.primaryColor,
        subheadingTextSize: Dimensions.font16,
        taglineNavigation: true,
      ),
      const SizedBox(
        height: 25,
      ),
      const RegisterForm(),
    ]),
  );
}
