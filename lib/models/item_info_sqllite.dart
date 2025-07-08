class ItemInfoSQLLite {
  int? id;
  String? item_image;
  String? item_name;
  String? item_desc;
  String? item_category;
  String? item_ymm;
  String? item_keywords;
  String? item_condition;
  String? item_value_type;
  String? item_value;
  String? item_status;
  String? item_additional_options;
  String? item_img_code;
  String? siteuser_id;

  ItemInfoSQLLite({
    this.id,
    this.item_image,
    this.item_name,
    this.item_desc,
    this.item_category,
    this.item_ymm,
    this.item_keywords,
    this.item_condition,
    this.item_value_type,
    this.item_value,
    this.item_status,
    this.item_additional_options,
    this.item_img_code,
    this.siteuser_id,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'item_image': this.item_image,
      'item_name': this.item_name,
      'item_desc': this.item_desc,
      'item_category': this.item_category,
      'item_ymm': this.item_ymm,
      'item_keywords': this.item_keywords,
      'item_condition': this.item_condition,
      'item_value_type': this.item_value_type,
      'item_value': this.item_value,
      'item_status': this.item_status,
      'item_additional_options': this.item_additional_options,
      'item_img_code': this.item_img_code,
      'siteuser_id': this.item_img_code,
    };
    return map;
  }

  ItemInfoSQLLite.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    item_image = map['item_image'];
    item_name = map['item_name'];
    item_desc = map['item_desc'];
    item_category = map['item_category'];
    item_ymm = map['item_ymm'];
    item_keywords = map['item_keywords'];
    item_condition = map['item_condition'];
    item_value_type = map['item_value_type'];
    item_value = map['item_value'];
    item_status = map['item_status'];
    item_additional_options = map['item_additional_options'];
    item_img_code = map['item_img_code'];
    siteuser_id = map['siteuser_id'];
  }
}
