class DeleteMyItemFailureResponse {
  bool? success;
  String? reasonCode;
  String? authToken;
  String? action;
  String? message;
  List<ReferenceCollections>? refCollections;

  DeleteMyItemFailureResponse(
      {this.success,
      this.reasonCode,
      this.authToken,
      this.action,
      this.message,
      this.refCollections});

  DeleteMyItemFailureResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    reasonCode = json['reason_code'];
    authToken = json['auth_token'];
    action = json['action'];
    message = json['message'];
    if (json['collections'] != null) {
      refCollections = <ReferenceCollections>[];
      json['collections'].forEach((v) {
        refCollections!.add(new ReferenceCollections.fromJson(v));
      });
    }
  }
}

class ReferenceCollections {
  String? collectionName;

  ReferenceCollections({this.collectionName});

  ReferenceCollections.fromJson(Map<String, dynamic> json) {
    collectionName = json['collection_name'];
  }
}
