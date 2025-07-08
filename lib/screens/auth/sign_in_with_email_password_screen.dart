import 'package:flutter/material.dart';
import 'package:pam_app/forms/sign_in_with_email_password_form.dart';
import 'package:pam_app/screens/auth/login_screen.dart';

import '../../constants/colours.dart';

class SignInWithEmailPasswordScreen extends StatelessWidget {
  static const String screenId = "signinwithemailpassword_screen";

  const SignInWithEmailPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    print('<=====> ${args['action']}');

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
          args['action'] == 'signin'
              ? 'Signin with email and password'
              : 'Signup with email and password',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: _body(context, args['action']),
    );
  }

  Widget _body(context, String action) {
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 50,
      ),
      SignInWithEmailPasswordForm(action: action)
    ]));
  }
}
