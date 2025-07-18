import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/models/attachments_list.dart';
import 'package:pam_app/services/auth.dart';
import 'package:pam_app/widgets/app_icon.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../common/alert.dart';
import '../common/utility.dart';
import '../constants/colours.dart';
import '../controllers/item_controller.dart';
import '../models/item_image.dart';
import '../screens/addItem/VideoPlayerScreen.dart';
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

  PageController pageController = PageController(viewportFraction: 0.85);
  double _curPageValue = 0.0;
  double _scaleFactor = 0.8;
  double _height = Dimensions.pageViewContainer;

  bool _btnEnabled = false;
  bool isLoading = true;
  late final InternetConnectionCheckerPlus _connectionChecker;
  Auth authService = Auth();
  final storage = const FlutterSecureStorage();
  final myItemId = "";
  String? mediaUrl;

  @override
  void initState() {
    _itemNameController = TextEditingController();
    _itemNameNode = FocusNode();

    _itemDescController = TextEditingController();
    _itemDescNode = FocusNode();

    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();

    getMyItemAttachmentsList();

    pageController.addListener(() {
      setState(() {
        _curPageValue = pageController.page!;
      });
    });

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

  getMyItemAttachmentsList() async {
    final myItemId = await storage.read(key: 'myItemId');
    print('myItemId :: ${myItemId}');
    itemController.getMyItemsAttachmentsController(myItemId!);
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

  _bodyWidget() {
    return GetBuilder<ItemController>(
      builder: (controller) {
        return controller.isLoaded
            ? Column(
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
                      itemCount:
                          controller.myItemAttachmentsListIndexServer.length,
                      itemBuilder: (context, position) {
                        return _buildPageItem(
                            position,
                            controller
                                .myItemAttachmentsListIndexServer[position]);
                      },
                    ),
                  ),
                  new DotsIndicator(
                    dotsCount: max(
                        1, controller.myItemAttachmentsListIndexServer.length),
                    position: _curPageValue,
                    decorator: DotsDecorator(
                      activeColor: AppColors.primaryColor,
                      size: const Size.square(9.0),
                      activeSize: const Size(18.0, 9.0),
                      activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
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
                                        'itemName':
                                            _itemNameController.text.trim(),
                                        'itemDesc':
                                            _itemDescController.text.trim()
                                      },
                                    );
                                    Get.snackbar('Success',
                                        'Data is stored successfully');
                                  }
                                : null,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          roundedButton(
                              bgColor: _btnEnabled
                                  ? AppColors.secondaryColor
                                  : Colors.grey[400],
                              textColor: _btnEnabled
                                  ? AppColors.whiteColor
                                  : Colors.grey[350],
                              borderColor: _btnEnabled
                                  ? AppColors.secondaryColor
                                  : Colors.grey[400],
                              text: 'Save and return to home',
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

                                      Navigator.pushNamed(
                                          context, HomeScreen.screenId);
                                    }
                                  : null),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator();
      },
    );
  }

  void validateButton() {
    bool isValid = true;

    isValid = _itemNameController.text.length > 3;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  Future<void> updateItemNameInSQLLite(
      String item_name, String item_desc) async {
    try {
      itemController.updateItemName(item_name, item_desc);
    } catch (e) {}
  }

  bool _isVideo(String path) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.3gp'];
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  final Map<String, ImageProvider> _cache = {};

  Future<ImageProvider?> _getThumbnailImage(String mediaUrl) async {
    if (_cache.containsKey(mediaUrl)) {
      return _cache[mediaUrl];
    }

    if (_isVideo(mediaUrl)) {
      // final tempDir = await getTemporaryDirectory();

      final thumbData = await VideoThumbnail.thumbnailData(
        video: mediaUrl,
        // thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 150,
        quality: 75,
      );

      if (thumbData != null) {
        final imageProvider = MemoryImage(thumbData);
        _cache[mediaUrl] = imageProvider;
        return imageProvider;
      }
      return null;
    } else {
      return CachedNetworkImageProvider(mediaUrl);
    }
  }

  Widget _placeholderBox(Widget child) {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildPageItem(int index, MyitemImgsModel attachment) {
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
          FutureBuilder<ImageProvider?>(
            future: _getThumbnailImage(attachment.imgUrl!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 200,
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  height: Dimensions.pageViewContainer,
                  margin: EdgeInsets.symmetric(horizontal: Dimensions.height10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: snapshot.data!,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset(2, 3))
                    ],
                  ),
                  child: _isVideo(attachment.imgUrl!)
                      ? Center(
                          child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerScreen(
                                    videoUrl: attachment.imgUrl!),
                              ),
                            );
                          },
                          child: Icon(Icons.play_circle_fill,
                              size: 50, color: Colors.white),
                        ))
                      : null,
                );
              }

              return _placeholderBox(const Icon(Icons.broken_image, size: 40));
            },
          ),
          /* Container(
            padding: EdgeInsets.only(
                left: Dimensions.width20,
                right: Dimensions.width20,
                top: Dimensions.height20,
                bottom: Dimensions.height20),
            child: GestureDetector(
              onTap: () {
                print('Open media: $mediaUrl');
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
