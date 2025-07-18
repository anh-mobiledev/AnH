import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/screens/home_screen.dart';
import 'package:pam_app/screens/welcome_screen.dart';

import '../services/auth.dart';
import 'intro_screen.dart';
import 'usecase_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String screenId = 'splash_screen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Auth authService = Auth();

  bool _isConnected = false;
  late final InternetConnectionCheckerPlus _connectionChecker;

  int _activeDot = 0;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();

    permissionBasedNavigationFunc(context);

    super.initState();

/*
    // Cycle through dots every 500ms
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _activeDot = (_activeDot + 1) % 3;
      });
    });

    // Simulate splash delay
    Future.delayed(Duration(seconds: 3), () {
      _timer.cancel();
      // Navigate to next screen here
      if (_isConnected) {
        Navigator.pushReplacementNamed(context, IntroScreen.screenId);
      } else {
        Navigator.pushReplacementNamed(context, UsecaseScreen.screenId);
      }
    });*/
  }

  /* permissionBasedNavigationFunc() {
  
    Timer(const Duration(seconds: 4), () async {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user == null) {
          Navigator.pushReplacementNamed(context, WelcomeScreen.screenId);
        } else {
          Navigator.pushReplacementNamed(context, HomeScreen.screenId);
        }
      });
    });
  }*/

  void permissionBasedNavigationFunc(BuildContext context) {
    Timer(const Duration(seconds: 4), () async {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // Logged in with Firebase
        Navigator.pushReplacementNamed(context, HomeScreen.screenId);
      } else {
        // Check for native login token
        final token = await storage.read(key: 'app_token');

        if (token != null && token.isNotEmpty) {
          // Logged in with native
          Navigator.pushReplacementNamed(context, HomeScreen.screenId);
        } else {
          // Not logged in
          Navigator.pushReplacementNamed(context, WelcomeScreen.screenId);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final isConnected = await _connectionChecker.hasConnection;
    setState(() {
      _isConnected = isConnected;
    });
  }

  void _startMonitoring() {
    _connectionChecker.onStatusChange.listen((status) {
      setState(() {
        _isConnected = status == InternetConnectionStatus.connected;
      });
    });
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _activeDot == index
            ? AppColors.secondaryColor
            : AppColors.whiteColor,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: Dimensions.screenWidth,
            height: Dimensions.screenHeight,
            child: Column(
              children: [
                Container(
                  width: Dimensions.screenWidth,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: Dimensions.height45),
                  child: Text(
                    'Assets and Heirlooms',
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.font26),
                  ),
                ),
                Container(
                  width: Dimensions.screenWidth,
                  alignment: Alignment.center,
                  child: Text(
                    'The story of your stuff',
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.font20),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.whiteColor, shape: BoxShape.circle),
                  margin: EdgeInsets.all(10),
                  width: Dimensions.screenWidth,
                  height: 200,
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    "assets/lottie/splash_lottie.json",
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  width: Dimensions.screenWidth,
                  height: 350,
                  alignment: Alignment.center,
                  child: Text(
                    'Use if for:\n\n Personal Inventory, \n Identifying Heirlooms, \n Yard Sales, \n Online Sales, \n Consignment, \n Estate Planning, \n Insurance, \n ...and many more!',
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: Dimensions.font16),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, buildDot),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
