class ContactCreateBody {
  String? resultAs;
  String? authToken;
  String? uid;
  String? deviceId;
  String? firstName;
  String? lastName;
  String? gender;
  String? email;
  String? homePhone;
  String? workPhone;
  String? mobile;

  ContactCreateBody(
      {this.resultAs,
      this.authToken,
      this.uid,
      this.deviceId,
      this.firstName,
      this.lastName,
      this.gender,
      this.email,
      this.homePhone,
      this.workPhone,
      this.mobile});

 

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result_as'] = this.resultAs;
    data['auth_token'] = this.authToken;
    data['uid'] = this.uid;
    data['device_id'] = this.deviceId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['email'] = this.email;
    data['home_phone'] = this.homePhone;
    data['work_phone'] = this.workPhone;
    data['mobile'] = this.mobile;
    return data;
  }
}