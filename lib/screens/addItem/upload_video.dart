import 'dart:io';

//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/screens/addItem/whatdoyouwanttonameit.dart';
import 'package:pam_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/bottom_nav_widget.dart';
import '../../constants/colours.dart';
import '../../constants/imgasset.dart';

enum MediaType {
  image,
  video;
}

class UploadVideoScreen extends StatefulWidget {
  static const screenId = 'uploadvideo_screen';
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final ImagePicker imagePicker = ImagePicker();

  XFile? videoFileList;
  String? downloadUrls;
  File? imageFiles;
  MediaType _mediaType = MediaType.image;
  String? imagePath;

  final picker = ImagePicker();

  bool uploading = false;
  double val = 0;
  //late CollectionReference imgRef;
  //late firebase_storage.Reference ref;
  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushNamed(HomeScreen.screenId);
          },
        ),
        title: Text(
          '',
          style: TextStyle(color: AppColors.blackColor),
        ),
        actions: [
          //actions widget in appbar
          TextButton(
              onPressed: () async {
                setState(() {
                  uploading = true;
                });

                if (videoFileList != null) {
                  // uploadFiles();
                } else {
                  uploading = false;
                  Get.snackbar('Error', 'Please upload any videos',
                      backgroundColor: Colors.red);
                }
              },
              child: Text(
                'Next',
                style:
                    TextStyle(fontSize: Dimensions.font20, color: AppColors.blackColor),
              ))
        ],
      ),
      body: _body(context),
      bottomNavigationBar: BottomNavigationWidget(
        buttonText: 'Skip images',
        validator: true,
        onPressed: () async {
          Navigator.of(context).pushNamed(WhatDoYouWantToNameItScreen.screenId);
        },
      ),
    );
  }

  Widget _body(context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Stack(
                children: [
                  (imagePath != null)
                      ? Image.file(File(imagePath!))
                      : Center(
                          child: Container(
                            width: 300,
                            height: 300,
                            color: Colors.grey[300]!,
                          ),
                        ),
                  uploading
                      ? Center(
                          child: Container(
                            height: Dimensions.height20 * Dimensions.height10,
                            width: Dimensions.height120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(
                                    'uploading...',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                                CircularProgressIndicator(
                                  value: val,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      // Navigator.of(context).pushNamed(UploadVideoScreen.screenId);
                    },
                    child: Image.asset(
                      imgvideo,
                      height: 100,
                      width: 100,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        backgroundColor: Colors.white,
                        shadowColor: Colors.grey[400],
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        _mediaType = MediaType.video;
                        // pickMedia(ImageSource.gallery);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.image,
                              size: 30,
                              color: Colors.red,
                            ),
                            Text(
                              "Gallery",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        backgroundColor: Colors.white,
                        shadowColor: Colors.grey[400],
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        _mediaType = MediaType.video;
                        // pickMedia(ImageSource.camera);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.red,
                            ),
                            Text(
                              "Camera",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* Future uploadFiles() async {
    sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getBool("isRecord_video"));

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('videos/${Path.basename(videoFileList!.path)}');

    UploadTask uploadTask = ref.putFile(
        File(videoFileList!.path), SettableMetadata(contentType: 'video/mp4'));

    var storageTaskSnapshot = await uploadTask.whenComplete(() => null);
    var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    final String url = downloadUrl.toString();

    User? user = FirebaseAuth.instance.currentUser;

    if (sharedPreferences.getBool("isRecord_video") == false) {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('item_media').doc();
      documentReference.set({
        'link': url,
        'user_id': user!.uid,
        'item_id': documentReference.id
      }).then((value) {
        Navigator.of(context).pushNamed(WhatDoYouWantToNameItScreen.screenId);
        Get.snackbar('Success', 'Data is stored successfully');
      });
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('documentID', documentReference.id);
    } else {
      var collection = FirebaseFirestore.instance.collection('item_media');

      collection
          .doc(sharedPreferences.getString(
              'documentID')) // <-- Doc ID where data should be updated.
          .update({'link': url}).then((value) {
        sharedPreferences.setBool("isRecord_video", false);
        Navigator.of(context).pushNamed(AddDetailsScreen.screenId);
        Get.snackbar('Success', 'Data is stored successfully');
      });
    }
  }*/
}
