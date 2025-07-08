import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/constants/validators.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/controllers/item_controller.dart';
import 'package:pam_app/screens/addItem/howyouwanttodescribeit.dart';
import 'package:pam_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/alert.dart';
import '../../constants/colours.dart';

enum MediaType {
  image,
  video;
}

class UploadImageScreen extends StatefulWidget {
  static const screenId = 'uploadimage_screen';
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final ImagePicker imagePicker = ImagePicker();

  List<String> downloadUrls = [];

  List<File>? imageFiles = [];
  MediaType _mediaType = MediaType.image;
  String? imagePath;

  File? _cameraImage;
  bool uploading = false;
  double val = 0;
  //late CollectionReference imgRef;
  //late firebase_storage.Reference ref;
  late SharedPreferences sharedPreferences;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemNameController;
  late final FocusNode _itemNameNode;
  late final TextEditingController _descController;
  late final FocusNode _descNode;
  final _addFormKey = GlobalKey<FormState>();
  var itemController = Get.find<ItemController>();
// same channel and methodname.
  Dialogs alert = Dialogs();

  @override
  void initState() {
    super.initState();
    //imgRef = FirebaseFirestore.instance.collection('imageURLs');
    _itemNameController = TextEditingController();
    _itemNameNode = FocusNode();
    _descController = TextEditingController();
    _descNode = FocusNode();
  }

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
        // actions: [
        //   //actions widget in appbar
        //   TextButton(
        //       onPressed: () async {
        //         setState(() {
        //           uploading = true;
        //         });

        //         if (imageFiles!.length > 0) {
        //           uploadFiles().whenComplete(() => Navigator.of(context)
        //               .pushNamed(HowYouWantToDescribeItScreen.screenId));
        //         } else {
        //           uploading = false;
        //           Get.snackbar('Error', 'Please upload any images',
        //               backgroundColor: Colors.red);
        //         }
        //       },
        //       child: Text(
        //         'Next',
        //         style:
        //             TextStyle(fontSize: Dimensions.font20, color: blackColor),
        //       ))
        // ],
      ),
      body: _body(context),
    );
  }

  Widget _bottomNavigationBar(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: roundedButton(
            context: context,
            bgColor: AppColors.whiteColor,
            borderColor: AppColors.blackColor,
            textColor: AppColors.blackColor,
            text: 'Save and add more details',
            onPressed: () async {
              setState(() {
                uploading = true;
              });

              /* if (imageFiles!.length > 0) {
                uploadFiles().whenComplete(() => Navigator.of(context)
                    .pushNamed(HowYouWantToDescribeItScreen.screenId));
                if (_formKey.currentState!.validate()) {}
              } else {
                uploading = false;
                Get.snackbar('Error', 'Please upload any images',
                    backgroundColor: Colors.red);
              }*/

              Navigator.pushNamed(
                  context, HowYouWantToDescribeItScreen.screenId);
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
              sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setBool("skipbtn", false);

              Navigator.pushNamed(context, HomeScreen.screenId);
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  /*Future uploadFiles() async {
    int i = 1;

    for (var img in imageFiles!) {
      setState(() {
        val = i / imageFiles!.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/${Path.basename(img.path)}');
      await ref.putFile(img);
      final String downloadUrl = await ref.getDownloadURL();
      downloadUrls.add(downloadUrl);

      i++;
    }
    User? user = FirebaseAuth.instance.currentUser;
    /* FirebaseFirestore.instance.collection('item_images').add(
        {'imageUrlList': downloadUrls, 'user_id': user!.uid}).then((value) {
      Get.snackbar('Success', 'Data is stored successfully');
    });*/

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('item_media').doc();
    documentReference.set({
      'link': downloadUrls,
      'user_id': user!.uid,
      'item_id': documentReference.id
    }).then((value) {
      Get.snackbar('Success', 'Data is stored successfully');
    });
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('documentID', documentReference.id);
  }*/

  Widget _body(context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: imageFiles!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding:
                                EdgeInsets.only(left: 20, right: 20, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.file(
                                  File(imageFiles![index].path),
                                  fit: BoxFit.cover,
                                  height: 220,
                                ),
                                InkWell(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  onTap: () {
                                    imageFiles!.removeAt(index);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ),
                uploading
                    ? Center(
                        child: Container(
                          height: 400.0,
                          width: 120.0,
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
                              SizedBox(
                                height: 50.0,
                                width: 50.0,
                              ),
                              CircularProgressIndicator(
                                value: val,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
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
                ),
              )
            else
              InkWell(
                onTap: () async {
                  uploadToBoxApi();
                  //selectImages(ImageSource.camera);
                },
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Tooltip(
                      message: "Pick images",
                      child: Icon(Icons.photo_camera_rounded),
                    ),
                  ),
                ),
              ),

            /*Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey,
                      shadowColor: Colors.grey[400],
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      _mediaType = MediaType.video;
                      selectImages(ImageSource.camera);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          // Icon(
                          //   Icons.camera_alt,
                          //   size: 30,
                          //   color: Colors.red,
                          // ),
                          Text(
                            "Add photos to list",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),),*/
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
                      focusNode: _itemNameNode,
                      controller: _itemNameController,
                      validator: (value) {
                        return checkNullEmptyValidation(value, 'item name');
                      },
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
                    ),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    TextFormField(
                      focusNode: _descNode,
                      controller: _descController,
                      validator: (value) {
                        return checkNullEmptyValidation(value, 'item name');
                      },
                      keyboardType: TextInputType.name,
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

  Future<void> uploadToBoxApi() async {
    const MethodChannel _channel = const MethodChannel("BoxAPI/mychannel");
    final result = await _channel.invokeMethod('apicall');
    print("result from iOS native + Swift ${result}");
  }

  /*storeEntry(List<String> imageUrls, String name) {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('item_media')
        .add({'image': imageUrls, 'user_id': user!.uid}).then((value) {
      Get.snackbar('Success', 'Data is stored successfully');
    });
  }*/

  saveItem() async {
    if (_addFormKey.currentState!.validate()) {
      _addFormKey.currentState!.save();

      alert.showLoaderDialog(context);

      /* itemController
          .addItem(_itemNameController.text, _descController.text)
          .then((response) {
        if (response.success!) {

          Navigator.pop(context);
        }
      });*/
    }
  }
}
