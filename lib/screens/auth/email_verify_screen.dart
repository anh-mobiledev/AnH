import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:open_mail_app/open_mail_app.dart';

import 'package:pam_app/components/custom_icon_button.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/screens/home_screen.dart';
import 'package:pam_app/screens/location_screen.dart';

import '../../services/auth.dart';

class EmailVerifyScreen extends StatefulWidget {
  static const String screenId = 'email_otp_screen';
  const EmailVerifyScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  bool isPinEntered = false;
  String smsCode = "";

  Auth authService = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _body(context),
    );
  }

  Future<void> validateEmailOtp() async {
    if (kDebugMode) {
      print('sms code is : $smsCode');
    }
  }

  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.only(top: 100, left: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify Email',
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Check your email to verify your regsitered email',
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Lottie.asset(
                'assets/lottie/verify_lottie.json',
                width: double.infinity,
                height: 350,
              ),
            ),
            InkWell(
              onTap: () async {
                var result = await OpenMailApp.openMailApp();
                if (!result.didOpen && !result.canOpen) {
                  customSnackBar(
                      context: context, content: 'No mail apps installed');
                } else if (!result.didOpen && result.canOpen) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return MailAppPickerDialog(
                        mailApps: result.options,
                      );
                    },
                  );

                  // Get.to(LocationScreen.screenId);
                  Navigator.pushReplacementNamed(context, HomeScreen.screenId);
                }
              },
              child: CustomIconButton(
                  text: 'Verify Email',
                  bgColor: AppColors.secondaryColor,
                  icon: Icons.verified_user,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15)),
            )
          ]),
        ),
      ],
    );
  }
}
