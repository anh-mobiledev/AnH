// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:pam_app/models/child_collection_sqlite.dart';
import 'package:pam_app/models/item_info_sqllite.dart';
import 'package:pam_app/models/parent_collection_sqlite.dart';
import 'package:pam_app/models/user_location.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item_image.dart';
import '../models/use_case.dart';
import '../models/user_info.dart';

class DBHelper {
//
  static Database? _db;

//Save item information
  static const String ITEM_IMG_TABLE = 'ItemImageTable';
  static const String ITEM_IMG_ID = 'id';
  static const String ITEM_IMAGE = 'item_image';
  static const String ITEM_IMAGE_CODE = 'item_code';
  static const String ITEM_IMAGE_UID = 'siteuser_id';

  //Save item information
  static const String ITEM_TABLE = 'ItemTable';
  static const String ITEM_ID = 'id';

  static const String ITEM_NAME = 'item_name';
  static const String ITEM_DESC = 'item_desc';
  static const String ITEM_CAT = 'item_category';
  static const String ITEM_YMM = 'item_ymm';
  static const String ITEM_KEYWORDS = 'item_keywords';
  static const String ITEM_CONDITION = 'item_condition';
  static const String ITEM_VALUE_TYPE = 'item_value_type';
  static const String ITEM_VALUE = 'item_value';
  static const String ITEM_STATUS = 'item_status';
  static const String ITEM_ADDITIONAL_OPTIONS = 'item_additional_options';
  static const String ITEM_IMG_CODE = 'item_img_code';
  static const String ITEM_UID = 'siteuser_id';

  //Save user information
  static const String USER_INFO_TABLE = 'UserInfoTable';
  static const String USER_ID = 'id';
  static const String SITE_USER_ID = 'siteuser_id';
  static const String USER_NAME = 'username';

  //Save USE CASE information
  static const String USE_CASE_TABLE = 'UseCaseTable';
  static const String USE_CASE_ID = 'id';
  static const String USE_CASE_VALUE = 'value';
  static const String USE_CASE_DESC = 'desc';
  static const String USE_CASE_USER_ID = 'siteuser_id';

  //Save USER LOCATION
  static const String LOCATION_TABLE = 'UseLocationTable';
  static const String LOC_ID = 'id';
  static const String LOC_NAME = 'name';
  static const String LAT_VAL = 'latitude_coord';
  static const String LONG_VAL = 'longitude_coord';
  static const String STREET_ADDR1 = 'street_addr1';
  static const String STREET_ADDR2 = 'street_addr2';
  static const String CITY = 'city';
  static const String STATE_PROV = 'state_prov';
  static const String COUNTRY = 'country';
  static const String LOC_USER_ID = 'siteuser_id';

  //Parent Collection
  static const String PARENT_COLLECTION_TABLE = 'ParentCollectionTable';
  static const String PARENT_COLLECTION_ID = 'id';
  static const String PARENT_COLLECTION_NAME = 'name';
  static const String PARENT_COLLECTION_DESC = 'desc';
  static const String PARENT_COLLECTION_ICON_CODE = 'icon_code';

  //Child Collection
  static const String CHILD_COLLECTION_TABLE = 'ChildCollectionTable';
  static const String CHILD_COLLECTION_ID = 'id';
  static const String CHILD_COLLECTION_NAME = 'name';
  static const String CHILD_COLLECTION_CURRENT_VALUE = 'current_value';
  static const String CHILD_COLLECTION_PARENT_ID = 'parent_id';

  static const String DB_NAME = 'AnH.db';
  late SharedPreferences sharedPreferences;

  Future<Database> get db async {
    if (null != _db) {
      return _db!;
    }
    _db = await initDB();
    return _db!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $ITEM_IMG_TABLE ($ITEM_IMG_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $ITEM_IMAGE TEXT, $ITEM_IMAGE_CODE TEXT, $ITEM_IMAGE_UID TEXT)');
    await db.execute(
        'CREATE TABLE $ITEM_TABLE ($ITEM_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $ITEM_NAME TEXT, $ITEM_DESC TEXT, $ITEM_CAT TEXT,$ITEM_YMM TEXT, $ITEM_KEYWORDS TEXT, $ITEM_CONDITION TEXT, $ITEM_VALUE_TYPE TEXT, $ITEM_VALUE TEXT, $ITEM_STATUS TEXT, $ITEM_ADDITIONAL_OPTIONS TEXT,  $ITEM_IMG_CODE TEXT, $ITEM_UID TEXT)');
    await db.execute(
        'CREATE TABLE $USER_INFO_TABLE ($USER_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $SITE_USER_ID TEXT, $USER_NAME TEXT)');
    await db.execute(
        'CREATE TABLE $USE_CASE_TABLE ($USE_CASE_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $USE_CASE_VALUE TEXT, $USE_CASE_DESC TEXT, $USE_CASE_USER_ID TEXT)');
    await db.execute(
        'CREATE TABLE $LOCATION_TABLE ($LOC_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $LOC_NAME TEXT, $LONG_VAL TEXT, $LAT_VAL TEXT, $STREET_ADDR1 TEXT, $STREET_ADDR2 TEXT, $CITY TEXT, $STATE_PROV TEXT, $COUNTRY TEXT, $LOC_USER_ID TEXT)');

    //PARENT COLLECTION
    await db.execute(
        'CREATE TABLE $PARENT_COLLECTION_TABLE ($PARENT_COLLECTION_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $PARENT_COLLECTION_NAME TEXT, $PARENT_COLLECTION_DESC TEXT, $PARENT_COLLECTION_ICON_CODE INTEGER)');

    //CHILD COLLECTION
    await db.execute(
        'CREATE TABLE $CHILD_COLLECTION_TABLE ($CHILD_COLLECTION_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $CHILD_COLLECTION_NAME TEXT, $CHILD_COLLECTION_CURRENT_VALUE DOUBLE, $CHILD_COLLECTION_PARENT_ID INTEGER)');
  }

  //-----------------------------SQLLITE INSERT ITEM INFO-----------------------------------
  Future<ItemImage> saveItemInfo(ItemImage itemInfo) async {
    var dbClient = await db;

    itemInfo.id = await dbClient.insert(ITEM_IMG_TABLE, itemInfo.toMap());

    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt('insertedId', itemInfo.item_code!);

    print(await sharedPreferences.getInt("insertedId"));

    return itemInfo;
  }

  Future<int> deleteItemImageById(int item_id) async {
    var dbClient = await db;
    print(item_id);
    final result = await dbClient
        .delete(ITEM_IMG_TABLE, where: "id = ?", whereArgs: [item_id]);
    print(result);
    return result;
  }

  // Image labeling using ML kit
  Future<int> insertItem_Image_Name(String imagePath, String imageName) async {
    var dbClient = await db;

    final data = {'item_image_path': imagePath, 'item_name': imageName};
    final result = await dbClient.insert(ITEM_TABLE, data);

    return result;
  }

  Future<int> insertItemCode(
      int item_img_code, String imageName, String imageDesc) async {
    var dbClient = await db;
    //int? item_img_code;

    //sharedPreferences = await SharedPreferences.getInstance();
    //item_img_code = await sharedPreferences.getInt("insertedId");

    print('update item image code method: $item_img_code');
    final data = {
      'item_img_code': item_img_code,
      'item_name': imageName,
      'item_desc': imageDesc
    };
    final result = await dbClient.insert(ITEM_TABLE, data);

    return result;
  }

  //-----------------------SQLLITE UPDATE ITEM NAME-----------------------------------------
  Future<int> updateItemName(String name, String description) async {
    var dbClient = await db;
    int? item_img_code;

    sharedPreferences = await SharedPreferences.getInstance();
    item_img_code = await sharedPreferences.getInt("insertedId");

    print('update item name method: $item_img_code');
    final data = {'item_name': name, 'item_desc': description};
    // final result = await dbClient.insert(ITEM_TABLE, data);

    final result = await dbClient.update(ITEM_TABLE, data,
        where: "item_img_code = ?", whereArgs: [item_img_code]);
    return result;
  }

  Future<int> updateItemNameById(
      String name, String description, int itemId) async {
    var dbClient = await db;

    print('update item name method: $itemId');
    final data = {'item_name': name, 'item_desc': description};
    final result = await dbClient
        .update(ITEM_TABLE, data, where: "id = ?", whereArgs: [itemId]);

    return result;
  }

  //---------------------------SQLLITE UPDATE ITEM INFO-------------------------------------
  Future<int> updateItemDetailsInfo(
      String category,
      String ymm,
      String keywords,
      String condition,
      String value_type,
      String value,
      String status,
      int item_code) async {
    var dbClient = await db;

    if (item_code == 0 || item_code == "") {
      sharedPreferences = await SharedPreferences.getInstance();
      item_code = (await sharedPreferences.getInt("insertedId"))!;
      print('update item details method: $item_code');
    }

    print('update item details method: $item_code');

    final data = {
      'item_category': category,
      'item_ymm': ymm,
      'item_keywords': keywords,
      'item_condition': condition,
      'item_value_type': value_type,
      'item_value': value,
      'item_status': status
    };
    final result = await dbClient.update(ITEM_TABLE, data,
        where: "item_img_code = ?", whereArgs: [item_code]);
    return result;
  }

//---------------------------SQLLITE UPDATE ITEM INFO-------------------------------------
  Future<int> updateItemAdditionalOptions(String value, int item_code) async {
    var dbClient = await db;

    if (item_code == 0 || item_code == "") {
      sharedPreferences = await SharedPreferences.getInstance();
      item_code = (await sharedPreferences.getInt("insertedId"))!;
      print('update item details method: $item_code');
    }

    print('update item additional option details method: $item_code');

    final data = {'item_additional_options': value};
    final result = await dbClient.update(ITEM_TABLE, data,
        where: "item_img_code = ?", whereArgs: [item_code]);
    return result;
  }

//Save the user information to the database
  Future<UserInfo> saveUserInfo(UserInfo userInfo) async {
    var dbClient = await db;
    print(userInfo.username);
    userInfo.id = await dbClient.insert(USER_INFO_TABLE, userInfo.toMap());
    print(userInfo.siteuser_id);
    return userInfo;
  }

  //Save the use case information to the database
  Future<UseCase> saveUseCase(UseCase useCase) async {
    var dbClient = await db;
    print(useCase.id);
    useCase.id = await dbClient.insert(USE_CASE_TABLE, useCase.toMap());
    print(useCase.siteuser_id);
    return useCase;
  }

//Save the user location information to the database
  Future<UserLocation> saveLocation(UserLocation userLocation) async {
    var dbClient = await db;
    print(userLocation.id);
    userLocation.id =
        await dbClient.insert(LOCATION_TABLE, userLocation.toMap());
    print(userLocation.siteuser_id);
    return userLocation;
  }

  Future<List<ItemImage>> getPhotos(int item_code) async {
    var dbClient = await db;

    if (item_code == 0) {
      sharedPreferences = await SharedPreferences.getInstance();
      item_code = (await sharedPreferences.getInt('insertedId'))!;
      print(item_code);
    }

    List<Map> maps = await dbClient.rawQuery(
        'SELECT id, $ITEM_IMAGE FROM $ITEM_IMG_TABLE WHERE item_code = ? ',
        [item_code]);

    List<ItemImage> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(ItemImage.fromMap(Map<String, dynamic>.from(maps[i])));
      }
    }
    print("photos {{$items}}");
    return items;
  }

  Future<List<ItemImage>> getItemPhotosByImgCode(String itemCode) async {
    var dbClient = await db;

    print(itemCode);

    List<Map> maps = await dbClient.rawQuery(
        'SELECT id, $ITEM_IMAGE FROM $ITEM_IMG_TABLE WHERE item_code = ? ',
        [itemCode]);

    List<ItemImage> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(ItemImage.fromMap(Map<String, dynamic>.from(maps[i])));
      }
    }
    print("photos {{$items}}");
    return items;
  }

  Future<List<ItemInfoSQLLite>> getItemsList() async {
    var dbClient = await db;

    List<Map> maps = await dbClient.rawQuery(
        'SELECT a.item_image, b.* FROM ItemImageTable a INNER JOIN ItemTable b ON a.item_code =  b.item_img_code GROUP BY a.item_code ');

    List<ItemInfoSQLLite> items = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        items.add(ItemInfoSQLLite.fromMap(Map<String, dynamic>.from(maps[i])));
      }
    }
    print("myitems {{$items}}");
    return items;
  }

  Future<ItemInfoSQLLite> getItemDetailById(int itemId) async {
    var dbClient = await db;

    final map = await dbClient.rawQuery(
        'SELECT a.item_image, b.* FROM ItemImageTable a INNER JOIN ItemTable b ON a.item_code = b.item_img_code AND b.id = ${itemId} GROUP BY a.item_code');

    ItemInfoSQLLite itemInfoSQLLite;
    if (map.isNotEmpty) {
      itemInfoSQLLite = ItemInfoSQLLite.fromMap(map.first);
    } else {
      throw new Exception("No item found...!");
    }
    return itemInfoSQLLite;
  }

  Future<int> insertParentCollection(
      String name, String desc, int iconCode) async {
    var dbClient = await db;

    final data = {'name': name, 'desc': desc, 'icon_code': iconCode};
    final result = await dbClient.insert(PARENT_COLLECTION_TABLE, data);

    return result;
  }

  Future<List<ParentCollectionSqlite>> getParentCollectionList() async {
    var dbClient = await db;

    List<Map> maps =
        await dbClient.rawQuery('SELECT * FROM ParentCollectionTable');

    List<ParentCollectionSqlite> parent_collections = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        parent_collections.add(
            ParentCollectionSqlite.fromMap(Map<String, dynamic>.from(maps[i])));
      }
    }
    print("parent collection {{$parent_collections}}");
    return parent_collections;
  }

  Future<int> insertChildCollection(
      String name, double currentValue, int parent_id) async {
    var dbClient = await db;

    final data = {
      'name': name,
      'current_value': currentValue,
      'parent_id': parent_id
    };
    final result = await dbClient.insert(CHILD_COLLECTION_TABLE, data);

    return result;
  }

  Future<int> updateParentCollectionById(
      String name, String description, int icon_code, int id) async {
    var dbClient = await db;

    print('update item name method: $id');

    final data = {'name': name, 'desc': description, 'icon_code': icon_code};

    final result = await dbClient.update(PARENT_COLLECTION_TABLE, data,
        where: "id = ?", whereArgs: [id]);

    return result;
  }

  Future<List<ChildCollectionSqlite>> getChildCollectionByParentId(
      int parent_id) async {
    var dbClient = await db;

    List<Map> maps = await dbClient.rawQuery(
        'SELECT * FROM ChildCollectionTable WHERE parent_id = ?', [parent_id]);

    List<ChildCollectionSqlite> child_collections = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        child_collections.add(
            ChildCollectionSqlite.fromMap(Map<String, dynamic>.from(maps[i])));
      }
    }
    print("parent collection {{$child_collections}}");
    return child_collections;
  }

  Future<ChildCollectionSqlite> getChildCollectionById(int id) async {
    var dbClient = await db;

    final map = await dbClient.rawQuery(
        'SELECT b.* FROM ChildCollectionTable a INNER JOIN ParentCollectionTable b ON a.id = b.parent_id AND b.id = ${id}');

    ChildCollectionSqlite itemInfoSQLLite;
    if (map.isNotEmpty) {
      itemInfoSQLLite = ChildCollectionSqlite.fromMap(map.first);
    } else {
      throw new Exception("No item found...!");
    }
    return itemInfoSQLLite;
  }

  Future<int> updateChildCollectionById(
      String name, String current_value, int id) async {
    var dbClient = await db;

    print('update child collection name method: $id');

    final data = {'name': name, 'current_value': current_value};

    final result = await dbClient
        .update(CHILD_COLLECTION_TABLE, data, where: "id = ?", whereArgs: [id]);

    return result;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
