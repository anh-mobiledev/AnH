import 'dart:convert';

class NewAccountResponse {
  bool? success;
  String? authToken;
  String? message;
  UserData? data;

  NewAccountResponse({this.success, this.authToken, this.message, this.data});

  NewAccountResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    authToken = json['auth_token'];
    message = json['message'];
    data = json['data'] != null
        ? new UserData.fromJson(jsonDecode(json['data']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['auth_token'] = this.authToken;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserData {
  String? username;
  String? uid;

  UserData({this.username, this.uid});

  UserData.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['uid'] = this.uid;
    return data;
  }
}
