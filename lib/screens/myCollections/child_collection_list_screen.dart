import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/screens/myCollections/parent_collections_list_screen.dart';

import '../../constants/colours.dart';
import '../../forms/myCollections/child_collections_list_form.dart';
import '../auth/login_screen.dart';

class ChildCollectionsListScreen extends StatefulWidget {
  static const String screenId = 'childcollectionlist_screen';
  const ChildCollectionsListScreen({super.key});

  @override
  State<ChildCollectionsListScreen> createState() =>
      _ChildCollectionsListScreenState();
}

class _ChildCollectionsListScreenState
    extends State<ChildCollectionsListScreen> {
  bool _isConnected = false;
  var title;
  String? collectionId;

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
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    setState(() {
      title = arguments['name'];
      collectionId = arguments['collectionId'];
    });
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.secondaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context)
                .pushNamed(ParentCollectionsListScreen.screenId);
          },
        ),
        title: Text(
          title ?? "Assets and Heirlooms",
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: _body(),
    );
  }

  _body() {
    return Stack(
      children: [
        ChildCollectionsListForm(
          title,
          collectionId!,
        )
      ],
    );
  }
}
