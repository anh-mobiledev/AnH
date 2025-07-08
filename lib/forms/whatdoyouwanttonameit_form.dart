import 'dart:io';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/services/auth.dart';

import '../common/alert.dart';
import '../common/utility.dart';
import '../constants/colours.dart';
import '../controllers/item_controller.dart';
import '../models/item_image.dart';
import '../screens/addItem/add_details.dart';
import '../screens/home_screen.dart';

class WhatDoYouWanttoNameItForm extends StatefulWidget {
  @override
  State<WhatDoYouWanttoNameItForm> createState() =>
      _WhatDoYouWanttoNameItFormState();
}

class _WhatDoYouWanttoNameItFormState extends State<WhatDoYouWanttoNameItForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemNameController;
  late final FocusNode _itemNameNode;

  late final TextEditingController _itemDescController;
  late final FocusNode _itemDescNode;

  bool uploading = false;
  double val = 0;

  var itemController = Get.find<ItemController>();
  Dialogs alert = Dialogs();

  DBHelper dbHelper = DBHelper();

  bool _isConnected = false;
  late List<ItemImage> images;

  PageController pageController = PageController(viewportFraction: 0.85);
  double _curPageValue = 0.0;
  double _scaleFactor = 0.8;
  double _height = Dimensions.pageViewContainer;

  bool _btnEnabled = false;
  bool isLoading = true;
  late final InternetConnectionCheckerPlus _connectionChecker;
  Auth authService = Auth();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    _itemNameController = TextEditingController();
    _itemNameNode = FocusNode();

    _itemDescController = TextEditingController();
    _itemDescNode = FocusNode();

    dbHelper = DBHelper();
    //loadImageFromPreferences();
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();

    pageController.addListener(() {
      setState(() {
        _curPageValue = pageController.page!;
      });
    });

    images = [];
    refreshImages();

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

  pickImageFromCamera() {
    ImagePicker().pickImage(source: ImageSource.camera).then((imgFile) async {
      String imgString = Utility.base64String(await imgFile!.readAsBytes());
      print(imgString);
      ItemImage item_image =
          ItemImage(id: 0, item_image: imgString, item_code: 0);

      await dbHelper.saveItemInfo(item_image);
      Get.snackbar('Success', 'Image is stored successfully');
    });
  }

  refreshImages() async {
    isLoading = true;
    dbHelper.getPhotos(0).then((imgs) {
      setState(() {
        images.clear();
        images.addAll(imgs);
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bodyWidget();
  }

  gridView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        crossAxisCount: 1,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: images.map((image) {
          return Image.file(
            File(image.item_image),
            fit: BoxFit.fill,
          );
        }).toList(),
      ),
    );
  }

  _bodyWidget() {
    return isLoading
        ? CircularProgressIndicator()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                //color: Colors.red,
                height: Dimensions.pageViewContainer,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: images.length,
                  itemBuilder: (context, position) {
                    return _buildPageItem(position);
                  },
                ),
              ),
              new DotsIndicator(
                dotsCount: images.length,
                position: _curPageValue,
                decorator: DotsDecorator(
                  activeColor: AppColors.primaryColor,
                  size: const Size.square(9.0),
                  activeSize: const Size(18.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),

              /*SizedBox(
          height: 150,
          child: Flexible(child: gridView(), fit: FlexFit.loose),
        ),*/
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
                        height: Dimensions.height10,
                      ),
                      TextFormField(
                        focusNode: _itemNameNode,
                        controller: _itemNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            labelText: 'Name of item',
                            labelStyle: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 14,
                            ),
                            hintText: 'Enter name of item',
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
                        maxLines: 5,
                        focusNode: _itemDescNode,
                        controller: _itemDescController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 14,
                            ),
                            hintText: 'Enter description of item',
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
                        bgColor: _btnEnabled
                            ? AppColors.secondaryColor
                            : Colors.grey[400],
                        textColor: _btnEnabled
                            ? AppColors.whiteColor
                            : Colors.grey[350],
                        borderColor: _btnEnabled
                            ? AppColors.secondaryColor
                            : Colors.grey[400],
                        text: 'Save and add more details',
                        onPressed: _btnEnabled
                            ? () async {
                                itemController.updateMyItem(
                                    itemController.myItemId,
                                    _itemNameController.text.trim(),
                                    _itemDescController.text.trim(),
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '');

                                Navigator.of(context).pushNamed(
                                  AddDetailsScreen.screenId,
                                  arguments: {
                                    'itemName': _itemNameController.text.trim(),
                                    'itemDesc': _itemDescController.text.trim()
                                  },
                                );
                                Get.snackbar(
                                    'Success', 'Data is stored successfully');
                              }
                            : null,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      roundedButton(
                        context: context,
                        bgColor: AppColors.secondaryColor,
                        text: 'Save and return to home',
                        textColor: AppColors.whiteColor,
                        onPressed: () async {
                          Navigator.pushNamed(context, HomeScreen.screenId);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /* Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
            context: context,
            bgColor: _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
            textColor: _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
            borderColor:
            _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
            text: 'Save and continue',
            onPressed: _btnEnabled ||
                _formKey.currentState != null ||
                _formKey.currentState!.validate()
                ? null
                : () async {
              await updateItemNameInSQLLite(
                  _itemNameController.text.trim(),
                  _itemDescController.text.trim());

              Navigator.of(context).pushNamed(AddDetailsScreen.screenId);
              Get.snackbar('Success', 'Data is stored successfully');
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
            context: context,
            bgColor: AppColors.secondaryColor,
            text: 'Done for now',
            textColor: AppColors.whiteColor,
            onPressed: () async {
              Navigator.pushNamed(context, HomeScreen.screenId);
            },
          ),
        ),*/

              //_bottomNavigationBar(context)
            ],
          );
  }

  void validateButton() {
    bool isValid = true;

    isValid = _itemNameController.text.length > 3;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  /* updateItemNameInServer() {
    itemController
        .addItem(_itemNameController.text, "", "", "", "", "", "")
        .then((response) {
      Navigator.pop(context);
      if (response.isSuccess) {
        print(itemController.finId);

        Navigator.pushNamed(context, AddItemImagesScreen.screenId);
      } else {
        alert.showAlertDialog(
            context, AppConstants.ALERT_TITLE_ADDITEM, response.message);
      }
    });
  }*/

  Future<void> updateItemNameInSQLLite(
      String item_name, String item_desc) async {
    try {
      itemController.updateItemName(item_name, item_desc);
    } catch (e) {}
  }

  Widget _buildPageItem(int index) {
    Matrix4 matrix = new Matrix4.identity();

    if (index == _curPageValue.floor()) {
      var curScale = 1 - (_curPageValue - index) * (1 - _scaleFactor);
      var curTrans = _height * (1 - curScale) / 2;
      matrix = Matrix4.diagonal3Values(1, curScale, 1)
        ..setTranslationRaw(0, curTrans, 0);
    } else if (index == _curPageValue.floor() + 1) {
      var curScale =
          _scaleFactor + (_curPageValue - index + 1) * (1 - _scaleFactor);
      var curTrans = _height * (1 - curScale) / 2;
      Matrix4.diagonal3Values(1, curScale, 1);
      matrix = Matrix4.diagonal3Values(1, curScale, 1)
        ..setTranslationRaw(0, curTrans, 0);
    } else {
      var curScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, curScale, 1)
        ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }
    return Transform(
      transform: matrix,
      child: Stack(
        children: [
          Container(
            height: Dimensions.pageViewContainer,
            margin: EdgeInsets.only(
                left: Dimensions.height10, right: Dimensions.height10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius30),
                // color: index.isEven ? Color(0xff00AABF) : Color(0xFF8f837f),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(File(images[index].item_image)),
                )),
          ),
          /*   Container(
            padding: EdgeInsets.only(
                left: Dimensions.width20,
                right: Dimensions.width20,
                top: Dimensions.height20,
                bottom: Dimensions.height20),
            child: GestureDetector(
              onTap: () {
                //Get.to(PopularFoodDetails());
              },
              child: AppIcon(
                icon: Icons.delete,
                backgroundColor: Colors.red,
                iconSize: Dimensions.iconSize16,
                iconColor: Colors.white,
              ),
            ),
          )*/
        ],
      ),
    );
  }
}
