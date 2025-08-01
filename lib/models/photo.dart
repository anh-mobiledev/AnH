class Photo {
  int? id;
  String? photoName='';

  Photo({this.id, this.photoName});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'photoName': this.photoName,
    };
    return map;
  }

  Photo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    photoName = map['photoName'];
  }
}
