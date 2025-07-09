import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pam_app/common/alert.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/screens/auth/phone_auth_screen.dart';
import 'package:pam_app/screens/auth/sign_in_with_username_password_screen.dart';
import 'package:pam_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_contants.dart';
import '../constants/widgets.dart';
import '../screens/auth/sign_in_with_email_password_screen.dart';
import '../screens/usecase_screen.dart';
import '../services/auth.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginInButtons extends StatefulWidget {
  const LoginInButtons({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginInButtons> createState() => _LoginInButtonsState();
}

enum SupportState {
  unknown,
  Supported,
  unSupported,
}

class _LoginInButtonsState extends State<LoginInButtons> {
  Auth authService = Auth();
  final storage = const FlutterSecureStorage();

  String deviceName = '', deviceVersion = '', identifier = '';
  late SharedPreferences sharedPreferences;

  final LocalAuthentication auth = new LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;
  Dialogs alert = Dialogs();

  Future<void> checkBiometric() async {
    late bool canCheckbiometric;
    try {
      canCheckbiometric = await auth.canCheckBiometrics;
      print("Biometric supported: $canCheckbiometric");
    } on PlatformException catch (e) {
      print(e);
      canCheckbiometric = false;
    }
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> biometricTypes;
    try {
      biometricTypes = await auth.getAvailableBiometrics();
      print("supported biometries: $biometricTypes");
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      availableBiometrics = biometricTypes;
    });
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
          localizedReason: 'Authenticate with Fingerprint or Face ID',
          options: AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ));

      if (!mounted) {
        return;
      }

      if (authenticated) {
        Navigator.pushNamed(context, HomeScreen.screenId);
      }
    } on PlatformException catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OutlinedButton.icon(
              onPressed: () async {
                authenticateWithBiometrics();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(260, 60),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon: FaIcon(FontAwesomeIcons.fingerprint,
                  color: Color(0xFF1877F2)),
              label: Text('Sign in with Biomatric',
                  style: TextStyle(color: Colors.black87)),
            ),
          ),
          const SizedBox(
            height: 15,
          ),*/
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(context)
                    .pushNamed(SignInWithUsernamePasswordScreen.screenId);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(260, 60),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon: FaIcon(FontAwesomeIcons.user, color: Color(0xFF1877F2)),
              label: Text('Sign in with username/password',
                  style: TextStyle(color: Colors.black87)),
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(context)
                    .pushNamed(SignInWithUsernamePasswordScreen.screenId);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(260, 60),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon: FaIcon(FontAwesomeIcons.user, color: Color(0xFF1877F2)),
              label: Text('Sign in with Username/Password',
                  style: TextStyle(color: Colors.black87)),
            ),
          ),*/
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(context).pushNamed(
                    SignInWithEmailPasswordScreen.screenId,
                    arguments: {'action': 'signin'});
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(260, 60),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon:
                  FaIcon(FontAwesomeIcons.mailchimp, color: Color(0xFF1877F2)),
              label: Text('Sign in with Email',
                  style: TextStyle(color: Colors.black87)),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(context).pushNamed(PhoneAuthScreen.screenId);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(260, 60),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon: FaIcon(FontAwesomeIcons.phone, color: Colors.green),
              label: Text('Sign in with Phone',
                  style: TextStyle(color: Colors.black87)),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OutlinedButton.icon(
              onPressed: () async {
                /*sharedPreferences = await SharedPreferences.getInstance();
                await sharedPreferences.setString(
                    AppConstants.DEVICE_ID, identifier);*/

                final deviceId =
                    await storage.write(key: 'deviceId', value: identifier);

                User? user = await Auth.signInWithGoogle(context: context);

                String? firebaseToken = await user?.getIdToken();
                print('firebaseToken:: ${firebaseToken}');

                if (user != null) {
                  authService.getAdminCredentialPhoneNumber(context, user);
                } else {
                  alert.showAlertDialog(
                      context, "Google", "Google signin cancelled by user");
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(260, 60),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon: FaIcon(FontAwesomeIcons.google, color: Color(0xFFDB4437)),
              label: Text('Sign in with Google',
                  style: TextStyle(color: Colors.black87)),
            ),
          ),
          /* SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OutlinedButton.icon(
              onPressed: () async {
                /*sharedPreferences = await SharedPreferences.getInstance();
                await sharedPreferences.setString(
                    AppConstants.DEVICE_ID, identifier);*/

                final deviceId =
                    await storage.write(key: 'deviceId', value: identifier);

                await authService.signInWithFacebook(context: context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(260, 60),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
              ),
              icon: FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2)),
              label: Text('Sign in with Facebook',
                  style: TextStyle(color: Colors.black87)),
            ),
          ),*/
        ],
      ),
    );
  }
}
