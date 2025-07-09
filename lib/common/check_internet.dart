import 'dart:async';

import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckInternet {
  StreamSubscription<DataConnectionStatus>? listener;
  var InternetStatus = "Unknown";
  var contentmessage = "Unknown";
  late SharedPreferences sharedPreferences;

  void _showDialog(String title, String content, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text(title),
              content: new Text(content),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"))
              ]);
        });
  }

  checkConnection(BuildContext context) async {
    sharedPreferences = await SharedPreferences.getInstance();
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          InternetStatus = "Connected to the Internet";
          contentmessage = "Connected to the Internet";
          sharedPreferences.setString("internet", "YES");
          //_showDialog(InternetStatus, contentmessage, context);
          break;
        case DataConnectionStatus.disconnected:
          InternetStatus = "You are disconnected to the Internet. ";
          contentmessage = "Please check your internet connection";
          sharedPreferences.setString("internet", "NO");
          _showDialog(InternetStatus, contentmessage, context);
          break;
      }
    });
    return await DataConnectionChecker().connectionStatus;
  }
}
