import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/services/auth.dart';
import 'package:pam_app/widgets/small_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

import '../common/alert.dart';
import '../constants/colours.dart';
import '../constants/imgasset.dart';
import '../constants/widgets.dart';
import '../controllers/item_controller.dart';
import '../helper/DBHelper.dart';
import '../models/item_image.dart';
import '../models/photo.dart';
import '../screens/addItem/add_item_images.dart';
import '../screens/addItem/whatdoyouwanttonameit.dart';
import 'howyouwanttodescribeit_form.dart';

class AddItemImagesForm extends StatefulWidget {
  const AddItemImagesForm({super.key});

  @override
  State<AddItemImagesForm> createState() => _AddItemImagesFormState();
}

class _AddItemImagesFormState extends State<AddItemImagesForm> {
  //late File fileMedia;
  final ImagePicker imagePicker = ImagePicker();

  List<XFile>? imageFileList = [];
  MediaType _mediaType = MediaType.image;
  String? imagePath;

  Photo photo = Photo();
  ItemImage image = ItemImage(item_image: "");
  DBHelper dbHelper = DBHelper();
  late List<ItemImage> images;
  final Random _random =
      Random(); // Create a Random object for generating random numbers
  int _randomNumber = 0;
  int itemCode = -1;
  var itemController = Get.find<ItemController>();

  bool _btnEnabled = false;
  Dialogs alert = Dialogs();

  StringBuffer sb = StringBuffer();
  String lblText = '';
  String imgLabel = '';
  String objName = '';
  var imgFile;
  final storage = const FlutterSecureStorage();

  /// static final ImageLabelerOptions _options = ImageLabelerOptions(confidenceThreshold: 0.75);

  /// final imageLabeler = ImageLabeler(options: _options);
  ///
  Auth authService = Auth();

  String? _result;
  final String _apiKey = 'AIzaSyDs-7B57GbTGU9RimBiLlR0spvng_ccPTc';

  void generateRandomNumber() {
    setState(
      () {
        _randomNumber =
            1000 + _random.nextInt(9000); // Generates a random 4-digit number
      },
    );
  }

  @override
  void initState() {
    super.initState();
    images = [];
    dbHelper = DBHelper();
    print('initState method itemCode: ${itemCode}');
    refreshImages(itemCode);
  }

  refreshImages(int item_code) {
    dbHelper.getPhotos(item_code).then((imgs) {
      
      setState(() {
        images.clear();
        images.addAll(imgs);
      });
    });
  }

  gridView() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: images.map((image) {
          return Card(
            elevation: 5,
            shadowColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            margin: EdgeInsets.all(5),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
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
                          fit: BoxFit.cover,
                          image: FileImage(
                            File(image.item_image),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: () async {
                        confirmDialog(image.id!, image.item_image);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: Colors.red),
                            SizedBox(
                              width: 5,
                            ),
                            SmallText(
                              text: "Remove this",
                              color: Colors.red,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  File? compressedVideo;

  pickVideo(ImageSource source) async {
    final videoFile = await ImagePicker().pickVideo(source: source);

    if (videoFile != null) {
      alert.showLoaderDialog(context);

      compressedVideo = await compressVideo(File(videoFile.path));

      Directory directory = await getApplicationDocumentsDirectory();

      File(videoFile.path).copy('${directory.path}/${videoFile.name}');

      String video_local_path = '${directory.path}/${videoFile.name}';

      if (_randomNumber == 0) {
        generateRandomNumber();

        itemCode = _randomNumber;
      } else {
        itemCode = _randomNumber;
      }

      await itemController.insertItemImageSQLLite(video_local_path, itemCode);

      await itemController.insertItemImageCode(itemCode, "", "");

      setState(() {
        _btnEnabled = true;
      });

      refreshImages(itemCode);

      Navigator.pop(context);
    }
  }

  Future<void> classifyImage(File? imagePath) async {
    print('Entering AI');

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      imagePath!.absolute.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 75, // adjust as needed
      format: CompressFormat.jpeg,
    );

    final String base64Image = base64Encode(compressedBytes!);

    //final bytes = await imagePath!.readAsBytesSync();
    //final String base64Image = base64Encode(bytes);

    final response = await http
        .post(
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
    )
        .timeout(Duration(seconds: 10), onTimeout: () {
      throw TimeoutException("Cloud Vision API request timed out");
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> extractedData = jsonDecode(response.body);
      List<dynamic> labelAnnotations =
          extractedData["responses"][0]["labelAnnotations"];
      labelAnnotations.forEach((entry) {
        if (imgLabel.isNotEmpty) {
          imgLabel = imgLabel + ',' + entry['description'];
        } else {
          imgLabel = entry['description'];
        }
      });
      List<dynamic> objectAnnotations =
          extractedData["responses"][0]["localizedObjectAnnotations"];
      objectAnnotations.forEach((entry) {
        if (objName.isNotEmpty) {
          objName = entry['name'];
        } else {
          objName = entry['name'];
        }
      });

      print('obj name ${objName}, \n image name ${imgLabel}');
      await itemController
          .addMyItemPrimaryImage(objName, imgLabel, imagePath)
          .then((result) {
        if (result.isSuccess) {
          Navigator.pop(context);
          Navigator.pushNamed(context, AddItemImagesScreen.screenId);
        } else {}
      });
    }
  }

  File? compresssedImg;
  pickImage(ImageSource source) async {
    try {
      imgFile = await imagePicker.pickImage(source: source);

      if (imgFile != null) {
        alert.showLoaderDialog(context);

        compresssedImg = await compressImage(File(imgFile.path));

        Directory directory = await getApplicationDocumentsDirectory();

        File(imgFile.path).copy('${directory.path}/${imgFile.name}');

        String img_local_path = '${directory.path}/${imgFile.name}';

        if (_randomNumber == 0) {
          generateRandomNumber();

          itemCode = _randomNumber;
        } else {
          itemCode = _randomNumber;
        }

        await itemController.insertItemImageSQLLite(img_local_path, itemCode);

        await itemController.insertItemImageCode(itemCode, objName, imgLabel);

        setState(() {
          _btnEnabled = true;
        });

        refreshImages(itemCode);

        Navigator.pop(context);
      }
    } catch (e) {
      return null;
    }
  }

  Future<File> compressImage(File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path, targetPath,
      quality: 70, // Adjust quality (0-100)
    );

    return File(result!.path);
  }

  Future<File?> compressVideo(File videoFile) async {
    File videoCopressedFile = File(videoFile.path);
    // Compress the video
    final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
      videoCopressedFile.path,
      quality: VideoQuality
          .MediumQuality, // LowQuality, MediumQuality, HighestQuality
      deleteOrigin: false, // Set to true to remove the original file
    );

    return compressedVideo?.file;
    /*
    // Pick a video file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      // File videoFile = File(result.files.single.path!);

      File videoCopressedFile = File(videoFile.path);
      // Compress the video
      final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
        videoCopressedFile.path,
        quality: VideoQuality
            .MediumQuality, // LowQuality, MediumQuality, HighestQuality
        deleteOrigin: false, // Set to true to remove the original file
      );

      return compressedVideo?.file;
    }
    return null;*/
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "For quick entries of many items, take or pick a picture and click 'Next Item', we will use AI to automatically categorize the image and add some details. If you prefer to add your own details immediately, click 'Continue' and you can add more images, video or add other information.",
                style: TextStyle(color: AppColors.paraColor)),
          ),

          //Take photo / upload image
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _mediaType = MediaType.image;

                      pickImage(ImageSource.camera);
                    },
                    child: Image.asset(
                      imgcamera,
                      height: 80,
                      width: 80,
                    ),
                  ),
                  Text("Take photo"),
                ],
              ),
              SizedBox(
                height: 30,
                width: 50,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _mediaType = MediaType.image;

                      pickImage(ImageSource.gallery);
                    },
                    child: Image.asset(
                      imggallery,
                      height: 80,
                      width: 80,
                    ),
                  ),
                  Text("Upload photo"),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _mediaType = MediaType.video;

                      pickVideo(ImageSource.camera);
                    },
                    child: Image.asset(
                      imgvideocamera,
                      height: 80,
                      width: 80,
                    ),
                  ),
                  Text("Record video"),
                ],
              ),
              SizedBox(
                height: 30,
                width: 50,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _mediaType = MediaType.video;

                      pickVideo(ImageSource.gallery);
                    },
                    child: Image.asset(
                      imgvideo,
                      height: 80,
                      width: 80,
                    ),
                  ),
                  Text("Upload video"),
                ],
              ),
            ],
          ),

          gridView(),
          SizedBox(height: Dimensions.height10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: roundedButton(
              context: context,
              bgColor:
                  _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
              textColor: _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
              borderColor:
                  _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
              text: 'Add Details',
              onPressed: _btnEnabled
                  ? () async {
                      alert.showLoaderDialog(context);
                      File? filePath;

                      if (_mediaType == MediaType.image) {
                        filePath = File(compresssedImg!.path);
                      } else if (_mediaType == MediaType.video) {
                        filePath = File(compressedVideo!.path);
                      }
                      await itemController
                          .addMyItemPrimaryImage("", "", filePath!)
                          .then((result) {
                        if (result.isSuccess) {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, WhatDoYouWantToNameItScreen.screenId);
                        } else {
                          alert.showAlertDialog(
                              context, "title", result.message);
                        }
                      });
                    }
                  : null,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: roundedButton(
              context: context,
              bgColor:
                  _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
              textColor: _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
              borderColor:
                  _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
              text: 'Add Next Item',
              onPressed: _btnEnabled
                  ? () async {
                      alert.showLoaderDialog(context);

                      File? filePath;
                      try {
                        if (_mediaType == MediaType.image) {
                          filePath = File(compresssedImg!.path);
                          await classifyImage(filePath);
                        } else if (_mediaType == MediaType.video) {
                          filePath = File(compressedVideo!.path);

                          await itemController
                              .addMyItemPrimaryImage("", "", filePath)
                              .then((result) {
                            Navigator.pop(context);

                            if (result.isSuccess) {
                              Navigator.pushNamed(
                                  context, AddItemImagesScreen.screenId);
                            } else {
                              alert.showAlertDialog(
                                  context, "title", result.message);
                            }
                          });
                        }
                      } on TimeoutException {
                        alert.showAlertDialog(context, "",
                            "Google AI is taking too long. Try again.");
                      } catch (e) {
                        authService.logout();
                      }
                    }
                  : null,
            ),
          )
        ],
      ),
    );
  }

  Future<void> confirmDialog(int id, String image_path) async {
    print('image id --> ${id} image path --> ${image_path}');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text('Are you sure want delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();

                //  alert.showLoaderDialog(context);

                //Delete the item image from local storage
                final targetFile = await Directory(image_path);
                targetFile.deleteSync(recursive: true);

                //Delete the item image from SQLLite database
                await itemController.deleteItemImageById_SQLLite(id);
                Get.snackbar('Success', 'Image deleted successfully');

                setState(() {
                  _btnEnabled = false;
                });

                refreshImages(itemCode);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
