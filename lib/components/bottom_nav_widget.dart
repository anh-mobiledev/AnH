import 'package:flutter/material.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';

import '../constants/colours.dart';

class BottomNavigationWidget extends StatelessWidget {
  final bool validator;
  final Function()? onPressed;
  final String buttonText;
  final ProgressDialog? progressDialog;
  const BottomNavigationWidget({
    Key? key,
    required this.validator,
    this.onPressed,
    required this.buttonText,
    this.progressDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.whiteColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: AbsorbPointer(
            absorbing: !validator,
            child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: AppThemeColor))),
                  backgroundColor: validator
                      ? MaterialStateProperty.all(AppColors.secondaryColor)
                      : MaterialStateProperty.all(AppColors.disabledColor)),
              onPressed: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: path1Color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
