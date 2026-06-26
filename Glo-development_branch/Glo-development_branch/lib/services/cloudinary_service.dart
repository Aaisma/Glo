import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'your_cloud_name',      // from Cloudinary dashboard
    'your_upload_preset',   // configured in Cloudinary settings
    cache: false,
  );

  /// Uploads an image file to Cloudinary and returns the secure URL.
  Future<String?> uploadImage(File file) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl; // this is the link you save in Firestore
    } catch (e) {
      return null;
    }
  }
}
