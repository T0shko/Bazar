// Helper to conditionally use image_cropper only on non-web platforms
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditionally import the correct implementation for the current platform
import 'image_cropper_mobile_impl.dart'
    if (dart.library.html) 'image_cropper_web_impl.dart' as cropper_impl;

class ImageCropperHelper {
  // Use dynamic return type to work on both web and mobile
  static Future<dynamic> cropImage({
    required String sourcePath,
    required dynamic aspectRatio,
    required List<dynamic> uiSettings,
  }) async {
    final result = await cropper_impl.cropImageImpl(
      sourcePath: sourcePath,
      aspectRatio: aspectRatio,
      uiSettings: uiSettings,
    );
    // On web, result will be null, on mobile it will be File
    return result;
  }

  static dynamic createAspectRatio(double x, double y) {
    if (kIsWeb) {
      return null;
    }
    return cropper_impl.createAspectRatioImpl(x, y);
  }

  static List<dynamic> createUiSettings(BuildContext context) {
    if (kIsWeb) {
      return [];
    }
    return cropper_impl.createUiSettingsImpl(context);
  }
}

