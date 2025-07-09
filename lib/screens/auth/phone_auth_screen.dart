import 'package:pam_app/components/bottom_nav_widget.dart';
import 'package:pam_app/constants/colours.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';

import '../../services/auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  static const String screenId = 'phone_auth_screen';
  final bool isFromLogin;
  const PhoneAuthScreen({
    Key? key,
    this.isFromLogin = true,
  }) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  Auth authService = Auth();
  late final TextEditingController _countryCodeController;
  late final TextEditingController _phoneNumberController;
  late final FocusNode _countryCodeNode;
  late final FocusNode _phoneNumberNode;
  String counterText = '0';
  bool validate = false;
  bool isLoading = true;
  String verificationIdFinal = "";
  @override
  void initState() {
    _countryCodeController = TextEditingController(text: '+91');
    _phoneNumberController = TextEditingController();
    _countryCodeNode = FocusNode();
    _phoneNumberNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneNumberController.dispose();
    _countryCodeNode.dispose();
    _phoneNumberNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
    ProgressDialog progressDialog = ProgressDialog(
      context: context,
      backgroundColor: AppColors.whiteColor,
      textColor: AppColors.blackColor,
      loadingText: 'Verifying details',
      progressIndicatorColor: AppColors.blackColor,
    );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.whiteColor,
            iconTheme: IconThemeData(color: AppColors.blackColor),
            title: Text(
              widget.isFromLogin ? 'Login' : 'Signup',
              style: TextStyle(color: AppColors.blackColor),
            )),
        body: _body(context),
        bottomNavigationBar: BottomNavigationWidget(
          validator: validate,
          buttonText: 'Next',
          progressDialog: progressDialog,
          onPressed: signInValidate,
        ),
      ),
    );
  }

  void signInValidate() {
    String number =
        '${_countryCodeController.text}${_phoneNumberController.text}';

    if (kDebugMode) {
      print(number);
    }
    authService.verifyPhoneNumber(context, number);
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 40,
          ),
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: 40,
            child: CircleAvatar(
              backgroundColor: AppColors.secondaryColor,
              radius: 37,
              child: Icon(
                CupertinoIcons.person,
                color: AppColors.whiteColor,
                size: 40,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'Enter your Phone Number',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'We will send a confirmation code to the phone number you provide.',
            style: TextStyle(
              color: AppColors.greyColor,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TextFormField(
                    focusNode: _countryCodeNode,
                    textAlign: TextAlign.center,
                    controller: _countryCodeController,
                    decoration: InputDecoration(
                        labelText: 'Country',
                        enabled: false,
                        contentPadding: const EdgeInsets.all(20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: TextFormField(
                      focusNode: _phoneNumberNode,
                      maxLength: 10,
                      onChanged: (value) {
                        setState(() {
                          counterText = value.length.toString();
                        });
                        if (value.length == 10) {
                          setState(() {
                            validate = true;
                          });
                        }
                        if (value.length < 10) {
                          setState(() {
                            validate = false;
                          });
                        }
                      },
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          counterText: '$counterText/10',
                          counterStyle: const TextStyle(fontSize: 10),
                          labelText: 'Phone Number',
                          hintText: 'Enter Your Phone Number',
                          hintStyle: TextStyle(
                            color: AppColors.greyColor,
                            fontSize: 12,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
