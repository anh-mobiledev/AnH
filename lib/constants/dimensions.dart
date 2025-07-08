import 'package:get/get.dart';

class Dimensions {
  static double screenHeight = Get.context!.height;
  static double screenWidth = Get.context!.width;

  //topbanner
  static double pageView = screenHeight / 2.64;
  static double pageViewContainer = screenHeight / 3.84; //(844/220)
  static double pageViewTextContainer = screenHeight / 7.03; //(844/120)

  //font size
  static double font16 = screenHeight / 52.75;
  static double font20 = screenHeight / 42.2;
  static double font26 = screenHeight / 32.46;
  static double font40 = screenHeight / 21;
  static double font50 = screenHeight / 16.89;

  //radius
  static double radius15 = screenHeight / 56.27;
  static double radius20 = screenHeight / 42.2;
  static double radius30 = screenHeight / 28.13;

  //Height
  static double height10 = screenHeight / 84.4;
  static double height15 = screenHeight / 56.27;
  static double height20 = screenHeight / 42.2;
  static double height30 = screenHeight / 28.13;
  static double height45 = screenHeight / 18.75;
  static double height70 = screenHeight / 1.2;
  static double height120 = screenHeight / 7.033;
  static double height150 = screenHeight / 5.63;
  static double height200 = screenHeight / 4.22;

  //dynamic width padding and margin
  static double width10 = screenHeight / 84.4;
  static double width15 = screenHeight / 56.27;
  static double width20 = screenHeight / 42.2;
  static double width30 = screenHeight / 28.13;

  static double popularFoodImgSize = screenHeight;

  //dynamic icon size
  static double iconSize24 = screenHeight / 35.17;
  static double iconSize16 = screenHeight / 52.75;

  //bottom height
  static double bottomHeightBar = screenHeight / 7.03;
  static double welcomescreenlottieheight = screenHeight / 2.82;

  //list view size
  static double listViewImgSize = screenWidth / 3.25;
  static double listViewTextContSize = screenWidth / 3.9;

  //bottomheight
  static double bottomHeightbar = screenHeight / 7.03;
}
