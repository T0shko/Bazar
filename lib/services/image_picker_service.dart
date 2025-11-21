import 'dart:async';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_cropper_helper.dart';
import 'file_helper.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<dynamic> pickAndCropImage(BuildContext context) async {
    try {
      // Show dialog to choose source
      final source = await _showImageSourceDialog(context);
      if (source == null) return null;

      // Pick image
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      // Crop image using helper (handles web vs mobile/desktop)
      final croppedFile = await ImageCropperHelper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: _createCropAspectRatio(1, 1),
        uiSettings: _createUiSettings(context),
      );

      // On mobile/desktop, croppedFile will be File?, on web it will be null
      if (croppedFile != null && !kIsWeb) {
        return croppedFile;
      }
      
      // If cropping was skipped or failed, return original file
      // On web, we return the XFile directly (upload method handles it)
      if (kIsWeb) {
        // On web, return the XFile object directly
        return pickedFile;
      }
      
      // On mobile/desktop, create File from path
      // Use helper that handles web vs mobile
      return createFileFromPath(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      rethrow;
    }
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    if (kIsWeb) {
      // On web, only show gallery option (camera doesn't work well on web)
      return await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Files'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    } else {
      // Check if we're on macOS - camera requires delegate setup
      // Use defaultTargetPlatform which works on all platforms including web
      final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
      
      // On macOS, only show gallery (camera requires delegate setup)
      // On iOS/Android, show both options
      return await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMacOS) // Only show camera on iOS/Android
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    }
  }

  dynamic _createCropAspectRatio(double x, double y) {
    if (kIsWeb) {
      return null;
    }
    // Create aspect ratio using helper
    return ImageCropperHelper.createAspectRatio(x, y);
  }

  List<dynamic> _createUiSettings(BuildContext context) {
    if (kIsWeb) {
      return [];
    }
    // Create UI settings using helper
    return ImageCropperHelper.createUiSettings(context);
  }
}

