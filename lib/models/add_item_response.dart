class AddItemResponse {
  bool? success;
  String? message;
  ItemModel? data;

  AddItemResponse({this.success, this.message, this.data});

  AddItemResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new ItemModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ItemModel {
  int? id;
  String? siteuserId;
  String? name;
  String? description;
  String? guid;
  String? createdAt;
  String? updatedAt;

  ItemModel(
      {this.id,
      this.siteuserId,
      this.name,
      this.description,
      this.guid,
      this.createdAt,
      this.updatedAt});

  ItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteuserId = json['siteuser_id'];
    name = json['name'];
    description = json['description'];
    guid = json['guid'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['siteuser_id'] = this.siteuserId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['guid'] = this.guid;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}