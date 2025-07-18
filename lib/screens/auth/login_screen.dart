import 'package:pam_app/components/large_heading_widget.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/forms/login_form.dart';

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const String screenId = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: _body(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        LargeHeadingWidget(
            heading: 'Welcome', subHeading: 'Sign in to Continue'),
        LogInForm(),
      ]),
    );
  }
}
