import 'package:flutter/material.dart';

import '../../constants/colours.dart';
import '../../forms/sign_in_with_username_password_form.dart';
import 'login_screen.dart';

class SignInWithUsernamePasswordScreen extends StatelessWidget {
  static const String screenId = "signinwithusernamepassword_screen";
  const SignInWithUsernamePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.secondaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(LoginScreen.screenId);
          },
        ),
        title: Text(
          'Sign in with username and password',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 50,
      ),
      SignInWithUsernamePasswordForm()
    ]));
  }
}
