//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/widgets.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  static const screenId = 'profile_screen';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  //UserService firebaseUser = UserService();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.secondaryColor),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 20, horizontal: 50))),
              onPressed: () async {
                loadingDialogBox(context, 'Signing Out');

                Navigator.of(context).pop();
                // await googleSignIn.signOut();

                /*await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      WelcomeScreen.screenId, (route) => false);
                });*/
              },
              child: Text(
                'Sign Out',
              ))
        ],
      ),
    );
  }
}
