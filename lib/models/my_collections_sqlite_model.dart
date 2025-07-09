class MyCollectionSQLite {
  bool? _success;
  String? _action;
  late List<CollectionSQLiteModel> _collections;
  List<CollectionSQLiteModel> get collections => _collections;

  MyCollection({required success, required action, required collectionIndex}) {
    this._success = success;
    this._action = action;
    this._collections = collectionIndex;
  }

  MyCollectionSQLite.fromJson(Map<String, dynamic> json) {
    _success = json['success'];
    _action = json['action'];
    if (json['collections'] != null) {
      _collections = <CollectionSQLiteModel>[];
      json['collections'].forEach((v) {
        _collections.add(new CollectionSQLiteModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this._success;
    data['action'] = this._action;
    if (_collections != null) {
      data['collections'] = this.collections.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CollectionSQLiteModel {
  int? id;
  String? name;
  String? desc;
  int? price;
  String? image;

  CollectionSQLiteModel(
      {this.id, this.name, this.desc, this.price, this.image});

  CollectionSQLiteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    desc = json['desc'];
    price = json['price'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['desc'] = this.desc;
    data['price'] = this.price;
    data['image'] = this.image;
    return data;
  }
}
