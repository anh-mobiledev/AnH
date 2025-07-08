import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/forms/add_item_image_form.dart';
import 'package:pam_app/screens/auth/login_screen.dart';
import 'package:pam_app/screens/home_screen.dart';

import '../../constants/colours.dart';

class AddItemImageScreen extends StatefulWidget {
  static const screenId = 'add_item_screen';

  const AddItemImageScreen({super.key});

  @override
  State<AddItemImageScreen> createState() => _AddItemImageScreenState();
}

class _AddItemImageScreenState extends State<AddItemImageScreen> {
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
          'Add item',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(HomeScreen.screenId);
          },
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [AddItemImageForm()]));
  }
}
