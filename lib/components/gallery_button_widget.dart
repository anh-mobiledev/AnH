import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pam_app/components/list_tile_widget.dart';

import '../models/media_source.dart';

class GalleryButtonWidget extends StatefulWidget {
  const GalleryButtonWidget({super.key});

  @override
  State<GalleryButtonWidget> createState() => _GalleryButtonWidgetState();
}

class _GalleryButtonWidgetState extends State<GalleryButtonWidget> {
  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  @override
  Widget build(BuildContext context) => ListTileWidget(
      text: 'From Gallery',
      icon: Icons.photo,
      onClicked: () => pickGalleryMedia(context));

  Future pickGalleryMedia(BuildContext context) async {
    final source = ModalRoute.of(context)?.settings.arguments;

    final getMedia = source == MediaSource.image
        ? ImagePicker().pickImage(source: ImageSource.gallery)
        : ImagePicker().pickVideo(source: ImageSource.camera);

    final media = await getMedia;
    final file = File(media!.path);

    Navigator.of(context).pop(file);
  }

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    print("Image List Length:" + imageFileList!.length.toString());
    setState(() {});
  }
}
