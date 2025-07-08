class ParentCollectionSqlite {
  int? id;
  String? name;
  String? desc;
  int? icon_code;

  ParentCollectionSqlite({this.id, this.name, this.desc, this.icon_code});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'name': this.name,
      'desc': this.desc,
      'icon_code': this.icon_code
    };
    return map;
  }

  ParentCollectionSqlite.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    desc = map['desc'];
    icon_code = map['icon_code'];
  }
}
