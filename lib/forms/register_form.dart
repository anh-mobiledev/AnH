import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pam_app/common/alert.dart';
import 'package:pam_app/components/signup_buttons.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/constants/validators.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/models/new_account_body.dart';
import 'package:pam_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';
import '../screens/home_screen.dart';
import '../screens/location_screen.dart';
import '../services/auth.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool obsecure = true;
  Auth authService = Auth();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final FocusNode _firstNameNode;
  late final FocusNode _lastNameNode;
  late final FocusNode _userNameNode;
  late final FocusNode _emailNode;
  late final FocusNode _passwordNode;
  late final FocusNode _confirmPasswordNode;
  final _formKey = GlobalKey<FormState>();
  Dialogs alert = Dialogs();

  var authController = Get.find<AuthController>();
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _userNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _firstNameNode = FocusNode();
    _lastNameNode = FocusNode();
    _userNameNode = FocusNode();
    _emailNode = FocusNode();
    _passwordNode = FocusNode();
    _confirmPasswordNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameNode.dispose();
    _lastNameNode.dispose();
    _userNameNode.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    super.dispose();
  }

/* -- NEW ACCOUNT JSON RESPONSE */
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/new_account_response.json');
    final data = await json.decode(response);
    print(data['data']['username']);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - Dimensions.height120,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: _firstNameNode,
                          validator: (value) {
                            return checkNullEmptyValidation(
                                value, 'first name');
                          },
                          controller: _firstNameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              labelText: 'First Name',
                              labelStyle: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 14,
                              ),
                              hintText: 'Enter your First Name',
                              hintStyle: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          focusNode: _lastNameNode,
                          validator: (value) {
                            return checkNullEmptyValidation(value, 'last name');
                          },
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 14,
                              ),
                              hintText: 'Enter your Last Name',
                              hintStyle: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    focusNode: _emailNode,
                    controller: _emailController,
                    validator: (value) {
                      return validateEmail(value,
                          EmailValidator.validate(_emailController.text));
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                        hintText: 'Enter your Email',
                        hintStyle: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.all(15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  /* const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    focusNode: _userNameNode,
                    validator: (value) {
                      return checkNullEmptyValidation(value, 'user name');
                    },
                    controller: _userNameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        labelText: 'User Name',
                        labelStyle: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                        hintText: 'Enter your username',
                        hintStyle: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.all(15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ), */
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    focusNode: _passwordNode,
                    obscureText: obsecure,
                    controller: _passwordController,
                    validator: (value) {
                      return validatePassword(value, _passwordController.text);
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye_outlined,
                              color: obsecure
                                  ? AppColors.greyColor
                                  : AppColors.blackColor,
                            ),
                            onPressed: () {
                              setState(() {
                                obsecure = !obsecure;
                              });
                            }),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                        hintText: 'Enter Your Password',
                        hintStyle: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.all(15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    focusNode: _confirmPasswordNode,
                    obscureText: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      return validateSamePassword(
                          value, _passwordController.text);
                    },
                    decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                        hintText: 'Enter Your Confirm Password',
                        hintStyle: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.all(15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  roundedButton(
                      context: context,
                      bgColor: AppColors.secondaryColor,
                      text: 'Sign Up',
                      textColor: AppColors.whiteColor,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          /* NewAccountBody newAccountBody = NewAccountBody(
                              first_name: _firstNameController.text.trim(),
                              last_name: _lastNameController.text.trim(),
                              username: _userNameController.text.trim(),
                              password: _passwordController.text.trim(),
                              email: _emailController.text.trim());
                          authController
                              .newAccount(newAccountBody)
                              .then((response) {
                            Navigator.pop(context);

                            if (response.success == true) {
                              Navigator.of(context)
                                  .pushNamed(HomeScreen.screenId);
                              /* Navigator.pushReplacementNamed(
                                  context, LocationScreen.screenId);*/
                            } else {
                              alert.showAlertDialog(
                                  context, "", response.message!);
                            }
                          });*/
                          //readJson();
                          await authService.getAdminCredentialEmailAndPassword(
                              context: context,
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              isLoginUser: false);
                        }
                      }),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Text(
              'By Signing up you agree to our Terms and Conditions, and Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font16,
                color: AppColors.greyColor,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'Or',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.greyColor,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const SignUpButtons(),
        ],
      ),
    );
  }

  void submitNewAccount() {}
}
