class CollectionCreateBody {
  String authToken;
  String collectionName;
  String collectionDescription;

  String collectionIconId;

  CollectionCreateBody(
      {required this.authToken,
      required this.collectionName,
      required this.collectionDescription,
      required this.collectionIconId});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    data["result_as"] = "JSON";
    data["auth_token"] = this.authToken;
    data["collection[name]"] = this.collectionName;
    data["collection[description]"] = this.collectionDescription;
 
    data["collection[icon_id]"] = this.collectionIconId;
    return data;
  }
}
