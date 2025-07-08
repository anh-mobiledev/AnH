import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/models/my_items_server_model.dart';
import 'package:pam_app/screens/addItem/items_list.dart';

import '../../constants/colours.dart';
import '../../forms/item_details_view_form.dart';
import '../auth/login_screen.dart';

String? a;

class ItemDetailsViewScreen extends StatefulWidget {
  static const String screenId = 'itemdetailsview_screen';

  @override
  State<ItemDetailsViewScreen> createState() => _ItemDetailsViewScreenState();
}

class _ItemDetailsViewScreenState extends State<ItemDetailsViewScreen> {
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
    /* final arguments =
        ModalRoute.of(context)?.settings.arguments as ItemInfoSQLLite;*/

    final arguments =
        ModalRoute.of(context)?.settings.arguments as MyItemsServerModel;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.secondaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            /*if (arguments.fromScreen == 'childcollectionlist') {
            } else {
              Navigator.of(context).pushNamed(ItemsListScreen.screenId);
            }*/
          },
        ),
        title: Text(
          'Item details',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: _body(arguments),
    );
  }

  _body(MyItemsServerModel arguments) {
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ItemDetailsViewForm(arguments)]));
  }
}
