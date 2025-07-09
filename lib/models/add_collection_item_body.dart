class CollectionItemCreateBody {
  String authToken;
  String myItemId;
  String collectionId;
  String altDescription;
  String qty;
  String qtyUnits;
  bool forSale;
  bool forRent;
  bool sharable;

  CollectionItemCreateBody(
      {required this.authToken,
      required this.myItemId,
      required this.collectionId,
      required this.altDescription,
      required this.qty,
      required this.qtyUnits,
      required this.forSale,
      required this.forRent,
      required this.sharable});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    data["result_as"] = "JSON";
    data["auth_token"] = this.authToken;
    data["myitem_id"] = this.myItemId;
    data["collection_id"] = this.collectionId;
    data["alt_description"] = this.altDescription;
    data["qty"] = this.qty;
    data["qty_units"] = this.qtyUnits;
    data["for_sale"] = this.forSale;
    data["for_rent"] = this.forRent;
    data["sharable"] = this.sharable;
    return data;
  }
}
