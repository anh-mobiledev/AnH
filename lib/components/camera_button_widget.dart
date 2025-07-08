import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pam_app/components/list_tile_widget.dart';

import '../models/media_source.dart';

class CameraButtonWidget extends StatelessWidget {
  const CameraButtonWidget({super.key});

  @override
  Widget build(BuildContext context) => ListTileWidget(
        text: 'From Camera',
        icon: Icons.camera_alt,
        onClicked: () => pickCameraMedia(context),
      );

  Future pickCameraMedia(BuildContext context) async {
    final source = ModalRoute.of(context)?.settings.arguments;

    final getMedia = source == MediaSource.image
        ? ImagePicker().pickImage(source: ImageSource.gallery)
        : ImagePicker().pickVideo(source: ImageSource.camera);

    final media = await getMedia;
    final file = File(media!.path);

    Navigator.of(context).pop(file);
  }
}
