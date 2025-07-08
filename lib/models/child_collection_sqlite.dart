class ChildCollectionSqlite {
  int? id;
  String? name;
  double? current_value;
  int? parent_id;

  ChildCollectionSqlite(
      {this.id, this.name, this.current_value, this.parent_id});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'name': this.name,
      'desc': this.current_value,
      'icon_code': this.parent_id
    };
    return map;
  }

  ChildCollectionSqlite.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    current_value = map['current_value'];
    parent_id = map['parent_id'];
  }
}
