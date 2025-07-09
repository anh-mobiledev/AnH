class UserInfo {
  int? id;
  String? siteuser_id = '';
  String? username = '';

  UserInfo({this.id, this.siteuser_id, this.username});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'username': this.username,
      'siteuser_id': this.siteuser_id,
    };
    return map;
  }

  UserInfo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    username = map['username'];
    siteuser_id = map['siteuser_id'];
  }
}
