import '../model/image_model.dart';

/// Abstract repository contract for handling image operations.
/// Keeps your app decoupled from the actual Cloudinary/Firestore implementation.
abstract class ImageRepo {
  /// Upload a profile image for a given user.
  /// Returns an [ImageModel] containing the Cloudinary secure_url and metadata.
  Future<ImageModel> uploadProfileImage(String userId, String filePath);

  /// Delete an image by its Firestore document ID.
  Future<void> deleteImage(String imageId);

  /// Fetch the most recent image uploaded by a user.
  /// Returns null if no image exists.
  Future<ImageModel?> getImageByUser(String userId);
}
