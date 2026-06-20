import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  final String id;          // Firestore document ID
  final String url;         // Cloudinary secure_url
  final String userId;      // Owner of the image
  final DateTime uploadedAt;

  ImageModel({
    required this.id,
    required this.url,
    required this.userId,
    required this.uploadedAt,
  });

  // Factory constructor to build from Firestore document
  factory ImageModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ImageModel(
      id: documentId,
      url: data['url'] ?? '',
      userId: data['userId'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'userId': userId,
      'uploadedAt': uploadedAt,
    };
  }
}
