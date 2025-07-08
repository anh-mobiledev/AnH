import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/screens/auth/login_screen.dart';
import 'package:pam_app/screens/auth/register_screen.dart';

import '../constants/dimensions.dart';

class WelcomeScreen extends StatefulWidget {
  static const screenId = 'welcome_screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

enum SupportState {
  unknown,
  Supported,
  unSupported,
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final LocalAuthentication auth = new LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;

  @override
  void initState() {
    auth.isDeviceSupported().then((bool isSupported) => setState(() =>
        supportState =
            isSupported ? SupportState.Supported : SupportState.unSupported));
    super.initState();
    checkBiometric();
    getAvailableBiometrics();
  }

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
        Navigator.pushNamed(context, LoginScreen.screenId);
      }
    } on PlatformException catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: welcomeBodyWidget(context),
    );
  }

  Widget welcomeBodyWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assets and Heirlooms',
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: Dimensions.font26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lets get started!',
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: Dimensions.font26,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Lottie.asset(
                'assets/lottie/welcome_lottie.json',
                width: double.infinity,
                height: Dimensions.welcomescreenlottieheight,
              ),
            )
          ]),
        ),
        _bottomNavigationBar(context),
      ],
    );
  }

  Widget _bottomNavigationBar(context) {
    return Column(
      children: [
        /* Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor: AppColors.whiteColor,
              borderColor: AppColors.blackColor,
              textColor: AppColors.blackColor,
              text: 'Login with Biometric / Face ID',
              onPressed: () {
                authenticateWithBiometrics();
              }),
        ),
        const SizedBox(
          height: 10,
        ),*/
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor: AppColors.whiteColor,
              borderColor: AppColors.blackColor,
              textColor: AppColors.blackColor,
              text: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.screenId);
              }),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor: AppColors.secondaryColor,
              text: 'Sign Up',
              textColor: AppColors.whiteColor,
              onPressed: () {
                Navigator.pushNamed(context, RegisterScreen.screenId);
              }),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
