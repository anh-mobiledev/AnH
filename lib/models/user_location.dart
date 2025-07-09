class UserLocation {
  int? id;
  String? name = '';
  String? longitude_coord = '';
  String? latitude_coord = '';
  String? street_addr1 = '';
  String? street_addr2 = '';
  String? city = '';
  String? state_prov = '';
  String? country = '';
  String? siteuser_id = '';

  UserLocation(
      {this.id,
      this.name,
      this.longitude_coord,
      this.latitude_coord,
      this.street_addr1,
      this.street_addr2,
      this.city,
      this.state_prov,
      this.country,
      this.siteuser_id});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': this.id,
      'name': this.name,
      'longitude_coord': this.longitude_coord,
      'latitude_coord': this.latitude_coord,
      'street_addr1': this.street_addr1,
      'street_addr2': this.street_addr2,
      'city': this.city,
      'state_prov': this.state_prov,
      'country': this.country,
      'siteuser_id': this.siteuser_id
    };
    return map;
  }

  UserLocation.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    longitude_coord = map['longitude_coord'];
    latitude_coord = map['latitude_coord'];
    street_addr1 = map['street_addr1'];
    street_addr2 = map['street_addr2'];
    city = map['city'];
    state_prov = map['state_province'];
    country = map['country'];
    siteuser_id = map['siteuser_id'];
  }
}
