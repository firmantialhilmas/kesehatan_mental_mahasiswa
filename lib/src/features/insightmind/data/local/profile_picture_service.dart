// lib/src/features/insightmind/data/local/profile_picture_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfilePictureService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery and save it to app's local storage
  /// Returns the path to the saved image, or null if cancelled/failed
  /// For web: returns the XFile path (temporary)
  /// For mobile/desktop: returns the permanent file path
  Future<String?> pickAndSaveImage() async {
    try {
      // Pick image from gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return null; // User cancelled
      }

      // For web, we can't use path_provider, so return the XFile path directly
      if (kIsWeb) {
        return pickedFile.path;
      }

      // For mobile/desktop, save to permanent storage
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String profilePicsDir = path.join(appDir.path, 'profile_pictures');
      
      // Create directory if it doesn't exist
      final Directory dir = Directory(profilePicsDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(pickedFile.path);
      final String fileName = 'profile_$timestamp$extension';
      final String savedPath = path.join(profilePicsDir, fileName);

      // Copy file to app directory
      final File sourceFile = File(pickedFile.path);
      await sourceFile.copy(savedPath);

      return savedPath;
    } catch (e) {
      print('Error picking/saving image: $e');
      return null;
    }
  }

  /// Delete a profile picture from local storage
  Future<bool> deleteImage(String imagePath) async {
    try {
      // For web, we don't need to delete (it's temporary)
      if (kIsWeb) {
        return true;
      }

      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Check if a file exists at the given path
  Future<bool> imageExists(String imagePath) async {
    try {
      // For web, assume it exists if path is not empty
      if (kIsWeb) {
        return imagePath.isNotEmpty;
      }

      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
