import 'package:flutter/material.dart';
import 'package:pam_app/constants/dimensions.dart';

class ListTileWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onClicked;
  const ListTileWidget(
      {required this.text,
      required this.icon,
      required this.onClicked,
      super.key});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          text,
          style: TextStyle(
              fontSize: Dimensions.font16, fontWeight: FontWeight.normal),
        ),
        leading: Icon(icon, size: Dimensions.iconSize24, color: Colors.black),
        onTap: onClicked,
      );
}
