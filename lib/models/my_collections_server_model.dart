class MyCollectionsServer {
  bool? success;
  String? authToken;
  String? action;
  String? message;

  late List<CollectionsServerModel> _collections;
  List<CollectionsServerModel> get collections => _collections;

  MyCollectionsServer(
      {required success,
      required authToken,
      required action,
      required message,
      required collectionIndex}) {
    this.success = success;
    this.authToken = authToken;
    this.message = message;
    this._collections = collectionIndex;
  }

  MyCollectionsServer.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    authToken = json['auth_token'];
    action = json['action'];
    message = json['message'];
    if (json['collections'] != null) {
      _collections = <CollectionsServerModel>[];
      json['collections'].forEach((v) {
        _collections.add(new CollectionsServerModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['auth_token'] = this.authToken;
    data['action'] = this.action;
    data['message'] = this.message;
    if (this._collections != null) {
      data['collections'] = this._collections.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CollectionsServerModel {
  String? id;
  String? siteuserId;
  String? name;
  String? description;
  int? iconId;
  String? pictureId;
  String? valuationId;
  String? moneyId;
  String? createdAt;
  String? updatedAt;

  CollectionsServerModel(
      {this.id,
      this.siteuserId,
      this.name,
      this.description,
      this.iconId,
      this.pictureId,
      this.valuationId,
      this.moneyId,
      this.createdAt,
      this.updatedAt});

  CollectionsServerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteuserId = json['siteuser_id'];
    name = json['name'];
    description = json['description'];
    iconId = json['icon_id'];
    pictureId = json['picture_id'];
    valuationId = json['valuation_id'];
    moneyId = json['money_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['siteuser_id'] = this.siteuserId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['icon_id'] = this.iconId;
    data['picture_id'] = this.pictureId;
    data['valuation_id'] = this.valuationId;
    data['money_id'] = this.moneyId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
