// Mobile implementation - uses real image_cropper
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<File?> cropImageImpl({
  required String sourcePath,
  required dynamic aspectRatio,
  required List<dynamic> uiSettings,
}) async {
  try {
    // Cast uiSettings to the correct type required by image_cropper
    final settings = uiSettings.cast<PlatformUiSettings>();
    
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: aspectRatio as CropAspectRatio?,
      uiSettings: settings,
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  } catch (e) {
    // If cropping fails, return null to skip it
    return null;
  }
}

dynamic createAspectRatioImpl(double x, double y) {
  return CropAspectRatio(ratioX: x, ratioY: y);
}

List<dynamic> createUiSettingsImpl(dynamic context) {
  return [
    AndroidUiSettings(
      toolbarTitle: 'Crop Image',
      toolbarColor: const Color(0xFF5B5CEB),
      toolbarWidgetColor: Colors.white,
      initAspectRatio: CropAspectRatioPreset.square,
      lockAspectRatio: true,
    ),
    IOSUiSettings(
      title: 'Crop Image',
      aspectRatioLockEnabled: true,
    ),
  ];
}

