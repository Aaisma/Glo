class UserProfile {
  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String photoUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'photoUrl': photoUrl,
    };
  }
}
