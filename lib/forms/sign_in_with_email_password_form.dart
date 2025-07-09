import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_contants.dart';
import '../constants/colours.dart';
import '../constants/validators.dart';
import '../constants/widgets.dart';
import '../screens/auth/reset_password_screen.dart';
import '../services/auth.dart';

class SignInWithEmailPasswordForm extends StatefulWidget {
  final String action;
  const SignInWithEmailPasswordForm({required this.action, super.key});

  @override
  State<SignInWithEmailPasswordForm> createState() =>
      _SignInWithEmailPasswordFormState();
}

class _SignInWithEmailPasswordFormState
    extends State<SignInWithEmailPasswordForm> {
  Auth authService = Auth();
  final storage = const FlutterSecureStorage();

  String deviceName = '', deviceVersion = '', identifier = '';

  late final TextEditingController _emailController;
  late final FocusNode _emailNode;

  late final TextEditingController _passwordController;
  late final FocusNode _passwordNode;

  final _formKey = GlobalKey<FormState>();
  bool obsecure = true;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    _emailController = TextEditingController();
    _emailNode = FocusNode();

    _passwordController = TextEditingController();
    _passwordNode = FocusNode();

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailNode.dispose();

    _passwordController.dispose();
    _passwordNode.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  hintText: 'Enter your Email',
                  hintStyle: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              focusNode: _passwordNode,
              controller: _passwordController,
              validator: (value) {
                return validatePassword(value, _passwordController.text);
              },
              obscureText: obsecure,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye_outlined,
                        color: obsecure
                            ? AppColors.greyColor
                            : AppColors.blackColor,
                      ),
                      onPressed: () {
                        setState(() {
                          obsecure = !obsecure;
                        });
                      }),
                  labelText: 'Password',
                  hintText: 'Enter Your Password',
                  hintStyle: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(
                top: 10,
                right: 5,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, ResetPasswordScreen.screenId,
                      arguments: {'action': 'signinemail'});
                },
                child: Text(
                  'Forgot Password ?',
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            roundedButton(
              context: context,
              bgColor: AppColors.secondaryColor,
              text: widget.action == 'signin' ? 'Sign in' : 'Sign up',
              textColor: AppColors.whiteColor,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final deviceId =
                      await storage.write(key: 'deviceId', value: identifier);

                  /*sharedPreferences = await SharedPreferences.getInstance();
                  await sharedPreferences.setString(
                      identifier);*/

                  await authService.getAdminCredentialEmailAndPassword(
                      context: context,
                      email: _emailController.text,
                      password: _passwordController.text,
                      isLoginUser: widget.action == 'signin' ? true : false);
                }
              },
              child: Text(""),
            ),
          ],
        ),
      ),
    );
  }
}
