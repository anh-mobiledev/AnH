import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pam_app/models/item_details_create_body.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_contants.dart';
import '../../helper/DBHelper.dart';
import '../../models/item_image.dart';
import '../../models/item_info_sqllite.dart';
import '../api/api_client.dart';

class AddItemRepo extends GetxService {
  final ApiClient apiClient;
  SharedPreferences sharedPreferences;
  final storage = const FlutterSecureStorage();

  AddItemRepo({required this.apiClient, required this.sharedPreferences});

  Future<String> getUserId() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(AppConstants.UID) ?? "";
  }

  //AddDateils Create, Edit
  Future<Response> addDetails(ItemDetailsCreateBody addEditBody) async {
    return await apiClient.postData(
        AppConstants.ADD_DETAILS_CREATE_URI, addEditBody.toJson());
  }

  //Add primary image
  Future<dynamic> addMyItemPrimaryImage(
      String token, String name, String desc, File primary_image) async {
    return await apiClient.addMyItemPrimaryImage(
        "https://anh.jarrettsvillesoccer.com" + AppConstants.ADD_ITEM_URI,
        token,
        name,
        desc,
        primary_image);
  }

  // Add MyItems attachments
  Future<dynamic> addMyItemMediaAsAttachment(String token, String item_id,
      int fileFormat, String contentType, String isHidden, File image) async {
    return await apiClient.addAttachments(
        "https://anh.jarrettsvillesoccer.com" + AppConstants.ADD_ITEM_ATTCH_URI,
        token,
        item_id,
        fileFormat,
        contentType,
        isHidden,
        image);
  }

  //Update the myitem
  Future<Response> updateMyItem(
      String token,
      String siteruser_id,
      String id,
      String name,
      String desc,
      String value_type,
      String value_amt,
      String value_units,
      String status,
      String condition,
      String keywords) async {
    return await apiClient.patchData(
      AppConstants.EDIT_ITEM_URI + '${id}.json',
      {
        "result_as": "JSON",
        "auth_token": token,
        "siteuser_id": siteruser_id,
        "myitem": {
          "id": id,
          "siteuser_id": siteruser_id,
          "name": name,
          "description": desc,
          "value_type": value_type,
          "value_amt": value_amt,
          "value_units": value_units,
          "status": status,
          "condition": condition,
          "keywords": keywords
        }
      },
    );
  }

  Future<String> deleteMyItemRepo(String myItemId, String token) async {
    return await apiClient.deleteWithBody(
        AppConstants.BASE_URL + AppConstants.DEL_ITEM_URI + '${myItemId}',
        {'result_as': 'JSON', 'auth_token': token});
  }

  //--------------------------SQLLite UPDATE item name--------------------------------------
  Future<bool> insertItem_Image_Name_SQLLiteDB(
      String imagePath, String imageName) async {
    try {
      DBHelper dbHelper = DBHelper();
      dbHelper.insertItem_Image_Name(imagePath, imageName);
      return true;
    } catch (e) {
      throw e;
    }
  }

  //--------------------------SQLLite UPDATE item name--------------------------------------
  Future<bool> insertItemImageCodeSQLLiteDB(
      int item_img_code, String imageName, String imageDesc) async {
    try {
      DBHelper dbHelper = DBHelper();
      dbHelper.insertItemCode(item_img_code, imageName, imageDesc);
      return true;
    } catch (e) {
      throw e;
    }
  }

  //--------------------------SQLLite UPDATE item name--------------------------------------
  Future<bool> UpdateItemNameSQLLiteDB(
      String item_name, String item_desc) async {
    try {
      DBHelper dbHelper = DBHelper();
      dbHelper.updateItemName(item_name, item_desc);
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> UpdateItemNameById(
      String item_name, String item_desc, int item_id) async {
    try {
      DBHelper dbHelper = DBHelper();
      dbHelper.updateItemNameById(item_name, item_desc, item_id);
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateItemDetailsSQLLiteDB(
      String category,
      String ymm,
      String keywords,
      String condition,
      String value_type,
      String value,
      String status,
      int item_code) async {
    try {
      DBHelper dbHelper = DBHelper();

      dbHelper.updateItemDetailsInfo(category, ymm, keywords, condition,
          value_type, value, status, item_code);
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateItemAdditionalOptionsSQLLiteDB(
      String value, int item_code) async {
    try {
      DBHelper dbHelper = DBHelper();

      dbHelper.updateItemAdditionalOptions(value, item_code);
    } catch (e) {
      throw e;
    }
  }

  Future<bool> saveItemImageSQLLiteDB(String itemImage, int itemCode) async {
    try {
      String siteuserId = await this.getUserId();
      DBHelper dbHelper = DBHelper();
      ItemImage item_mage = ItemImage(
          item_image: itemImage, item_code: itemCode, siteuser_id: siteuserId);
      dbHelper.saveItemInfo(item_mage);
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteItemImageById_SQLLite(int item_id) async {
    try {
      DBHelper dbHelper = DBHelper();

      dbHelper.deleteItemImageById(item_id);
    } catch (e) {
      throw e;
    }
  }

  Future<List<ItemImage>> getItemsList() async {
    try {
      DBHelper dbHelper = DBHelper();
      List<ItemImage> list = [];
      list = await dbHelper.getPhotos(0);
      print("items images from repo {{$list}}");
      return list;
    } catch (e) {
      throw e;
    }
  }

  Future<List<ItemInfoSQLLite>> getMyItemsListSQLite() async {
    try {
      DBHelper dbHelper = new DBHelper();
      List<ItemInfoSQLLite> myItemslist = [];
      myItemslist = await dbHelper.getItemsList();
      return myItemslist;
    } catch (e) {
      throw e;
    }
  }

  //GET /myitems list
  Future<Response> getMyItemsListServer(String token) async {
    return await apiClient.getData('${AppConstants.MYITEMS_LIST_URI}'
        '?result_as=JSON&auth_token=$token');
  }

  //GET /myitems list
  Future<Response> getMyItemById(String token, String itemId) async {
    return await apiClient
        .getData('${AppConstants.MYITEMS_LIST_URI + '/${itemId}'}'
            '?result_as=JSON&auth_token=$token');
  }

  //GET /attachments
  Future<Response> getMyItemsAttachmentsRepo(
      String token, String myitem_id) async {
    return await apiClient.getData(
        '${AppConstants.MYITEMS_ATTACHMENTS_LIST_URI}'
        '?result_as=JSON&auth_token=$token&myitem_id=$myitem_id&order=item_images_toc_asc');
  }
}
