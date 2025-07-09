import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pam_app/screens/addItem/add_item_image.dart';
import 'package:path_provider/path_provider.dart';

import '../common/alert.dart';
import '../constants/colours.dart';
import '../constants/widgets.dart';
import '../controllers/item_controller.dart';
import '../screens/addItem/whatdoyouwanttonameit.dart';

class AddItemImageForm extends StatefulWidget {
  const AddItemImageForm({super.key});

  @override
  State<AddItemImageForm> createState() => _AddItemImageFormState();
}

class _AddItemImageFormState extends State<AddItemImageForm> {
  XFile? _image;

// Create a Random object for generating random numbers
  final Random _random = Random();
  int _randomNumber = 0;
  final ImagePicker _picker = ImagePicker();
  String? _result;
  final String _apiKey =
      'AIzaSyDs-7B57GbTGU9RimBiLlR0spvng_ccPTc'; //"AIzaSyDs-7B57GbTGU9RimBiLlR0spvng_ccPTc"
  bool _isLoading = false;

  var itemController = Get.find<ItemController>();
  File? _imageFile;
  
  /// late InputImage _inputImage;
  /// static final ImageLabelerOptions _options = ImageLabelerOptions(confidenceThreshold: 0.8);

  /// final imageLabeler = ImageLabeler(options: _options);

  String imageName = "";

  Future<void> pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.camera);

    if (_image != null) {
      setState(() {
        _imageFile = File(_image!.path);
      });
      
      //  _inputImage = InputImage.fromFile(_imageFile!);

      // identifyImage(_inputImage);

      // classifyImage(_image!.path);
    }
  }

  StringBuffer sb = StringBuffer();
  String lblText = '';
 /* void identifyImage(InputImage inputImage) async {
    alert.showLoaderDialog(context);

    final List<ImageLabel> image = await imageLabeler.processImage(inputImage);

    if (image.isEmpty) {
      setState(() {
        imageName = "";
      });
      return;
    }

    for (ImageLabel img in image) {
      if (lblText.isNotEmpty) {
        lblText = lblText + ',' + img.label;
      } else {
        lblText = img.label;
      }

      // print("Label : ${lblText}\nConfidence : ${img.confidence}");
    }
    print(lblText);
    try {
      Directory directory = await getApplicationDocumentsDirectory();

      File(_image!.path).copy('${directory.path}/${_image!.name}');

      String img_local_path = '${directory.path}/${_image!.name}';

      generateRandomNumber();

      await itemController.insertItemImageSQLLite(
          img_local_path, _randomNumber);
      await itemController.insertItemImageCode(_randomNumber, lblText, "");

      // await itemController.insertItem_Image_Name(img_local_path, lblText);
    } catch (e) {
      return null;
    }

    imageLabeler.close();
    setState(() {
      _btnEnabled = true;
    });

    Navigator.pop(context);
  }*/

  Future<void> classifyImage(String imagePath) async {
    alert.showLoaderDialog(context);

    final bytes = File(imagePath).readAsBytesSync();
    final String base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(
          "https://vision.googleapis.com/v1/images:annotate?key=$_apiKey"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'LABEL_DETECTION', 'maxResults': 10},
              {'type': 'OBJECT_LOCALIZATION', 'maxResults': 5}
            ]
          }
        ]
      }),
    );

    try {
      Directory directory = await getApplicationDocumentsDirectory();

      File(_image!.path).copy('${directory.path}/${_image!.name}');

      String img_local_path = '${directory.path}/${_image!.name}';

      generateRandomNumber();

      await itemController.insertItemImageSQLLite(
          img_local_path, _randomNumber);
      await itemController.insertItemImageCode(_randomNumber, lblText, "");
    } catch (e) {
      return null;
    }

    print('Status code: ${response.statusCode}');
    print('Response :  ${jsonDecode(response.body)}');

    setState(() {
      _btnEnabled = true;
    });

    Navigator.pop(context);
  }

  bool _btnEnabled = false;
  Dialogs alert = Dialogs();

  showImage() {
    /*Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: (Colors.red[200])!, width: 1.0),
                borderRadius: BorderRadius.circular(10.0)),
            child: Column(
              children: <Widget>[
                SizedBox(height: 30.0),
                Icon(Icons.camera_alt, color: Colors.red),
                SizedBox(height: 10.0),
                Text('Take Image of the Item',
                    style: TextStyle(color: Colors.red)),
                SizedBox(height: 30.0)
              ],
            ),
          )
        : Image.file(
            _imageFile!); SizedBox(
            height: 400,
            child: Card(
              elevation: 5,
              shadowColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              margin: EdgeInsets.all(5),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          10,
                        ),
                        topRight: Radius.circular(
                          10,
                        ),
                      ),
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: FileImage(
                          File(_image!.path),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: Dimensions.width20,
                        right: Dimensions.width20,
                        top: Dimensions.height20,
                        bottom: Dimensions.height20),
                    child: GestureDetector(
                      onTap: () {
                        pickImage();
                        //getImagefromCamera();
                      },
                      child: AppIcon(
                        icon: Icons.camera_alt_outlined,
                        backgroundColor: Colors.red,
                        iconSize: Dimensions.iconSize16,
                        iconColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );*/
  }

  void generateRandomNumber() {
    setState(
      () {
        _randomNumber =
            1000 + _random.nextInt(9000); // Generates a random 4-digit number
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          pickImage();
          //getImagefromCamera();
        },
        child: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: (Colors.red[200])!, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 30.0),
                    Icon(Icons.camera_alt, color: Colors.red),
                    SizedBox(height: 10.0),
                    Text('Take Image of the Item',
                        style: TextStyle(color: Colors.red)),
                    SizedBox(height: 30.0)
                  ],
                ),
              ),

            // Text(text, style: TextStyle(fontSize: 20)),

            Container(
              padding: EdgeInsets.all(16.0),
              width: double.infinity,
              child: roundedButton(
                context: context,
                bgColor:
                    _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
                textColor:
                    _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
                borderColor:
                    _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
                text: 'Continue',
                onPressed: _btnEnabled
                    ? () {
                        Navigator.pushNamed(
                            context, WhatDoYouWantToNameItScreen.screenId);
                      }
                    : null,
              ),
            ),

            Container(
              padding: EdgeInsets.all(16.0),
              width: double.infinity,
              child: roundedButton(
                context: context,
                bgColor:
                    _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
                textColor:
                    _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
                borderColor:
                    _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
                text: 'Next item',
                onPressed: _btnEnabled
                    ? () async {
                        Navigator.pushNamed(
                            context, AddItemImageScreen.screenId);
                      }
                    : null,
              ),
            )
          ]),
        ));
  }
}
