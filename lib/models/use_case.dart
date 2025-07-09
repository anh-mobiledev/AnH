class UseCase {
  int? id;
  String? value = '';
  String? desc = '';
  String? siteuser_id = '';

  UseCase({this.id, this.value, this.desc, this.siteuser_id});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'value': this.value,
      'desc': this.desc,
      'siteuser_id': this.siteuser_id
    };
    return map;
  }

  UseCase.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    value = map['value'];
    desc = map['desc'];
    siteuser_id = map['siteuser_id'];
  }
}
