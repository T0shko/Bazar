// Helper to create File objects - different implementations for web vs mobile
import 'file_helper_mobile.dart' if (dart.library.html) 'file_helper_web.dart' as file_impl;

dynamic createFileFromPath(String path) {
  return file_impl.createFileFromPath(path);
}

