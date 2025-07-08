import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/controllers/my_collections_controller.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/screens/myCollections/child_collection_list_screen.dart';

import '../../common/alert.dart';
import '../../constants/colours.dart';

class AddChildCollectionForm extends StatefulWidget {
  @override
  State<AddChildCollectionForm> createState() => _AddChildCollectionFormState();
}

class _AddChildCollectionFormState extends State<AddChildCollectionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _collectionNameController;
  late final FocusNode _collectionNameNode;

  late final TextEditingController _collectionCurrentValueController;
  late final FocusNode _collectionCurrentValueNode;

  bool uploading = false;
  double val = 0;

  var collectionController = Get.find<MyCollectionsController>();
  Dialogs alert = Dialogs();

  DBHelper dbHelper = DBHelper();

  bool _isConnected = false;

  bool _btnEnabled = false;
  bool isLoading = true;
  int? parentId;
  String? title;
  IconData? myObject;
  late String action;
  late String collectionName;
  late String currentValue;

  late String collectionId;
  late String altDescription;
  late String qty;
  late String qtyUnits;
  late String forSale;
  late String forRent;
  late String sharable;
  late final InternetConnectionCheckerPlus _connectionChecker;
  @override
  void initState() {
    _collectionNameController = TextEditingController();
    _collectionNameNode = FocusNode();

    _collectionCurrentValueController = TextEditingController();
    _collectionCurrentValueNode = FocusNode();

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
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    setState(() {
      parentId = arguments['parentId'];
      title = arguments['title'];
      action = arguments['action'];

      // print(action = arguments['action']);

      if (action == "edit") {
        _collectionNameController.text = arguments['child_name'];
        _collectionCurrentValueController.text =
            arguments['current_value'].toString();
      }
    });
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
                TextFormField(
                  focusNode: _collectionCurrentValueNode,
                  controller: _collectionCurrentValueController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: 'Enter current value',
                      labelStyle: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 14,
                      ),
                      hintText: 'Enter current value',
                      hintStyle: TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
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
                  text: action == "edit" ? "Update" : "Save",
                  onPressed: _btnEnabled
                      ? () async {
                          if (_isConnected) {
                            saveDataIntoServer();
                          } else {
                            saveDataInSQLLite();
                          }
                        }
                      : null,
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

  int result = 0;
  saveDataInSQLLite() async {
    try {
      alert.showLoaderDialog(context);
      int result = await collectionController.insertChildCollection(
          _collectionNameController.text.trim(),
          double.parse(_collectionCurrentValueController.text.toString()),
          parentId!);

      if (result != 0) {
        Navigator.pop(context);
        Navigator.pushNamed(context, ChildCollectionsListScreen.screenId,
            arguments: {
              'parentId': parentId,
              'title': title,
            });
      } else {
        Navigator.pop(context);
        alert.showAlertDialog(context, "Failure", "Oops! Something went wrong");
      }
    } catch (e) {}
    return 0;
  }

  saveDataIntoServer() {
    alert.showLoaderDialog(context);

    /* var collectionController = Get.find<MyCollectionsController>();

  

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      collectionController
          .collectionItemCreate(
              collectionController.getUserToken(),
              collectionId,
              
              altDescription,
              qty,
              qtyUnits,
              forSale,
              forRent,
              sharable)
          .then(
        (response) {
          if (response.isSuccess) {
            Navigator.pop(context);
            Navigator.pushNamed(context, ChildCollectionsListScreen.screenId,
                arguments: {
                  'parentId': parentId,
                  'title': title,
                });
          } else {
            Navigator.pop(context);
            alert.showAlertDialog(context, "", response.message);
            return;
          }
        },
      );
    }*/
  }
}
