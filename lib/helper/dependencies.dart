import 'package:get/get.dart';
import 'package:pam_app/controllers/auth_controller.dart';
import 'package:pam_app/controllers/item_controller.dart';
import 'package:pam_app/controllers/managecontacts_controller.dart';
import 'package:pam_app/controllers/my_collections_controller.dart';
import 'package:pam_app/controllers/use_case_controller.dart';
import 'package:pam_app/data/repository/auth_repo.dart';
import 'package:pam_app/data/repository/item_details_repo.dart';
import 'package:pam_app/data/repository/manage_contact_repo.dart';
import 'package:pam_app/data/repository/my_collections_repo.dart';
import 'package:pam_app/data/repository/use_case_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_contants.dart';
import '../data/api/api_client.dart';

Future<void> init() async {
  //Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(apiBaseUrl: AppConstants.BASE_URL));

  //Repository
  Get.lazyPut(() => ManageContactsRepo(
      apiClient: Get.find(), sharedPreferences: sharedPreferences));
  Get.lazyPut(() =>
      AddItemRepo(apiClient: Get.find(), sharedPreferences: sharedPreferences));
  Get.lazyPut(() =>
      AuthRepo(apiClient: Get.find(), sharedPreferences: sharedPreferences));
  Get.lazyPut(() =>
      UseCaseRepo(apiClient: Get.find(), sharedPreferences: sharedPreferences));
  Get.lazyPut(() => MyCollectionsRepo(
      apiClient: Get.find(), sharedPreferences: sharedPreferences));

  //controllers
  Get.lazyPut(() => ManageContactController(contactsRepo: Get.find()));
  Get.lazyPut(() => ItemController(addItemRepo: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => UseCaseController(useCaseRepo: Get.find()));
  Get.lazyPut(() => MyCollectionsController(myCollectionsRepo: Get.find()));
}
