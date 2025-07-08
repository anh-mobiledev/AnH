import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/screens/auth/login_screen.dart';

import '../../constants/colours.dart';
import '../../forms/add_details_form.dart';

class AddDetailsScreen extends StatefulWidget {
  static const String screenId = 'adddetails-screen';
  const AddDetailsScreen({super.key});

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
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
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          'Add an item details',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: _body(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: AddDetailsForm(),
    );
  }
}
