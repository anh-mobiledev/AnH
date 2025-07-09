class MyItemByIdServer {
  bool? success;
  String? authToken;
  String? action;
  String? message;

  late MyItemByIdServerModel _myItem;
  MyItemByIdServerModel get myItem => _myItem;

  MyItemByIdServer(
      {required success,
      required authToken,
      required action,
      required message,
      required myItemsIndex}) {
    this.success = success;
    this.authToken = authToken;
    this.message = message;
    this._myItem = myItemsIndex;
  }

  MyItemByIdServer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    authToken = json['auth_token'];
    action = json['action'];
    message = json['message'];
    _myItem = MyItemByIdServerModel.fromJson(json["myitem"]);
  }
}

class MyItemByIdServerModel {
  String? id;
  String? name;
  String? description;
  String? primary_img_url;
  double? valueAmount;
  String? valueType;
  String? valueUnits;
  String? status;
  String? condition;
  String? keywords;

  // String? siteuserId;
  // String? currentLocationId;
  // String? ymmId;
  // int? qty;
  // String? createdAt;
  // String? updatedAt;
  // String? locationId;
  // String? locationComment;
  // String? shareable;
  // String? forSale;
  // String? forRent;
  // String? itemType;

  MyItemByIdServerModel({
    this.id,
    this.name,
    this.description,
    this.primary_img_url,
    this.valueAmount,
    this.valueType,
    this.valueUnits,
    this.status,
    this.condition,
    this.keywords,
    //this.siteuserId,
    // this.currentLocationId,
    // this.ymmId,
    // this.qty,
    // this.createdAt,
    // this.updatedAt,
    // this.locationId,
    // this.locationComment,
    // this.shareable,
    // this.forSale,
    // this.forRent,
    // this.itemType
  });

  MyItemByIdServerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if (json['name'] == null) {
      name = "NA";
    } else {
      name = json['name'];
    }

    if (json['description'] == null) {
      description = "NA";
    } else {
      description = json['description'];
    }

    primary_img_url = json['primary_img_url'];

    if (json['value_amt'] == null) {
      valueAmount = 0.0;
    } else {
      valueAmount = json['value_amt'];
    }

    if (json['value_type'] == null || json['value_type'] == "") {
      valueType = "Select value type";
    } else {
      valueType = json['value_type'];
    }

    if (json['value_units'] == null || json['value_units'] == "") {
      valueUnits = "0";
    } else {
      valueUnits = json['value_units'];
    }

    if (json['status'] == null || json['status'] == "") {
      status = "Select status";
    } else {
      status = json['status'];
    }

    if (json['condition'] == null || json['condition'] == "") {
      condition = "Select condition";
    } else {
      condition = json['condition'];
    }

    if (json['keywords'] == null || json['keywords'] == "") {
      keywords = "";
    } else {
      keywords = json['keywords'];
    }

    //siteuserId = json['siteuser_id'];
    // currentLocationId = json['current_location_id'];
    // ymmId = json['ymm_id'];
    // qty = json['qty'];
    // createdAt = json['created_at'];
    // updatedAt = json['updated_at'];
    // locationId = json['location_id'];
    // locationComment = json['location_comment'];
    // shareable = json['shareable'];
    // forSale = json['for_sale'];
    // forRent = json['for_rent'];
    // itemType = json['item_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['primary_img_url'] = this.primary_img_url;
    data['value_amt'] = this.valueAmount;

    // data['siteuser_id'] = this.siteuserId;
    // data['value_type'] = this.valueType;
    // data['value_amt'] = this.valueAmt;
    // data['value_units'] = this.valueUnits;
    // data['status'] = this.status;
    // data['condition'] = this.condition;
    // data['keywords'] = this.keywords;
    // data['current_location_id'] = this.currentLocationId;
    // data['ymm_id'] = this.ymmId;
    // data['qty'] = this.qty;
    // data['created_at'] = this.createdAt;
    // data['updated_at'] = this.updatedAt;
    // data['location_id'] = this.locationId;
    // data['location_comment'] = this.locationComment;
    // data['shareable'] = this.shareable;
    // data['for_sale'] = this.forSale;
    // data['for_rent'] = this.forRent;
    // data['item_type'] = this.itemType;
    return data;
  }
}
