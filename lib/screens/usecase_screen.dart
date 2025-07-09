import 'dart:io';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/forms/use_case_form.dart';
import 'package:pam_app/screens/auth/login_screen.dart';
import 'package:pam_app/screens/home_screen.dart';

import '../constants/colours.dart';

class UsecaseScreen extends StatefulWidget {
  static const screenId = 'usecase_screen';

  const UsecaseScreen({Key? key}) : super(key: key);

  @override
  State<UsecaseScreen> createState() => _UsecaseScreenState();
}

class _UsecaseScreenState extends State<UsecaseScreen> {
  bool _isConnected = false;
  late final InternetConnectionCheckerPlus _connectionChecker;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.secondaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(HomeScreen.screenId);
          },
        ),
        actions: [
          _isConnected
              ? IconButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, LoginScreen.screenId);
                    //logout
                  },
                  icon: const Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    exit(0);
                  },
                  icon: const Icon(
                    Icons.exit_to_app_outlined,
                    color: Colors.white,
                  ),
                )
        ],
        title: Text(
          'Use cases',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: _body(),
    );
  }

  _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [Expanded(child: const UseCaseForm())],
    );
  }
}
