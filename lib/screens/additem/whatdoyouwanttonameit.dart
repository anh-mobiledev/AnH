import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/forms/whatdoyouwanttonameit_form.dart';

import '../../constants/colours.dart';
import '../auth/login_screen.dart';

class WhatDoYouWantToNameItScreen extends StatefulWidget {
  static const String screenId = 'whatdoyouwanttonameit_screen';

  const WhatDoYouWantToNameItScreen({super.key});

  @override
  State<WhatDoYouWantToNameItScreen> createState() =>
      _WhatDoYouWantToNameItScreenState();
}

class _WhatDoYouWantToNameItScreenState
    extends State<WhatDoYouWantToNameItScreen> {
  bool _isConnected = false;
  late final InternetConnectionCheckerPlus _connectionChecker;

  @override
  void initState() {
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();

    // TODO: implement initState
    super.initState();
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
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          'Add a new item',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WhatDoYouWanttoNameItForm(),
          ],
        ),
      ),
    );
  }
}
