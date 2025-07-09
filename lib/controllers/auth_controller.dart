import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pam_app/models/new_account_body.dart';

import '../data/repository/auth_repo.dart';
import '../models/new_account_response.dart';
import '../models/response_model.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  UserData userData = UserData();

  final storage = const FlutterSecureStorage();

  late String _locationId;
  String get locationId => _locationId;

  late String _userId;
  String get userId => _userId;

  AuthController({required this.authRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool userLoggedIn() {
    return authRepo.userLoggedIn();
  }

  Future<String> getUserId() {
    return authRepo.getUserId();
  }

  Future<ResponseModel> login(
      String username, String password, String deviceId) async {
    _isLoading = true;
    Response response = await authRepo.login(username, password);
    late ResponseModel responseModel;

    if (response.statusCode == 200) {
      if (response.body["success"] == true) {
        await storage.write(
            key: 'app_token', value: response.body['auth_token']);
        await storage.write(
            key: 'userId', value: response.body['data']['user_id']);

        // authRepo.saveUserToken(response.body["auth_token"].toString());

        // token = await authRepo.getAuthToken();
        //  print(token);

        /*  authRepo.saveUserDetails(
          username,
          password,
          deviceId,
          response.body["data"]["user_id"].toString(),
        );*/

        //  uid = await authRepo.getUserId();
        //  print(uid);

        //  print(response.body["data"]["user_id"].toString());

        //Local storage
        authRepo.saveUserInfo_sqlliteDB(
            response.body["data"]["user_id"].toString());

        responseModel = ResponseModel(true, response.body["auth_token"], "");
      } else {
        responseModel = ResponseModel(false, "", response.body["message"]);
        print(response.body["message"]);
      }
    } else {
      responseModel = ResponseModel(false, response.statusText!, "");
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<NewAccountResponse> newAccount(NewAccountBody newAccountBody) async {
    _isLoading = true;
    Response response = await authRepo.newAccount(newAccountBody);
    late NewAccountResponse responseModel;

    if (response.statusCode == 200) {
      print(response.body["data"]);

      await storage.write(key: 'app_token', value: response.body['auth_token']);

      /* authRepo.saveUserToken(response.body["auth_token"]);
      authRepo.saveUserDetails(response.body["data"]["username"], "", "",
          response.body["data"]["uid"]);*/

      responseModel = NewAccountResponse(
        success: true,
        authToken: response.body["auth_token"],
        message: response.body["message"],
      );
    } else {
      responseModel =
          NewAccountResponse(success: false, message: response.body["message"]);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> AddUserLocation(String name, String long, String lat,
      String address, String city, String state, String country) async {
    _isLoading = true;
    String uid;
    final appToken = await storage.read(key: 'app_token');
    uid = await this.getUserId();
    //print(token);
    //print(uid);
    Response response = await authRepo.AddUserLocation(
        appToken!, uid, name, long, lat, address, city, state, country);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      _locationId = response.body["location"];

      //authRepo.saveUserToken(response.body["auth_token"]);
      await storage.write(key: 'app_token', value: response.body["auth_token"]);

      responseModel = ResponseModel(
          true, response.body["auth_token"], response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText!, "");
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> insertUserLocationInfo_SQLLite(
      String name,
      String long,
      String lat,
      String address,
      String city,
      String state,
      String country) async {
    String uid = await this.getUserId();
    try {
      await authRepo.saveUserLocationInfo_sqlliteDB(
          name, long, lat, address, city, state, country, uid);
    } catch (e) {
      throw e;
    }
  }
}
