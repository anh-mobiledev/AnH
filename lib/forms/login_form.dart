import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pam_app/common/check_internet.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/screens/auth/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/alert.dart';
import '../components/login_buttons.dart';
import '../controllers/auth_controller.dart';
import '../services/auth.dart';

enum SingingWith {
  emailANDpassword,
  usernameANDpassword,
  google,
  facebook,
  phone
}

class LogInForm extends StatefulWidget {
  const LogInForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  Auth authService = Auth();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailNode;
  late final FocusNode _passwordNode;

  late final TextEditingController _usernameController;
  late final TextEditingController _upasswordController;
  late final FocusNode _usernameNode;
  late final FocusNode _upasswordNode;

  final _formKey = GlobalKey<FormState>();
  bool obsecure = true;
  String deviceName = '', deviceVersion = '', identifier = '';
  late SharedPreferences sharedPreferences;
  SingingWith? signingWith;
  bool _singingWithEmail = false;
  bool _singingWithUsername = false;

  var authController = Get.find<AuthController>();
  Dialogs alert = Dialogs();

  Future<void> _deviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceName = build.model!;

          deviceVersion = build.version.toString();
          identifier = build.androidId!;
          print(identifier);
        });
        //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = data.name!;
          deviceVersion = data.systemVersion!;
          identifier = data.identifierForVendor!;
        }); //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailNode = FocusNode();
    _passwordNode = FocusNode();

    _usernameController = TextEditingController();
    _upasswordController = TextEditingController();
    _usernameNode = FocusNode();
    _upasswordNode = FocusNode();

    CheckInternet().checkConnection(context);
    _deviceDetails();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();

    _usernameController.dispose();
    _upasswordController.dispose();
    _usernameNode.dispose();
    _upasswordNode.dispose();
    CheckInternet().listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /* Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Singing with email and password'),
                  leading: Radio<SingingWith>(
                    value: SingingWith.emailANDpassword,
                    groupValue: signingWith,
                    onChanged: (SingingWith? value) {
                      setState(() {
                        signingWith = value;

                        _singingWithEmail = true;
                        _singingWithUsername = false;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Singing with username and password'),
                  leading: Radio<SingingWith>(
                    value: SingingWith.usernameANDpassword,
                    groupValue: signingWith,
                    onChanged: (SingingWith? value) {
                      setState(() {
                        signingWith = value;
                        _singingWithEmail = false;
                        _singingWithUsername = true;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Singing with phone number'),
                  leading: Radio<SingingWith>(
                    value: SingingWith.phone,
                    groupValue: signingWith,
                    onChanged: (SingingWith? value) {
                      setState(() {
                        signingWith = value;
                        _singingWithEmail = false;
                        _singingWithUsername = false;
                      });

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const PhoneAuthScreen()));
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Singing with google'),
                  leading: Radio<SingingWith>(
                    value: SingingWith.google,
                    groupValue: signingWith,
                    onChanged: (SingingWith? value) async {
                      setState(() {
                        signingWith = value;
                        _singingWithEmail = false;
                        _singingWithUsername = false;
                      });

                      sharedPreferences = await SharedPreferences.getInstance();
                      await sharedPreferences.setString(
                          AppConstants.DEVICE_ID, identifier);
                      User? user =
                          await Auth.signInWithGoogle(context: context);
                      if (user != null) {
                        authService.getAdminCredentialPhoneNumber(
                            context, user);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Singing with facebook'),
                  leading: Radio<SingingWith>(
                    value: SingingWith.facebook,
                    groupValue: signingWith,
                    onChanged: (SingingWith? value) async {
                      setState(() {
                        signingWith = value;
                        _singingWithEmail = false;
                        _singingWithUsername = false;
                      });

                      sharedPreferences = await SharedPreferences.getInstance();
                      await sharedPreferences.setString(
                          AppConstants.DEVICE_ID, identifier);
                      authService.signInWithFacebook(context: context);
                    },
                  ),
                ),
                if (signingWith == SingingWith.emailANDpassword)
                  Visibility(
                    visible: _singingWithEmail,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          focusNode: _emailNode,
                          controller: _emailController,
                          validator: (value) {
                            return validateEmail(value,
                                EmailValidator.validate(_emailController.text));
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
                            return validatePassword(
                                value, _passwordController.text);
                          },
                          obscureText: obsecure,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: obsecure ? AppColors.greyColor : AppColors.blackColor,
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
                              Navigator.pushNamed(
                                  context, ResetPasswordScreen.screenId);
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
                          text: 'Sign In',
                          textColor: AppColors.whiteColor,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              sharedPreferences =
                                  await SharedPreferences.getInstance();
                              await sharedPreferences.setString(
                                  AppConstants.DEVICE_ID, identifier);

                              await authService
                                  .getAdminCredentialEmailAndPassword(
                                      context: context,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      isLoginUser: true);
                            }
                          },
                          child: Text(""),
                        ),
                      ],
                    ),
                  )
                else if (signingWith == SingingWith.usernameANDpassword)
                  Visibility(
                    visible: _singingWithUsername,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          focusNode: _usernameNode,
                          controller: _usernameController,
                          validator: (value) {
                            return checkNullEmptyValidation(
                                value, _usernameController.text);
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your username',
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
                          focusNode: _upasswordNode,
                          controller: _upasswordController,
                          validator: (value) {
                            return validatePassword(
                                value, _upasswordController.text);
                          },
                          obscureText: obsecure,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: obsecure ? AppColors.greyColor : AppColors.blackColor,
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
                              Navigator.pushNamed(
                                  context, ResetPasswordScreen.screenId);
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
                          text: 'Sign In',
                          textColor: AppColors.whiteColor,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              alert.showLoaderDialog(context);

                              authController
                                  .login(_usernameController.text.trim(),
                                      _upasswordController.text.trim(), "")
                                  .then((response) {
                                Navigator.pop(context);
                                if (response.isSuccess) {
                                  Navigator.pushReplacementNamed(
                                      context, LocationScreen.screenId);
                                } else {
                                  alert.showAlertDialog(
                                      context, "", response.message);
                                }
                              });
                            }
                          },
                          child: Text(""),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),*/
        const SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(
            text: 'Don\'t have an account? ',
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, RegisterScreen.screenId);
                  },
                text: 'Create new account',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 14,
                  color: AppColors.secondaryColor,
                ),
              )
            ],
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 14,
              color: AppColors.greyColor,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          'Or',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.greyColor,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        LoginInButtons(),
      ],
    );
  }
}
