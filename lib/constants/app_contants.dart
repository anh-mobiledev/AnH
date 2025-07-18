class AppConstants {
  static const String APP_NAME = "Assets and Heirloom";
  static const String BASE_URL =
      "https://anh.jarrettsvillesoccer.com"; //"http://34.209.90.79";
  static const String TOKEN = "DBtoken";
  static const String USERNAME = "username";
  static const String PASSWORD = "password";

  static const String UID = "user_id";

  static const String USER_LONGITUDE = "longituude";
  static const String USER_LATITUDE = "latitude";

//Login
  static const String LOGIN_URI = "/siteusers/sign_in";
  static const String LOGOUT_URI = "/siteusers/sign_out";

//New Account
  static const String NEW_ACCOUNT_URI = "/welcome/new_account";

// Add, Edit, List locations
  static const String ADD_LOC_URI = "/locations";
  static const String EDIT_LOC_URI = "/locatons/";
  static const String LIST_LOC_URI = "/locations.json";

//Add, Edit, List item details
  static const String ADD_ITEM_URI = "/myitems";
  static const String EDIT_ITEM_URI = "/myitems/";
  static const String DEL_ITEM_URI = "/myitems/";
  static const String LIST_ITEM_URI = "/myitems.json";

  static const String ADD_ITEM_ATTCH_URI = "/attachments";

//Add media items
  static const String ADD_MEDIA_URI = "/myitems";

//Manage Contacts
  static const String CONTACTS_ITEM_INDEX_URI = "";
  static const String CONTACTS_CREATE_URI = "";
  static const String CONTACTS_UPDATE_URI = "";

//Add Details
  static const String ADD_DETAILS_CREATE_URI = "";

//Add use case
  static const String ADD_USE_CASE_URI = "/siteusers/add_usercase";

//My Collection
  static const String COLLECTIONS_LIST_URI = "/collections";
  static const String COLLECTION_CREATE_URI = "/collections";
  static const String COLLECTION_DEL_URI = "/collections/";

  //Collections item
  static const String COLLECTIOS_ITEM_LIST_URI = "/collection_items";
  static const String COLLECTION_ITEM_CREATE_URI = "/collection_items";
  static const String COLLECTION_ITEM_DEL_URI = "/collection_items/";

  //Get myitems
  static const String MYITEMS_LIST_URI = "/myitems";

  //Get myitems attachments
  static const String MYITEMS_ATTACHMENTS_LIST_URI = "/attachments";

//Alert for new item
  static const String ALERT_TITLE_ADDITEM = "AnH:: Add item";
}
