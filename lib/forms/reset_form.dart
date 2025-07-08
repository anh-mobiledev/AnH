import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/validators.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/screens/auth/sign_in_with_email_password_screen.dart';

import '../services/auth.dart';

class ResetForm extends StatefulWidget {
  const ResetForm({
    Key? key,
  }) : super(key: key);

  @override
  State<ResetForm> createState() => _ResetFormState();
}

class _ResetFormState extends State<ResetForm> {
  Auth authService = Auth();
  late final TextEditingController _emailController;
  late final FocusNode _emailNode;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _emailController = TextEditingController();
    _emailNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  focusNode: _emailNode,
                  controller: _emailController,
                  validator: (value) {
                    return validateEmail(
                        value, EmailValidator.validate(_emailController.text));
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
                  height: 25,
                ),
                roundedButton(
                    context: context,
                    bgColor: AppColors.secondaryColor,
                    text: 'Send Reset Link',
                    textColor: AppColors.whiteColor,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        FirebaseAuth.instance
                            .sendPasswordResetEmail(
                          email: _emailController.text,
                          actionCodeSettings: ActionCodeSettings(
                              url:
                                  'https://personalassetmanager-5aa18.firebaseapp.com/reset',
                              handleCodeInApp: true,
                              androidPackageName: 'com.example.pam_app',
                              androidInstallApp: true,
                              androidMinimumVersion: '21',
                              iOSBundleId: 'com.example.pamApp'),
                        )
                            .then((value) {
                          customSnackBar(
                              context: context,
                              content: 'Reset email sent to your email');
                          Navigator.pushReplacementNamed(
                              context, SignInWithEmailPasswordScreen.screenId,
                              arguments: {'action': 'signin'});
                        });
                      }
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
