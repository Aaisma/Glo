import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/image_model.dart';
import 'image_repo.dart';
import '../services/cloudinary_service.dart';

class ImageRepoImpl implements ImageRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  Future<ImageModel> uploadProfileImage(String userId, String filePath) async {
    // Upload to Cloudinary
    final secureUrl = await _cloudinaryService.uploadImage(File(filePath));
    if (secureUrl == null) {
      throw Exception("Image upload failed");
    }

    // Save metadata in Firestore
    final docRef = await _firestore.collection("images").add({
      'url': secureUrl,
      'userId': userId,
      'uploadedAt': DateTime.now(),
    });

    return ImageModel(
      id: docRef.id,
      url: secureUrl,
      userId: userId,
      uploadedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteImage(String imageId) async {
    await _firestore.collection("images").doc(imageId).delete();
  }

  @override
  Future<ImageModel?> getImageByUser(String userId) async {
    final snapshot = await _firestore
        .collection("images")
        .where("userId", isEqualTo: userId)
        .orderBy("uploadedAt", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return ImageModel.fromMap(doc.data(), doc.id);
  }
}
