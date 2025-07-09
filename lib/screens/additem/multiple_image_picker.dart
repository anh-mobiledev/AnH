import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pam_app/screens/addItem/add_item_images.dart';

import '../../constants/colours.dart';

class MultipleImagePickerScreen extends StatefulWidget {
  static const screenId = 'imagepicker_screen';
  const MultipleImagePickerScreen({super.key});

  @override
  State<MultipleImagePickerScreen> createState() =>
      _MultipleImagePickerScreenState();
}

class _MultipleImagePickerScreenState extends State<MultipleImagePickerScreen> {
  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    print("Image List Length:" + imageFileList!.length.toString());
    setState(() {});
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
            Navigator.of(context).pushNamed(AddItemImagesScreen.screenId);
          },
        ),
        title: Text(
          'Pick images',
          style: TextStyle(color: AppColors.blackColor),
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  itemCount: imageFileList!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) {
                    return Image.file(
                      File(imageFileList![index].path),
                      fit: BoxFit.cover,
                    );
                  }),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              selectImages();
            },
            child: Text('Select Images'),
          ),
        ],
      ),
    );
  }
}
