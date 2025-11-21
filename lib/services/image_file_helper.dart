// Helper to handle File type differences between web and mobile
import 'image_file_helper_mobile.dart' if (dart.library.html) 'image_file_helper_web.dart' as file_impl;

dynamic getFileForImage(dynamic imageFile) {
  return file_impl.getFileForImage(imageFile);
}

