import 'package:flutter/material.dart';
import '../model/image_model.dart';
import '../repo/image_repo.dart';

class ImageViewModel extends ChangeNotifier {
  final ImageRepo _repo;

  ImageViewModel(this._repo);

  ImageModel? _currentImage;
  bool _isLoading = false;
  String? _errorMessage;

  ImageModel? get currentImage => _currentImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Upload a new profile image and update state
  Future<void> updateProfileImage(String userId, String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final image = await _repo.uploadProfileImage(userId, filePath);
      _currentImage = image;
    } catch (e) {
      _errorMessage = "Failed to upload image: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch the latest image for a user
  Future<void> fetchUserImage(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final image = await _repo.getImageByUser(userId);
      _currentImage = image;
    } catch (e) {
      _errorMessage = "Failed to fetch image: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an image by ID
  Future<void> deleteImage(String imageId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.deleteImage(imageId);
      _currentImage = null;
    } catch (e) {
      _errorMessage = "Failed to delete image: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
