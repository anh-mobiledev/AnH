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
