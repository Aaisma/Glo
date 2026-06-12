class SkinTip {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  SkinTip({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory SkinTip.fromMap(Map<String, dynamic> data, String documentId) {
    return SkinTip(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
