class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.imageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
    };
  }
}
