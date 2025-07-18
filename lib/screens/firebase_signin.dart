import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pam_app/common/alert.dart';
import 'package:pam_app/controllers/auth_controller.dart';
import 'package:pam_app/screens/home_screen.dart';

import '../constants/colours.dart';

class FirebaseSignIn extends StatefulWidget {
  static const String screenId = 'firebase_signin';
  const FirebaseSignIn({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FirebaseSignIn();
  }
}

class _FirebaseSignIn extends State<FirebaseSignIn> {
  final storage = FlutterSecureStorage();
  var authController = Get.find<AuthController>();
  Dialogs alert = Dialogs();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseTokenVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Authentication progress....',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
    );
  }

  firebaseTokenVerification() async {
    alert.showLoaderDialog(context);

    String? firebaseIdToken = await storage.read(key: 'firebase_token');
    String? firebaseUid = await storage.read(key: 'firebase_Uid');

    authController
        .verifyFirebaseIdTokenController(firebaseIdToken!, firebaseUid!)
        .then((result) {
      Navigator.pop(context);
      if (result.isSuccess) {
        Navigator.pushReplacementNamed(context, HomeScreen.screenId);
      } else {
        alert.showAlertDialog(
            context, "Verifying Firebase Token", result.message);
      }
    });
  }
}
