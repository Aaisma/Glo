//to edit later

class UserModel{
  
  final String id;
  final String name;
  final String? contact;
  final String email;

  UserModel.name(this.id, this.name, this.contact, this.email);

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'contact': this.contact,
      'email': this.email,
    };
  }

 // factory UserModel.fromMap(Map<String, dynamic> map) {
  //  return UserModel(
  //    id: map['id'] as String,
  //    name: map['name'] as String,
  //    contact: map['contact'] as String,
  //    email: map['email'] as String,
  //  );
  //}
}