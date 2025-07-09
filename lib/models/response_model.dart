class ResponseModel {
  bool _isSuccess;
  String _token;

  String _message;

  ResponseModel(this._isSuccess, this._token, this._message);

  bool get isSuccess => _isSuccess;
  String get authToken => _token;

  String get message => _message;
}
