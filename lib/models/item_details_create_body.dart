class ItemDetailsCreateBody {
  String token;
  String uid;
  String deviceId;
  String itemId;
  String name;
  String desc;
  String year;
  String make;
  String model;
  String keywords;
  String condition;
  String valueType;
  String otherValue;

  ItemDetailsCreateBody({
    required this.token,
    required this.uid,
    required this.deviceId,
    required this.itemId,
    required this.name,
    required this.desc,
    required this.year,
    required this.make,
    required this.model,
    required this.keywords,
    required this.condition,
    required this.valueType,
    required this.otherValue,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['auth_token'] = token;
    data['result_as'] = "JSON";
    data['client_id'] = uid;
    data['uid'] = '';
    data['device_id'] = deviceId;
    data['item_id'] = itemId;
    data['name'] = name;
    data['desc'] = desc;
    data['year'] = year;
    data['make'] = make;
    data['model'] = model;
    data['keywords'] = keywords;
    data['condition'] = condition;
    data['valueType'] = valueType;
    data['otherValue'] = otherValue;

    return data;
  }
}
