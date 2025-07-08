import 'package:flutter/material.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/forms/reset_form.dart';
import 'package:pam_app/screens/auth/sign_in_with_email_password_screen.dart';
import 'package:pam_app/screens/auth/sign_in_with_username_password_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String screenId = 'reset_password_screen';
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    //signinemail
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.secondaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (args['action'] == 'signinemail') {
              Navigator.of(context).pushNamed(
                  SignInWithEmailPasswordScreen.screenId,
                  arguments: {'action': 'signin'});
            } else if (args['action'] == 'signinusername') {
              Navigator.of(context).pushNamed(
                  SignInWithUsernamePasswordScreen.screenId,
                  arguments: {'action': 'signin'});
            }
          },
        ),
        title: Text(
          'Forgot Password',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ResetForm(),
            ]),
      ),
    );
  }
}
