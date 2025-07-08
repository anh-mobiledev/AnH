import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../common/alert.dart';
import '../constants/colours.dart';
import '../constants/validators.dart';
import '../constants/widgets.dart';
import '../controllers/auth_controller.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/location_screen.dart';

class SignInWithUsernamePasswordForm extends StatefulWidget {
  const SignInWithUsernamePasswordForm({super.key});

  @override
  State<SignInWithUsernamePasswordForm> createState() =>
      _SignInWithEmailPasswordFormState();
}

class _SignInWithEmailPasswordFormState
    extends State<SignInWithUsernamePasswordForm> {
  final _formKey = GlobalKey<FormState>();

  bool obsecure = true;

  String deviceName = '', deviceVersion = '', identifier = '';

  late final TextEditingController _usernameController;
  late final TextEditingController _upasswordController;
  late final FocusNode _usernameNode;
  late final FocusNode _upasswordNode;

  var authController = Get.find<AuthController>();
  Dialogs alert = Dialogs();

  @override
  void initState() {
    _usernameController = TextEditingController();
    _upasswordController = TextEditingController();
    _usernameNode = FocusNode();
    _upasswordNode = FocusNode();

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _upasswordController.dispose();
    _usernameNode.dispose();
    _upasswordNode.dispose();

    // TODO: implement dispose
    super.dispose();
  }

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
                return validatePassword(value, _upasswordController.text);
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
                      arguments: {'action': 'signinusername'});
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
              text: 'Sign in',
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
                      Navigator.of(context).pushNamed(HomeScreen.screenId);

                      /* Navigator.pushReplacementNamed(
                          context, LocationScreen.screenId);*/
                    } else {
                      alert.showAlertDialog(context, "", response.message);
                    }
                  });
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
