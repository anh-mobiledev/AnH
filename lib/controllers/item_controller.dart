import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pam_app/controllers/auth_controller.dart';
import 'package:pam_app/models/delete_myitem_failure_response.dart';
import 'package:pam_app/models/item_details_create_body.dart';
import 'package:pam_app/models/item_image.dart';
import 'package:pam_app/models/item_info_sqllite.dart';
import 'package:pam_app/models/my_items_by_id_server_model.dart';
import 'package:pam_app/models/response_model.dart';
import 'package:pam_app/services/auth.dart';

import '../data/repository/item_details_repo.dart';
import '../models/attachments_list.dart';
import '../models/my_items_server_model.dart';

class ItemController extends GetxController {
  final AddItemRepo addItemRepo;
  final storage = const FlutterSecureStorage();
  Auth authService = Auth();

  ItemController({required this.addItemRepo});
  List<ItemImage> _itemImagesList = [];
  List<ItemImage> get itemImagesList => _itemImagesList;

  List<ItemInfoSQLLite> _myItemsIndexList = [];
  List<ItemInfoSQLLite> get myItemsIndexList => _myItemsIndexList;

  List<MyItemsServerModel> _myItemsIndexListServer = [];
  List<MyItemsServerModel> get myItemsIndexListServer =>
      _myItemsIndexListServer;

  MyItemByIdServerModel? _myItemByIdServer;
  MyItemByIdServerModel? get myItemByIdServer => _myItemByIdServer!;

  List<MyitemImgsModel> _myItemAttachmentsListIndexServer = [];
  List<MyitemImgsModel> get myItemAttachmentsListIndexServer =>
      _myItemAttachmentsListIndexServer;

  List<ReferenceCollections> _refCollections = [];
  List<ReferenceCollections> get refCollections => _refCollections;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  late String _itemId;
  String get finId => _itemId;

  late String _attachment_id;
  String get attachment_id => _attachment_id;

  late String _myItemId;
  String get myItemId => _myItemId;

  var authController = Get.find<AuthController>();

  static Future<String?> getFirebaseToken() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    return await _auth.currentUser?.getIdToken();
  }

  static String? getFirebaseUid() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    return _auth.currentUser?.uid;
  }

//Create Edit ADDDETAILS

  Future<ResponseModel> AddDetails(ItemDetailsCreateBody addeditBody) async {
    Response response = await addItemRepo.addDetails(addeditBody);

    late ResponseModel responseModel;

    if (response.statusCode == 200) {
      _itemId = response.body["item_id"];

      print(_itemId);

      await storage.write(key: 'app_token', value: response.body["auth_token"]);

      //addItemRepo.saveUserToken(response.body["auth_token"]);

      responseModel = ResponseModel(
          true, response.body["auth_token"], response.body['message']);

      _isLoaded = true;
      update();
    } else {
      responseModel = ResponseModel(
          false, response.body["auth_token"], response.body['message']);
      _isLoaded = false;
    }

    return responseModel;
  }

  Future<void> insertItem_Image_Name(String imagePath, String name) {
    return addItemRepo.insertItem_Image_Name_SQLLiteDB(imagePath, name);
  }

  Future<void> insertItemImageCode(
      int item_img_code, String imageName, String imageDesc) {
    return addItemRepo.insertItemImageCodeSQLLiteDB(
        item_img_code, imageName, imageDesc);
  }

  Future<void> updateItemName(String item_name, String item_desc) {
    return addItemRepo.UpdateItemNameSQLLiteDB(item_name, item_desc);
  }

  Future<void> updateItemNameById(
      String item_name, String item_desc, int item_id) {
    return addItemRepo.UpdateItemNameById(item_name, item_desc, item_id);
  }

  Future<void> updateItemDetails_SQLLite(
      String item_category,
      String item_ymm,
      String item_keywords,
      String item_conditions,
      String item_value_type,
      String item_value,
      String item_status,
      int item_code) {
    return addItemRepo.updateItemDetailsSQLLiteDB(
        item_category,
        item_ymm,
        item_keywords,
        item_conditions,
        item_value_type,
        item_value,
        item_status,
        item_code);
  }

  Future<void> updateItemAdditionalOptions_SQLLite(
      String item_value, int item_code) {
    return addItemRepo.updateItemAdditionalOptionsSQLLiteDB(
        item_value, item_code);
  }

  //MyItem primary image upload.
  Future<ResponseModel> addMyItemPrimaryImage(
      String name, String description, File file) async {
    //App token
    final appToken = await storage.read(key: 'app_token');

    String? token;

    //Firebase token
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    dynamic response = await addItemRepo.addMyItemPrimaryImage(
        token!, name, description, file);

    print("myitem resposne ${response}");

    late ResponseModel responseModel;

    if (response['success']) {
      _myItemId = response["myitem"][0]["id"];
      print(_myItemId);

      await storage.write(key: 'myItemId', value: response["myitem"][0]["id"]);
      //print(response["auth_token"]);

      //  addItemRepo.saveUserToken(response["auth_token"]);
      await storage.write(key: 'app_token', value: response["auth_token"]);

      responseModel =
          ResponseModel(true, response["auth_token"], response["message"]);

      _isLoaded = true;
      update();
    } else {
      _isLoaded = false;
      responseModel =
          ResponseModel(false, response["auth_token"], response["message"]);
    }

    return responseModel;
  }

  //MyItem more images upload as attachments
  Future<ResponseModel> addMyItemMediaAsAttachment(String item_id,
      int fileFormat, String contentType, String isHidden, File file) async {
    final appToken = await storage.read(key: 'app_token');

    String? token;

    //Firebase token
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    dynamic response = await addItemRepo.addMyItemMediaAsAttachment(
        token!, item_id, fileFormat, contentType, isHidden, file);

    print("myitem resposne ${response}");

    late ResponseModel responseModel;

    if (response['success']) {
      _attachment_id = response["attachment_id"];

      print(response["auth_token"]);

      await storage.write(key: 'app_token', value: response["auth_token"]);

      //addItemRepo.saveUserToken(response["auth_token"]);

      responseModel =
          ResponseModel(true, response["auth_token"], response["message"]);
      _isLoaded = true;
      update();
    } else {
      _isLoaded = false;
      responseModel = ResponseModel(false, response["messge"], "");
    }

    return responseModel;
  }

  // MyItems list
  Future<void> getMyItemsListServer() async {
    try {
      final appToken = await storage.read(key: 'app_token');
      final userId = await storage.read(key: 'user_id');

      String? token;

      //Firebase token
      if (appToken == null) {
        String? fbIdToken = await Auth.getIdToken();
        String? fbUserId = await Auth.getUid();

        authController
            .verifyFirebaseIdTokenController(fbIdToken!, fbUserId!)
            .then((result) {
          if (result.isSuccess) {
            token = result.authToken;
          }
        });
      } else {
        token = appToken;
      }

      Response response = await addItemRepo.getMyItemsListServer(token!);

      print('status code ${response.statusCode}');
      print('status text ${response.statusText}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);

        await storage.write(
            key: 'app_token', value: response.body["auth_token"]);

        //  addItemRepo.saveUserToken(response.body['auth_token']);

        _myItemsIndexListServer = [];
        _myItemsIndexListServer
            .addAll(MyItemsServer.fromJson(response.body).myItems);
        _isLoaded = true;
        update();
      } else {
        _isLoaded = false;
        _myItemsIndexListServer = [];
      }
    } catch (e) {
      throw e;
    }
  }

// MyItems list
  Future<void> getMyItemById(String itemId) async {
    try {
      //App token
      final appToken = await storage.read(key: 'app_token');

      String? token;

      //Firebase token
      if (appToken == null) {
        token = await Auth.getIdToken();
      } else {
        token = appToken;
      }

      //  print('getMyItemsListServer ==> ${token}');

      Response response = await addItemRepo.getMyItemById(token!, itemId);

      print('status code ${response.statusCode}');

      print('status text ${response.statusText}');

      print('getMyItemById::${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('getMyItemById::${response.body}');

        //addItemRepo.saveUserToken(response.body['auth_token']);

        _myItemByIdServer = MyItemByIdServer.fromJson(response.body).myItem;
        _isLoaded = true;
        update();
      } else {
        _isLoaded = false;
      }
    } catch (e) {
      throw e;
    }
  }

  //MyItem attachmensts list
  Future<void> getMyItemsAttachmentsController(String myitem_id) async {
    final appToken = await storage.read(key: 'app_token');

    String? token;
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    print('auth token: ${token} itemId: ${myitem_id}');

    try {
      Response response =
          await addItemRepo.getMyItemsAttachmentsRepo(token!, myitem_id);

      print('attachments response :: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        //addItemRepo.saveUserToken(response.body['auth_token']);
        await storage.write(
            key: 'app_token', value: response.body["auth_token"]);

        _myItemAttachmentsListIndexServer = [];
        _myItemAttachmentsListIndexServer
            .addAll(MyItemAttachmentsList.fromJson(response.body).myitemImgs);
        _isLoaded = true;
        update();
      } else {
        _isLoaded = false;
        _myItemAttachmentsListIndexServer = [];
      }
    } catch (e) {
      throw e;
    }
  }

  // Update MyItem
  Future<ResponseModel> updateMyItem(
      String id,
      String name,
      String desc,
      String value_type,
      String value_amt,
      String value_units,
      String status,
      String condition,
      String keywords) async {
    // token = await this.getAuthToken();
    // siteuser_id = await this.getUserId();

    //App token
    final appToken = await storage.read(key: 'app_token');
    final user_Id = await storage.read(key: 'userId');

    String? token, userId;

    //Firebase token
    if (appToken == null && user_Id == null) {
      token = await Auth.getIdToken();
      userId = Auth.getUid();
    } else {
      token = appToken;
      userId = user_Id;
    }

    Response response = await addItemRepo.updateMyItem(
        token!,
        userId!,
        id,
        name,
        desc,
        value_type,
        value_amt,
        value_units,
        status,
        condition,
        keywords);
    late ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      await storage.write(key: 'app_token', value: response.body["auth_token"]);

      //addItemRepo.saveUserToken(response.body["auth_token"]);

      responseModel = ResponseModel(
          true, response.body["auth_token"], response.body["message"]);
      _isLoaded = true;
      update();
    } else {
      responseModel = ResponseModel(false, response.statusText!, "");
      _isLoaded = false;
    }

    return responseModel;
  }

  Future<ResponseModel> deleteMyitemController(String myItemId) async {
    //App token
    final appToken = await storage.read(key: 'app_token');
    String? token;

    //Firebase token
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    print('myItemId${myItemId}');

    String responseString =
        await addItemRepo.deleteMyItemRepo(myItemId, token!);

    Map<String, dynamic> jsonObject = jsonDecode(responseString);

    late ResponseModel responseModel;

    if (jsonObject['success'] == true) {
      await storage.write(key: 'app_token', value: jsonObject['auth_token']);

      responseModel =
          ResponseModel(true, jsonObject['auth_token'], jsonObject['message']);

      _isLoaded = true;

      update();
    } else {
      await storage.write(key: 'app_token', value: jsonObject['auth_token']);
      responseModel = ResponseModel(false, "", jsonObject['message']);

      _refCollections = [];
      _refCollections.addAll(
          DeleteMyItemFailureResponse.fromJson(jsonObject).refCollections!);

      _isLoaded = true;
      update();
    }

    return responseModel;
  }

  Future<void> insertItemImageSQLLite(String itemImage, int itemCode) async {
    try {
      await addItemRepo.saveItemImageSQLLiteDB(itemImage, itemCode);
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteItemImageById_SQLLite(int item_id) async {
    try {
      await addItemRepo.deleteItemImageById_SQLLite(item_id);
    } catch (e) {
      throw e;
    }
  }

  Future<List<ItemInfoSQLLite>> getMyitemsListSQLite() async {
    try {
      _myItemsIndexList = [];

      _myItemsIndexList.addAll(await addItemRepo.getMyItemsListSQLite());
      _isLoaded = true;
      update();
      return _myItemsIndexList;
    } catch (e) {
      throw e;
    }
  }
}
