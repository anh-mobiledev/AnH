import 'package:flutter/material.dart';
import 'package:pam_app/screens/addItem/add_item_images.dart';

import '../../components/camera_button_widget.dart';
import '../../components/gallery_button_widget.dart';
import '../../constants/colours.dart';

class SourcePage extends StatelessWidget {
  static const screenId = 'sourcepage_screen';
  const SourcePage({super.key});

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
            'Select source',
            style: TextStyle(color: AppColors.blackColor),
          ),
        ),
        body: ListView(
          children: [CameraButtonWidget(), GalleryButtonWidget()],
        ));
  }
}
