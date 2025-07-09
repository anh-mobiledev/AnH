
import 'package:pam_app/models/contact_create_body.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_contants.dart';
import '../../models/contact_update_body.dart';
import '/data/api/api_client.dart';
import 'package:get/get.dart';

class ManageContactsRepo extends GetxService {
  final ApiClient apiClient;
  SharedPreferences sharedPreferences;
  ManageContactsRepo(
      {required this.apiClient, required this.sharedPreferences});

 

  //Contact Create
  Future<Response> contactCreate(ContactCreateBody ContactCreateBody) async {
    return await apiClient.postData(
        AppConstants.CONTACTS_CREATE_URI, ContactCreateBody.toJson());
  }

  //Contact Update
  Future<Response> contactUpdate(ContactUpdateBody contactUpdateBody) async {
    return await apiClient.postData(
        AppConstants.CONTACTS_UPDATE_URI, contactUpdateBody.toJson());
  }

}
