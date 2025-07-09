class MyItemAttachmentsList {
  bool? success;
  String? authToken;
  String? action;
  String? message;

  late List<MyitemImgsModel> _myitemImgs;
  List<MyitemImgsModel> get myitemImgs => _myitemImgs;

  MyItemAttachmentsList(
      {required success,
      required authToken,
      required action,
      required message,
      required myitemImgs}) {
    this.success = success;
    this.authToken = authToken;
    this.message = message;
    this._myitemImgs = myitemImgs;
  }

  MyItemAttachmentsList.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    authToken = json['auth_token'];
    action = json['action'];
    message = json['message'];
    if (json['myitem_imgs'] != null) {
      _myitemImgs = <MyitemImgsModel>[];
      json['myitem_imgs'].forEach((v) {
        _myitemImgs.add(new MyitemImgsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['auth_token'] = this.authToken;
    data['action'] = this.action;
    data['message'] = this.message;
    if (this._myitemImgs != null) {
      data['myitem_imgs'] = this._myitemImgs.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MyitemImgsModel {
  String? myitemId;
  String? attachmentId;
  String? name;
  String? description;
  String? imgUrl;
  var imgFormat;
  var imgContentType;
  var isHidden;

  MyitemImgsModel(
      {this.myitemId,
      this.attachmentId,
      this.name,
      this.description,
      this.imgUrl,
      this.imgFormat,
      this.imgContentType,
      this.isHidden});

  MyitemImgsModel.fromJson(Map<String, dynamic> json) {
    myitemId = json['myitem_id'];
    attachmentId = json['attachment_id'];

    if (json['name'] == null || json['name'] == "") {
      name = "NA";
    } else {
      name = json['name'];
    }

    if (json['description'] == null || json['description'] == "") {
      description = "NA";
    } else {
      description = json['description'];
    }

    imgUrl = json['img_url'];

    if (json['img_format'] == null || json['img_format'] == "") {
      imgFormat = "NA";
    } else {
      imgFormat = json['img_format'];
    }

    if (json['img_contentType'] == null || json['img_contentType'] == "") {
      imgContentType = "NA";
    } else {
      imgContentType = json['img_contentType'];
    }

    if (json['isHidden'] == null || json['isHidden'] == "") {
      isHidden = "NA";
    } else {
      isHidden = json['isHidden'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['myitem_id'] = this.myitemId;
    data['attachment_id'] = this.attachmentId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['img_url'] = this.imgUrl;
    data['img_format'] = this.imgFormat;
    data['img_contentType'] = this.imgContentType;
    data['isHidden'] = this.isHidden;
    return data;
  }
}
