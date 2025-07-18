import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/constants/imgasset.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/controllers/item_controller.dart';
import 'package:pam_app/forms/howyouwanttodescribeit_form.dart';
import 'package:pam_app/screens/addItem/add_item_images.dart';
import 'package:pam_app/screens/addItem/whatdoyouwanttonameit.dart';
import 'package:pam_app/widgets/small_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image/image.dart' as img;

import '../common/alert.dart';
import '../services/auth.dart';

class MediaPickerForm extends StatefulWidget {
  const MediaPickerForm({super.key});

  @override
  State<MediaPickerForm> createState() => _MediaPickerFormState();
}

class _MediaPickerFormState extends State<MediaPickerForm> {
  final List<_MediaItem> _mediaItems = [];
  final ImagePicker _picker = ImagePicker();

  bool _btnEnabled = false;
  Dialogs alert = Dialogs();

  var itemController = Get.find<ItemController>();
  final storage = const FlutterSecureStorage();
  MediaType _mediaType = MediaType.image;

  File? compressedVideo, compressedImg;

  Auth authService = Auth();

  String? _result;
  final String _apiKey = 'AIzaSyDs-7B57GbTGU9RimBiLlR0spvng_ccPTc';
  StringBuffer sb = StringBuffer();
  String lblText = '';
  String imgLabel = '';
  String objName = '';
  double _compressionProgress = 0.0;
  StreamSubscription<double>? _subscription;
  File? compressedFile;
  File? thumbnail;

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    final XFile? picked = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (picked == null) return;

    final mimeType = lookupMimeType(picked.path);
    if (mimeType == null) return;

    File originalFile = File(picked.path);

    if (mimeType.startsWith("video")) {
      // Listen to compression progress
      VideoCompress.compressProgress$.subscribe((progress) {
        setState(() {
          _compressionProgress = progress;
        });
      });

      final info = await VideoCompress.compressVideo(
        originalFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      compressedFile = info?.file ?? originalFile;

      // Generate thumbnail explicitly here:
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: compressedFile!.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      if (thumbPath != null) thumbnail = File(thumbPath);

      // Cancel subscription after compression finishes
      await _subscription?.cancel();
      _subscription = null;
    } else {
      compressedFile = await compressImage(originalFile);
      thumbnail = compressedFile;
    }

    if (compressedFile == null || thumbnail == null) return;

    setState(() {
      _mediaItems.add(_MediaItem(
        file: compressedFile!,
        thumbnail: thumbnail!,
        isVideo: mimeType.startsWith("video"),
      ));
      _btnEnabled = true;
      _compressionProgress = 0.0; // reset progress
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: SmallText(
                text:
                    "For quick entries of many items, take or pick a picture and click 'Save and finish', we will use AI to automatically categorize the image and add some details. If you prefer to add your own details immediately, click 'Add details' and you can add more images, video or add other information.",
                size: Dimensions.font16,
                height: 1.2,
                color: AppColors.greyColor,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _mediaType = MediaType.image;
                    _pickMedia(ImageSource.camera, isVideo: false);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _mediaType = MediaType.image;
                    _pickMedia(ImageSource.gallery, isVideo: false);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _mediaType = MediaType.video;
                    _pickMedia(ImageSource.camera, isVideo: true);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _mediaType = MediaType.video;
                    _pickMedia(ImageSource.gallery, isVideo: true);
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
        Column(
          children: [
            if (_compressionProgress > 0 && _compressionProgress < 100)
              LinearProgressIndicator(
                value: _compressionProgress / 100,
              ),
            Container(
              height: 280,
              child: _mediaItems.isEmpty
                  ? Center(child: Text("No media uploaded yet"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _mediaItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final item = _mediaItems[index];
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  item.thumbnail,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (item.isVideo)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Icon(Icons.play_circle_fill,
                                      color: Colors.white70, size: 36),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.height10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
            context: context,
            bgColor: _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
            textColor: _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
            borderColor:
                _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
            text: 'Add Details',
            onPressed: _btnEnabled
                ? () async {
                    alert.showLoaderDialog(context);

                    await itemController
                        .addMyItemPrimaryImage("", "", compressedFile!)
                        .then((result) {
                      if (result.isSuccess) {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, WhatDoYouWantToNameItScreen.screenId);
                      } else {
                        alert.showAlertDialog(context, "title", result.message);
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
            bgColor: _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
            textColor: _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
            borderColor:
                _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
            text: 'Save and finish',
            onPressed: _btnEnabled
                ? () async {
                    alert.showLoaderDialog(context);

                    try {
                      if (_mediaType == MediaType.image) {
                        await classifyImage(compressedFile);
                      } else if (_mediaType == MediaType.video) {
                        await itemController
                            .addMyItemPrimaryImage("", "", compressedFile!)
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
    );
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
          Navigator.of(context).pop(false);
        } else {}
      });
    }
  }
}

class _MediaItem {
  final File file;
  final File thumbnail;
  final bool isVideo;

  _MediaItem(
      {required this.file, required this.thumbnail, required this.isVideo});
}
