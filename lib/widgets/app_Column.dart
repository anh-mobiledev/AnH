import 'package:flutter/material.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/widgets/big_text.dart';
import 'package:pam_app/widgets/small_text.dart';

import '../constants/colours.dart';
import 'Icon_and_text.dart';

class AppColumn extends StatelessWidget {
  final String text;
  const AppColumn({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BigText(
          text: text,
          size: Dimensions.font26,
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        Row(
          children: [
            Wrap(
              children: List.generate(
                  5,
                  (index) => Icon(
                        Icons.star,
                        color: AppColors.primaryColor,
                        size: 15,
                      )),
            ),
            SizedBox(
              width: Dimensions.width10,
            ),
            SmallText(text: "4.5"),
            SizedBox(
              width: Dimensions.width10,
            ),
            SmallText(text: "1287"),
            SizedBox(
              width: Dimensions.width10,
            ),
            SmallText(text: "Comments"),
          ],
        ),
        SizedBox(
          height: Dimensions.height20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconAndText(
                icon: Icons.circle_sharp,
                iconText: "Normal",
                iconColor: AppColors.iconColor1),
            SizedBox(
              width: Dimensions.width10,
            ),
            IconAndText(
                icon: Icons.location_on,
                iconText: "1.7 km",
                iconColor: AppColors.primaryColor),
            SizedBox(
              width: Dimensions.width10,
            ),
            IconAndText(
                icon: Icons.timer_outlined,
                iconText: "32min",
                iconColor: AppColors.iconColor2),
            SizedBox(
              width: Dimensions.width10,
            ),
          ],
        )
      ],
    );
  }
}
