// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:pam_app/common/check_internet.dart';
import 'package:pam_app/screens/welcome_screen.dart';

import '../constants/colours.dart';

//import on board me dependency

class IntroScreen extends StatefulWidget {
  static const String screenId = 'intro_screen';
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IntroScreen();
  }
}

class _IntroScreen extends State<IntroScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CheckInternet().checkConnection(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    CheckInternet().listener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //this is a page decoration for intro screen
    PageDecoration pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: Colors.white), //tile font size, weight and color
      bodyTextStyle: TextStyle(fontSize: 19.0, color: Colors.white),
      //body text size and color
      // descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      //decription padding
      imagePadding: EdgeInsets.all(20), //image padding
      boxDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 0.5, 0.7, 0.9],
          colors: [
            Color(0xFF588adb),
            Color(0xFF2A7DFC),
            Color(0xFF2B7CFE),
            Color(0xFF2d6dcc),
          ],
        ),
      ), //show linear gradient background of page
    );

    return IntroductionScreen(
      globalBackgroundColor: Colors.deepOrangeAccent,
      //main background of screen
      pages: [
        //set your page view here
        PageViewModel(
          title: "Assets and Heirlooms",
          body:
              "Inspired from recognizing all the things my parents have that I don't know much about, welcome to an app that is designed to make it fun and easy to learn and share the Story of Your Stuff.",
          image: introImage('assets/images/intro1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Assets and Heirlooms",
          body:
              "Take pictures, describe the item if the details matter or tell a story about it, assume ownership, say who should get it, assign a cost paid, current value, location of item, quantity, etc",
          image: introImage('assets/images/intro2.png'),
          decoration: pageDecoration,
        ),
        /* PageViewModel(
          title: "Assets and Heirlooms",
          body: "All types of Social login",
          image: introImage('assets/images/intro3.jpg'),
          decoration: pageDecoration,
        ),*/

        //add more screen here
      ],

      onDone: () => goHomepage(context), //go to home page on done
      onSkip: () => goHomepage(context), // You can override on skip
      showSkipButton: true,
      //    skipFlex: 0,
      nextFlex: 0,

      skip: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, WelcomeScreen.screenId);
        },
        style: TextButton.styleFrom(
            foregroundColor: AppColors.whiteColor,
            backgroundColor: AppColors.skipbtncolor,
            textStyle:
                const TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
        child: const Text(
          'Skip',
        ),
      ),

      next: Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      done: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, WelcomeScreen.screenId);
        },
        style: TextButton.styleFrom(
            foregroundColor: AppColors.whiteColor,
            backgroundColor: AppColors.skipbtncolor,
            textStyle:
                const TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
        child: const Text(
          'Get Started',
        ),
      ),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0), //size of dots
        color: Colors.white, //color of dots
        activeSize: Size(22.0, 10.0),
        //activeColor: Colors.white, //color of active dot
        activeShape: RoundedRectangleBorder(
          //shave of active dot
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  void goHomepage(context) {
    Navigator.pushReplacementNamed(context, WelcomeScreen.screenId);
  }

  Widget introImage(String assetName) {
    //widget to show intro image
    return Align(
      child: Image.asset('$assetName', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }
}
