class NewAccountBody {
  String first_name;
  String last_name;
  String username;
  String password;
  String email;

  NewAccountBody({
    required this.first_name,
    required this.last_name,
    required this.username,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["result_as"] = "JSON";
    data["first_name"] = this.first_name;
    data["last_name"] = this.last_name;
    data["username"] = this.username;
    data["password"] = this.password;
    data["email"] = this.email;
    return data;
  }
}
