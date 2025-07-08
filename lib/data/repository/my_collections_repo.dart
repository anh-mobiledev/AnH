import 'dart:convert';

import 'package:get/get.dart';
import 'package:pam_app/models/parent_collection_sqlite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_contants.dart';
import '../../helper/DBHelper.dart';
import '../../models/child_collection_sqlite.dart';
import '../api/api_client.dart';

class MyCollectionsRepo extends GetxService {
  final ApiClient apiClient;
  SharedPreferences sharedPreferences;

  MyCollectionsRepo({required this.apiClient, required this.sharedPreferences});

  //Collections list
  Future<Response> getCollectionsList(String token) async {
    return await apiClient.getData('${AppConstants.COLLECTIONS_LIST_URI}'
        '?result_as=JSON&auth_token=$token');
  }

  //Collection Create
  Future<Response> collectionCreate(
      String token, String name, String desc, String iconId) async {
    Map data = {
      'result_as': 'JSON',
      'auth_token': token,
      'collection': {'name': name, 'description': desc, 'icon_id': iconId}
    };

    // print(data);
    String body = jsonEncode(data);
    return await apiClient.postData(AppConstants.COLLECTION_CREATE_URI, body);
  }

  //Collection Items list
  Future<Response> getCollectionItemsList(
      String token, String collectionId) async {
    return await apiClient.getData('${AppConstants.COLLECTIOS_ITEM_LIST_URI}'
        '?result_as=JSON&auth_token=$token&collection_id=$collectionId');
  }

  //Collection Create
  Future<Response> collectionItemCreate(
      String token,
      String collectionId,
      String myItemIds,
      // List<String> myItemIds,
      String altDescription,
      String qty,
      String qtyUnits,
      String forSale,
      String forRent,
      String sharable) async {
    Map data = {
      'result_as': 'JSON',
      'auth_token': token,
      'collection_item': {
        'collection_id': collectionId,
        'myitem_id': myItemIds,
        'alt_description': altDescription,
        'qty': qty,
        'qty_units': qtyUnits,
        'for_sale': forSale,
        'for_rent': forRent,
        'sharable': sharable
      }
    };
    // print(data);
    String body = jsonEncode(data);

    return await apiClient.postData(
        AppConstants.COLLECTION_ITEM_CREATE_URI, body);
  }

  //GET /myitems list
  /* Future<Response> getmyItemsList(String token) async {
    return await apiClient.getData('${AppConstants.MYITEMS_LIST_URI}'
        '?result_as=JSON&auth_token=$token');
  }*/

  //--------------------------SQLLite Insert Parent collection--------------------------------------
  Future<int> insertParentCollectionSQLLiteDB(
      String name, String desc, int icon_code) async {
    try {
      DBHelper dbHelper = DBHelper();
      final result = dbHelper.insertParentCollection(name, desc, icon_code);
      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<int> insertChildCollectionSQLLiteDB(
      String name, double current_value, int parent_id) async {
    try {
      DBHelper dbHelper = DBHelper();
      final result =
          dbHelper.insertChildCollection(name, current_value, parent_id);
      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<List<ParentCollectionSqlite>> getParentCollectionList() async {
    try {
      DBHelper dbHelper = DBHelper();
      List<ParentCollectionSqlite> list = [];
      list = await dbHelper.getParentCollectionList();
      print("parent collection from repo {{$list}}");
      return list;
    } catch (e) {
      throw e;
    }
  }

  Future<List<ChildCollectionSqlite>> getChildCollectionListByParentId(
      int parent_id) async {
    try {
      DBHelper dbHelper = DBHelper();
      List<ChildCollectionSqlite> list = [];
      list = await dbHelper.getChildCollectionByParentId(parent_id);
      print("items images from repo {{$list}}");
      return list;
    } catch (e) {
      throw e;
    }
  }
}
