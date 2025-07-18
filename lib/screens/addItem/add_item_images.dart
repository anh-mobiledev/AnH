import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/forms/add_item_images_form.dart';
import 'package:pam_app/forms/media_picker_form.dart';

import '../../constants/colours.dart';
import '../auth/login_screen.dart';
import '../home_screen.dart';

class AddItemImagesScreen extends StatefulWidget {
  static const screenId = 'additem_screen';

  const AddItemImagesScreen({super.key});

  @override
  State<AddItemImagesScreen> createState() => _AddItemImagesScreenState();
}

class _AddItemImagesScreenState extends State<AddItemImagesScreen> {
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
          'Add a New Item',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 50,
      ),
      MediaPickerForm()
      //AddItemImagesForm()
    ]));
  }
}
