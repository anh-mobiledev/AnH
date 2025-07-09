import 'package:flutter/material.dart';

import '../../forms/howyouwanttodescribeit_form.dart';

class HowYouWantToDescribeItScreen extends StatelessWidget {
  static const String screenId = 'howyouwanttodescribeit_screen';
  const HowYouWantToDescribeItScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HowYouWantToDescribeItForm();
  }
}
