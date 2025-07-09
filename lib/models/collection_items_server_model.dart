class CollectionItemsServer {
  bool? success;
  String? authToken;
  String? action;
  String? message;

  late List<CollectionItemsModel> _collectionItems;
  List<CollectionItemsModel> get collectionItems => _collectionItems;

  CollectionItemsServer(
      {required success,
      required authToken,
      required action,
      required message,
      required collectionItemsIndex}) {
    this.success = success;
    this.authToken = authToken;
    this.message = message;
    this._collectionItems = collectionItemsIndex;
  }

  CollectionItemsServer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    authToken = json['auth_token'];
    action = json['action'];
    message = json['message'];
    if (json['collection_items'] != null) {
      _collectionItems = <CollectionItemsModel>[];
      json['collection_items'].forEach((v) {
        collectionItems.add(new CollectionItemsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['auth_token'] = this.authToken;
    data['action'] = this.action;
    data['message'] = this.message;
    if (this.collectionItems != null) {
      data['collection_items'] =
          this.collectionItems.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CollectionItemsModel {
  String? id;
  String? name;
  String? description;
  String? valueAmount;
  String? primary_img_url;
  String? valueType;
  String? valueUnits;
  String? status;
  String? condition;
  String? keywords;

  CollectionItemsModel({
    this.id,
    this.name,
    this.description,
    this.valueAmount,
    this.primary_img_url,
    this.valueType,
    this.valueUnits,
    this.status,
    this.condition,
    this.keywords,
  });

  CollectionItemsModel.fromJson(Map<String, dynamic> json) {
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
    if (json['value_amt'] == null) {
      valueAmount = "\$0.00";
    } else {
      valueAmount = json['value_amt'];
    }
    if (json['primary_img_url'] == null) {
      primary_img_url = "NA";
    } else {
      primary_img_url = json['primary_img_url'];
    }

    if (json['value_amt'] == null) {
      valueAmount = "\$0.0";
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['value_amt'] = this.valueAmount;
    data['primary_img_url'] = this.primary_img_url;
    return data;
  }
}
