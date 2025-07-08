import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/controllers/my_collections_controller.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/screens/myCollections/add_parent_collection_screen.dart';
import 'package:pam_app/screens/myCollections/parent_collections_list_screen.dart';
import 'package:pam_app/widgets/small_text.dart';

import '../../common/alert.dart';
import '../../constants/colours.dart';
import 'icon_picker.dart';

class AddCollectionForm extends StatefulWidget {
  @override
  State<AddCollectionForm> createState() => _AddCollectionFormState();
}

class _AddCollectionFormState extends State<AddCollectionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _collectionNameController;
  late final FocusNode _collectionNameNode;

  late final TextEditingController _collectionDescController;
  late final FocusNode _collectionDescNode;

  bool uploading = false;
  double val = 0;

  var collectionController = Get.find<MyCollectionsController>();
  Dialogs alert = Dialogs();

  DBHelper dbHelper = DBHelper();

  bool _isConnected = false;

  bool _btnEnabled = false;
  bool isLoading = true;

  IconData? myObject;
  int icon_code = 0;
  late final InternetConnectionCheckerPlus _connectionChecker;

  @override
  void initState() {
    _collectionNameController = TextEditingController();
    _collectionNameNode = FocusNode();

    _collectionDescController = TextEditingController();
    _collectionDescNode = FocusNode();

    dbHelper = DBHelper();
    //loadImageFromPreferences();
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();

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
  void dispose() {
    _collectionNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bodyWidget();
  }

  _bodyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: Dimensions.height20,
                ),
                TextFormField(
                  focusNode: _collectionNameNode,
                  controller: _collectionNameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      labelText: 'Name of collection',
                      labelStyle: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 14,
                      ),
                      hintText: 'Enter name of collection',
                      hintStyle: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onChanged: (value) {
                    setState(() {
                      validateButton();
                    });
                  },
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: AppColors.secondaryColor, // Button color
                          child: InkWell(
                            splashColor: AppColors.whiteColor, // Splash color
                            onTap: () {
                              _showIconPickerDialog();
                            },
                            child: SizedBox(
                                width: 150,
                                height: 150,
                                child: Icon(
                                  myObject,
                                  size: 120,
                                  color: AppColors.whiteColor,
                                )),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.height10,
                      ),
                      SmallText(
                        text: "Click to Add an Icon",
                        color: AppColors.paraColor,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                TextFormField(
                  maxLines: 5,
                  focusNode: _collectionDescNode,
                  controller: _collectionDescController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: 'Enter an optional description',
                      labelStyle: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 14,
                      ),
                      hintText: 'Enter an optional description',
                      hintStyle: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                /* const SizedBox(
                  height: 10,
                ),
                roundedButton(
                  context: context,
                  bgColor:
                      _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
                  textColor:
                      _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
                  borderColor:
                      _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
                  text: 'Save and continue',
                  onPressed: _btnEnabled
                      ? () async {
                          if (_isConnected) {
                            alert.showLoaderDialog(context);

                            var collectionController =
                                Get.find<MyCollectionsController>();

                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              collectionController
                                  .collectionCreate(
                                      _collectionNameController.text.trim(),
                                      _collectionDescController.text.trim(),
                                      icon_code.toString())
                                  .then(
                                (response) {
                                  if (response.isSuccess) {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context,
                                        AddParentCollectionScreen.screenId);
                                  } else {
                                    Navigator.pop(context);
                                    alert.showAlertDialog(
                                        context, "", response.message);
                                    return;
                                  }
                                },
                              );
                            }
                          } else {
                            saveDataInSQLLite();
                          }
                        }
                      : null,
                ),*/
                const SizedBox(
                  height: 10,
                ),
                roundedButton(
                  context: context,
                  bgColor: AppColors.secondaryColor,
                  text: 'Save collection',
                  textColor: AppColors.whiteColor,
                  onPressed: () async {
                    alert.showLoaderDialog(context);

                    var collectionController =
                        Get.find<MyCollectionsController>();

                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      collectionController
                          .collectionCreate(
                              _collectionNameController.text.trim(),
                              _collectionDescController.text.trim(),
                              icon_code.toString())
                          .then(
                        (response) {
                          if (response.isSuccess) {
                            Navigator.pop(context);
                            Navigator.pushNamed(context,
                                    ParentCollectionsListScreen.screenId)
                                .then((vale) {
                              setState(() {});
                            });
                          } else {
                            Navigator.pop(context);
                            alert.showAlertDialog(
                                context, "", response.message);
                            return;
                          }
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void validateButton() {
    bool isValid = true;

    isValid = _collectionNameController.text.length > 3;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  Future<void> _showIconPickerDialog() async {
    IconData iconPicked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Pick an icon',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: IconPicker(),
        );
      },
    );

    if (iconPicked != null) {
      debugPrint('Icon changed to $iconPicked');
      setState(() {
        myObject = iconPicked;
        icon_code = iconPicked.codePoint;
      });
    }
  }

  int result = 0;
  saveDataInSQLLite() async {
    try {
      final int result = await collectionController.insertParentCollection(
          _collectionNameController.text.trim(),
          _collectionDescController.text.trim(),
          icon_code);
      if (result != 0) {
        Navigator.pop(context);
        Navigator.pushNamed(context, AddParentCollectionScreen.screenId);
      } else {
        alert.showAlertDialog(context, "Failure", "Oops! Something went wrong");
      }
    } catch (e) {}
    return 0;
  }

  saveDataIntoServer() {}
}
