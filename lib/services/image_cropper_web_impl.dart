// Web implementation - skip cropping
// Note: File type is not available on web, so we use dynamic
import 'package:flutter/material.dart';

Future<dynamic> cropImageImpl({
  required String sourcePath,
  required dynamic aspectRatio,
  required List<dynamic> uiSettings,
}) async {
  // On web, skip cropping and return null
  return null;
}

dynamic createAspectRatioImpl(double x, double y) {
  return null;
}

List<dynamic> createUiSettingsImpl(BuildContext context) {
  return [];
}

