import 'package:get/get.dart';
import 'package:pam_app/models/new_account_body.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/data/api/api_client.dart';
import '../../constants/app_contants.dart';
import '../../helper/DBHelper.dart';
import '../../models/user_info.dart';
import '../../models/user_location.dart';

class AuthRepo extends GetxService {
  final ApiClient apiClient;
  SharedPreferences sharedPreferences;

  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<void> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeaders(token);
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(AppConstants.TOKEN, token);

    //print('auth_token: ${sharedPreferences.getString(AppConstants.TOKEN)}');
    // return await sharedPreferences.setString(AppConstants.TOKEN, token);
  }

  bool userLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.TOKEN);
  }

  Future<String> getAuthToken() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(AppConstants.TOKEN) ?? "";
  }

  Future<String> getUserId() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(AppConstants.UID) ?? "";
  }

  Future<Response> newAccount(NewAccountBody newAccountBody) async {
    return await apiClient.postData(
        AppConstants.NEW_ACCOUNT_URI, newAccountBody.toJson());
  }

  Future<Response> login(String username, String password) async {
    return await apiClient.postData(AppConstants.LOGIN_URI, {
      "result_as": "JSON",
      "siteuser": {"username": username, "password": password}
    });
  }

  /// Update the user location
  Future<Response> AddUserLocation(
      String token,
      String uid,
      String name,
      String lat,
      String long,
      String address,
      String city,
      String state,
      String country) async {
    return await apiClient.postData(AppConstants.ADD_LOC_URI, {
      "result_as": "JSON",
      "auth_token": token,
      "siteuser_id": uid,
      "location": {
        "name": name,
        "longitude_coord": long,
        "latitude_coord": lat,
        "street_addr1": address,
        "street_addr2": address,
        "city": city,
        "state_prov": state,
        "country": country
      }
    });
  }

  /// Add a new use case
  Future<Response> addUseCase(String userId, String value, String desc) async {
    return await apiClient.postData(AppConstants.ADD_USE_CASE_URI, {
      "result_as": "JSON",
      "user_id": userId,
      "usecase_val": value,
      "usecase_desc": desc
    });
  }

  Future<void> saveUserDetails(
    String username,
    String password,
    String deviceId,
    String uid,
  ) async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString(AppConstants.USERNAME, username);
      await sharedPreferences.setString(AppConstants.PASSWORD, password);

      await sharedPreferences.setString(AppConstants.UID, uid);
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveUserLocation(
    String longitude,
    String latitude,
  ) async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString(AppConstants.USER_LONGITUDE, longitude);
      await sharedPreferences.setString(AppConstants.USER_LATITUDE, latitude);
    } catch (e) {
      throw e;
    }
  }

  //Save user information into local storage
  Future<void> saveUserInfo_sqlliteDB(String siteuser_id) async {
    try {
      // print(siteuser_id);

      String? uname = await sharedPreferences.getString(AppConstants.USERNAME);
      //print(uname);

      DBHelper dbHelper = DBHelper();
      UserInfo userInfo = UserInfo(siteuser_id: siteuser_id, username: uname);
      dbHelper.saveUserInfo(userInfo);
    } catch (e) {
      throw e;
    }
  }

  //Save user location information into local storage
  Future<void> saveUserLocationInfo_sqlliteDB(
      String _name,
      String _longitude,
      String _latitude,
      String _address,
      String _city,
      String _state,
      String _country,
      String _siteuser_id) async {
    try {
      DBHelper dbHelper = DBHelper();
      UserLocation locInfo = UserLocation(
          name: _name,
          latitude_coord: _latitude,
          longitude_coord: _longitude,
          street_addr1: _address,
          street_addr2: "",
          city: _city,
          state_prov: _state,
          country: _country,
          siteuser_id: _siteuser_id);

      dbHelper.saveLocation(locInfo);
    } catch (e) {
      throw e;
    }
  }
}
