import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../constants/colours.dart';
import '../../forms/myCollections/add_child_collection_form.dart';
import '../auth/login_screen.dart';
import 'child_collection_list_screen.dart';

class AddChildCollectionScreen extends StatefulWidget {
  static const String screenId = 'addchildcollection_screen';

  const AddChildCollectionScreen({super.key});

  @override
  State<AddChildCollectionScreen> createState() =>
      _AddChildCollectionScreenState();
}

class _AddChildCollectionScreenState extends State<AddChildCollectionScreen> {
  bool _isConnected = false;
  String? collectionId;
  String? title;
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
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    setState(() {
      collectionId = arguments['collectionId'];
      title = arguments['title'];
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.secondaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(ChildCollectionsListScreen.screenId,
                arguments: {'collectionId': collectionId, 'name': title});
          },
        ),
        title: Text(
          title! ?? "Add collection",
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AddChildCollectionForm(),
          ],
        ),
      ),
    );
  }
}
