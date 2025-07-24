import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pam_app/components/custom_icon_button.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/screens/auth/phone_auth_screen.dart';
import 'package:pam_app/screens/auth/sign_in_with_email_password_screen.dart';

import '../services/auth.dart';

class SignUpButtons extends StatefulWidget {
  const SignUpButtons({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpButtons> createState() => _SignUpButtonsState();
}

class _SignUpButtonsState extends State<SignUpButtons> {
  Auth authService = Auth();
  final storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => const PhoneAuthScreen(
                    isFromLogin: false,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(260, 60),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
            ),
            icon: FaIcon(FontAwesomeIcons.phone, color: Colors.green),
            label: Text('Signup with Phone',
                style: TextStyle(color: Colors.black87)),
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton.icon(
            onPressed: () async {
              User? user = await Auth.signInWithGoogle(context: context);

              if (user != null) {
                final firebaseIdToken = await user.getIdToken();
                final firebaseUid = await user.uid;

                await storage.write(
                    key: 'firebase_token', value: firebaseIdToken!);
                await storage.write(
                    key: 'firebase_user_id', value: firebaseUid);

                authService.getAdminCredentialPhoneNumber(context, user);
              }
              /*Navigator.of(context).pushNamed(
                  SignInWithEmailPasswordScreen.screenId,
                  arguments: {'action': 'signup'});*/
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(260, 60),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
            ),
            icon: FaIcon(FontAwesomeIcons.google, color: Color(0xFFDB4437)),
            label: Text('Signup with Google',
                style: TextStyle(color: Colors.black87)),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
