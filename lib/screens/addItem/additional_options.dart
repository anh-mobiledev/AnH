import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../constants/colours.dart';
import '../../forms/additional_options_form.dart';
import '../auth/login_screen.dart';
import '../home_screen.dart';

class AddionalOptionsScreen extends StatefulWidget {
  static const String screenId = 'additionaloptions_screen';
  const AddionalOptionsScreen({super.key});

  @override
  State<AddionalOptionsScreen> createState() => _AddionalOptionsScreenState();
}

class _AddionalOptionsScreenState extends State<AddionalOptionsScreen> {
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
        title: Text(
          'Add Addtional options',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: _body(),
    );
  }
}

_body() {
  return SingleChildScrollView(
    child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      AddionalOptionsForm(),
    ]),
  );
}
