import 'package:get/get.dart';
import 'package:pam_app/models/use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_contants.dart';
import '../../helper/DBHelper.dart';
import '../api/api_client.dart';

class UseCaseRepo extends GetxService {
  final ApiClient apiClient;
  SharedPreferences sharedPreferences;

  UseCaseRepo({required this.apiClient, required this.sharedPreferences});

  Future<String> getUserId() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(AppConstants.UID) ?? "";
  }
  
  //--------------------------SQLLite insert USE CASE --------------------------------------
  Future<bool> SaveUseCaseSQLLiteDB(String value, String desc) async {
    try {
      String siteuser_id = await this.getUserId();
      DBHelper dbHelper = DBHelper();
      UseCase useCaseInfo = UseCase(value: value, desc: desc, siteuser_id: siteuser_id);
      dbHelper.saveUseCase(useCaseInfo);
      return true;
    } catch (e) {
      throw e;
    }
  }
}
