import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/alert.dart';
import '../common/utility.dart';
import '../constants/colours.dart';
import '../controllers/item_controller.dart';

enum MediaType {
  image,
  video;
}

class HowYouWantToDescribeItForm extends StatefulWidget {
  const HowYouWantToDescribeItForm({super.key});

  @override
  State<HowYouWantToDescribeItForm> createState() =>
      _HowYouWantToDescribeItFormState();
}

class _HowYouWantToDescribeItFormState
    extends State<HowYouWantToDescribeItForm> {
  final _formKey = GlobalKey<FormState>();
  var _countertext = '';
  late final TextEditingController _itemValueController;
  late final FocusNode _itemValueNode;

  final ImagePicker imagePicker = ImagePicker();
  List<File>? imageFiles = [];
  MediaType _mediaType = MediaType.image;
  //String? imagePath;
  List<String> downloadUrls = [];

  File? _cameraImage;
  bool uploading = false;
  double val = 0;
  List<XFile>? imageFileList = [];
  //MediaType _mediaType = MediaType.image;

  final picker = ImagePicker();
  late SharedPreferences sharedPreferences;
  //late firebase_storage.Reference ref;

  Map<String, bool> values = {
    'Estate planning/Executorship': false,
    'Insurance inventory': false,
    'For sale': false,
    'Net worth': false,
    'Divorce/Separation': false,
  };
  var tmpArray = [];
  bool? _chkIdontknow = false;
  Map<String, bool?> _noCashOptions = {
    'Personal': false,
    'Heirloom': false,
    'Keepsake': false,
  };
  bool _checkboxListTile = false;
  // getCheckboxItems() {
  //   values.forEach((key, value) {
  //     if (value == true) {
  //       tmpArray.add(key);
  //     }
  //   });

  //   // Printing all selected items on Terminal screen.
  //   print(tmpArray);
  //   // Here you will get all your selected Checkbox items.

  //   // Clear array after use.
  //   tmpArray.clear();
  // }
  Image? imageFromPreferences;
  var itemController = Get.find<ItemController>();
  Dialogs alert = Dialogs();

  bool _isConnected = false;
  late final InternetConnectionCheckerPlus _connectionChecker;

  @override
  void initState() {
    _itemValueController = TextEditingController();
    _itemValueNode = FocusNode();

    loadImageFromPreferences();
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

  loadImageFromPreferences() {
    Utility.getImageFromPreferences().then((img) {
      if (null == img) {
        return;
      }
      setState(() {
        imageFromPreferences = Utility.imageFromBase64String(img);
      });
    });
  }

  @override
  void dispose() {
    _itemValueController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.secondaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.whiteColor),
        title: Text(
          '',
          style: TextStyle(color: AppColors.whiteColor),
        ),
      ),
      body: _bodyWidget(context),
    );
  }

  Widget _bottomNavigationBar(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: roundedButton(
            context: context,
            bgColor: AppColors.whiteColor,
            borderColor: AppColors.blackColor,
            textColor: AppColors.blackColor,
            text: "Tell it's story",
            onPressed: () async {},
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: roundedButton(
            context: context,
            bgColor: AppColors.secondaryColor,
            text: 'Done for now',
            textColor: AppColors.whiteColor,
            onPressed: () async {
              // sharedPreferences = await SharedPreferences.getInstance();
              //sharedPreferences.setBool("skipbtn", false);
              if (_formKey.currentState!.validate()) {}
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  updateItemDetails_Server() {}

  Widget _bodyWidget(context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageFromPreferences!,
            const SizedBox(
              height: 20,
            ),
            if (_cameraImage != null)
              Container(
                  height: 200,
                  width: 200,
                  child: Image.file(
                    _cameraImage!,
                    fit: BoxFit.cover,
                  ))
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Dimensions.height45,
                      ),
                      TextFormField(
                        focusNode: _itemValueNode,
                        controller: _itemValueController,
                        validator: (value) {
                          //return checkNullEmptyValidation(value, 'item name');
                        },
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            labelText: 'What is its value?',
                            labelStyle: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 14,
                            ),
                            hintText: 'Enter value of item',
                            hintStyle: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                      SizedBox(
                        height: Dimensions.height20,
                      ),
                      CheckboxListTile(
                        //checkbox positioned at left
                        value: _chkIdontknow,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setState(() {
                            _chkIdontknow = value;
                          });
                        },
                        title: Text("I don't know"),
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No cash value? So is it...',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black54),
                        ),
                      ),
                      Column(
                        children: _noCashOptions.keys
                            .map((roomName) => CheckboxListTile(
                                  title: Text(roomName),
                                  value: _noCashOptions[roomName],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _noCashOptions[roomName] = value;
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              height: Dimensions.height30,
            ),
            _bottomNavigationBar(context)
          ],
        ),
      ),
    );
  }
}
