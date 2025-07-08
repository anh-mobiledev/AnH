import 'package:flutter/cupertino.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/widgets/small_text.dart';

class IconAndText extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String iconText;

  const IconAndText(
      {Key? key,
      required this.icon,
      required this.iconColor,
      required this.iconText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: Dimensions.iconSize24,
        ),
        SizedBox(width: 5),
        SmallText(text: iconText),
      ],
    );
  }
}
