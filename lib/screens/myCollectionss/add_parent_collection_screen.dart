import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/forms/myCollections/add_collection_form.dart';
import 'package:pam_app/screens/myCollections/parent_collections_list_screen.dart';

import '../../constants/colours.dart';
import '../auth/login_screen.dart';

class AddParentCollectionScreen extends StatefulWidget {
  static const String screenId = 'addcollection_screen';

  const AddParentCollectionScreen({super.key});

  @override
  State<AddParentCollectionScreen> createState() =>
      _AddParentCollectionScreenState();
}

class _AddParentCollectionScreenState extends State<AddParentCollectionScreen> {
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
          'Add collection',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context)
                .pushNamed(ParentCollectionsListScreen.screenId);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AddCollectionForm(),
          ],
        ),
      ),
    );
  }
}
