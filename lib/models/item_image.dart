class ItemImage {
  int? id;
  String item_image = '';
  int? item_code;
  String? siteuser_id = '';

  ItemImage(
      {this.id, required this.item_image, this.item_code, this.siteuser_id});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'item_image': this.item_image,
      'item_code': this.item_code,
      'siteuser_id': this.siteuser_id
    };
    return map;
  }

  ItemImage.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    item_image = map['item_image'];
    item_code = map['item_code'];
    siteuser_id = map['siteuser_id'];
  }
}
