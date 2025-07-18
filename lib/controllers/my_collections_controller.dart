import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pam_app/data/repository/my_collections_repo.dart';
import 'package:pam_app/models/my_collections_server_model.dart';
import 'package:pam_app/services/auth.dart';

import '../models/child_collection_sqlite.dart';
import '../models/collection_items_server_model.dart';
import '../models/my_items_server_model.dart';
import '../models/parent_collection_sqlite.dart';
import '../models/response_model.dart';

class MyCollectionsController extends GetxController {
  final MyCollectionsRepo myCollectionsRepo;
  final storage = const FlutterSecureStorage();

  MyCollectionsController({required this.myCollectionsRepo});

  // List<dynamic> _myCollectionsIndexList = [];
  // List<dynamic> get myCollectionsIndexList => _myCollectionsIndexList;

  List<CollectionsServerModel> _myCollectionsIndexList = [];
  List<CollectionsServerModel> get myCollectionsIndexList =>
      _myCollectionsIndexList;

  List<CollectionItemsModel> _myCollectionItemsIndexList = [];
  List<CollectionItemsModel> get myCollectionItemsIndexList =>
      _myCollectionItemsIndexList;

  List<MyItemsServerModel> _myItemsIndexList = [];
  List<MyItemsServerModel> get myItemsIndexList => _myItemsIndexList;

  List<ParentCollectionSqlite> _parentCollectionsIndexList = [];
  List<ParentCollectionSqlite> get parentCollectionsIndexList =>
      _parentCollectionsIndexList;

  List<ChildCollectionSqlite> _childCollectionsIndexList = [];
  List<ChildCollectionSqlite> get childCollectionsIndexList =>
      _childCollectionsIndexList;

  var jsonData;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/collections_list.json');
    final data = await json.decode(response);
    jsonData = data['collections'];
    print(jsonData);
    _myCollectionsIndexList = [];
    _myCollectionsIndexList.addAll(jsonData);
    _isLoaded = true;
    update();
  }

  Future<void> getCollectionsList() async {
    //App token
    final appToken = await storage.read(key: 'app_token');

    String? token;

    //Firebase token
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    Response response = await myCollectionsRepo.getCollectionsList(token!);

    print('status code ${response.statusCode}');
    print('status text ${response.statusText}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.body);

      await storage.write(key: 'app_token', value: response.body["auth_token"]);

      //myCollectionsRepo.saveUserToken(response.body['auth_token']);
      _myCollectionsIndexList = [];
      _myCollectionsIndexList
          .addAll(MyCollectionsServer.fromJson(response.body).collections);
      _isLoaded = true;
      update();
    } else {
      _isLoaded = false;
      _myCollectionsIndexList = [];
    }
  }

  Future<ResponseModel> collectionCreate(
      String name, String desc, String iconId) async {
    //App token
    final appToken = await storage.read(key: 'app_token');

    String? token;

    //Firebase token
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    Response response =
        await myCollectionsRepo.collectionCreate(token!, name, desc, iconId);

    print('status code ${response.statusCode}');
    print('status text ${response.statusText}');
    late ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.body);

      if (response.body["success"] == true) {
        await storage.write(
            key: 'app_token', value: response.body["auth_token"]);

        //myCollectionsRepo.saveUserToken(response.body["auth_token"]);

        responseModel = ResponseModel(
            true, response.body["auth_token"], response.body["message"]);
      }
    } else {
      responseModel = ResponseModel(false, "", response.statusText!);
    }

    update();
    return responseModel;
  }

  Future<void> getCollectionItemsList(String collectionId) async {
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

      Response response =
          await myCollectionsRepo.getCollectionItemsList(token!, collectionId);
      print('status code ${response.statusCode}');
      print('status text ${response.statusText}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);

        await storage.write(
            key: 'app_token', value: response.body["auth_token"]);

        //  myCollectionsRepo.saveUserToken(response.body['auth_token']);

        _myCollectionItemsIndexList = [];
        _myCollectionItemsIndexList.addAll(
            CollectionItemsServer.fromJson(response.body).collectionItems);
        if (_myCollectionItemsIndexList.length == 0) {
          _isLoaded = false;
          _myCollectionItemsIndexList = [];
        } else {
          _isLoaded = true;
        }
        update();
      } else {
        _isLoaded = false;
        _myCollectionItemsIndexList = [];
      }
    } catch (e) {
      throw e;
    }
  }

  Future<ResponseModel> collectionItemCreate(
      String collectionId,
      String myItemIds,
      //List<String> myItemIds,
      String altDescription,
      String qty,
      String qtyUnits,
      String forSale,
      String forRent,
      String sharable) async {
    //App token
    final appToken = await storage.read(key: 'app_token');

    String? token;

    //Firebase token
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    Response response = await myCollectionsRepo.collectionItemCreate(
        token!,
        collectionId,
        myItemIds,
        altDescription,
        qty,
        qtyUnits,
        forSale,
        forRent,
        sharable);
    print('status code ${response.statusCode}');
    print('status text ${response.statusText}');
    late ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      await storage.write(key: 'app_token', value: response.body["auth_token"]);

      //    myCollectionsRepo.saveUserToken(response.body["auth_token"]);
      responseModel = ResponseModel(
          true, response.body["auth_token"], response.body["message"]);
    } else {
      responseModel = ResponseModel(false, "", response.statusText!);
    }

    update();
    return responseModel;
  }

  Future<ResponseModel> deleteCollectionController(String collectionId) async {
    //App token
    final appToken = await storage.read(key: 'app_token');
    String? token;

    //Firebase token
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    String responseString =
        await myCollectionsRepo.deleteCollectionRepo(collectionId, token!);

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

      _isLoaded = false;
    }

    return responseModel;
  }

  Future<ResponseModel> deleteCollectionItemController(
      int collectionItemId, String collectionId) async {
    //App token
    final appToken = await storage.read(key: 'app_token');
    String? token;

    //Firebase token
    if (appToken == null) {
      token = await Auth.getIdToken();
    } else {
      token = appToken;
    }

    String responseString = await myCollectionsRepo.deleteCollectionItemRepo(
        collectionItemId, collectionId, token!);

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

      _isLoaded = false;
    }

    return responseModel;
  }

  /* Future<void> getmyItemsList(String token) async {
    try {
      Response response = await myCollectionsRepo.getmyItemsList(token);
      print('status code ${response.statusCode}');
      print('status text ${response.statusText}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
        myCollectionsRepo.saveUserToken(response.body['auth_token']);

        _myItemsIndexList = [];
        _myItemsIndexList.addAll(MyItemsServer.fromJson(response.body).myItems);
        _isLoaded = true;
        update();
      } else {
        _isLoaded = false;
        _myItemsIndexList = [];
      }
    } catch (e) {
      throw e;
    }
  }*/

  Future<int> insertParentCollection(String name, String desc, int icon_code) {
    return myCollectionsRepo.insertParentCollectionSQLLiteDB(
        name, desc, icon_code);
  }

  Future<int> insertChildCollection(
      String name, double current_value, int parent_id) {
    return myCollectionsRepo.insertChildCollectionSQLLiteDB(
        name, current_value, parent_id);
  }

  Future<List<ParentCollectionSqlite>> getParentCollectionList() async {
    try {
      _parentCollectionsIndexList = [];

      _parentCollectionsIndexList
          .addAll(await myCollectionsRepo.getParentCollectionList());
      _isLoaded = true;
      update();
      return _parentCollectionsIndexList;
    } catch (e) {
      throw e;
    }
  }

  Future<List<ChildCollectionSqlite>> getChildCollectionList(
      int parent_id) async {
    try {
      _childCollectionsIndexList = [];
      _childCollectionsIndexList =
          await myCollectionsRepo.getChildCollectionListByParentId(parent_id);
      _isLoaded = true;
      update();
      return _childCollectionsIndexList;
    } catch (e) {
      throw e;
    }
  }
}
