class ContactList {
  String id = '';
  String first = '';
  String last = '';
  String relationship = '';

  ContactList({id, first, last, relationship});

  ContactList.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    first = json['first'];
    last = json['last'];
    relationship = json['relationship'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['first'] = first;
    data['last'] = last;
    data['relationship'] = relationship;
    return data;
  }
}
