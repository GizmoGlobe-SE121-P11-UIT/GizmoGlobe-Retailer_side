// Stub file for non-web platforms
import 'dart:async';
import 'dart:typed_data';

class WebUtils {
  static void pushState(String url) {
    // Stub implementation for non-web platforms
  }

  static void replaceState(String url) {
    // Stub implementation for non-web platforms
  }

  static String getCurrentUrl() {
    // Stub implementation for non-web platforms
    return '/';
  }

  static Stream<dynamic> get onHashChange {
    // Stub implementation for non-web platforms
    return const Stream.empty();
  }

  static void downloadFile(Uint8List bytes, String filename) {
    // Stub implementation for non-web platforms
    throw UnsupportedError('downloadFile is not supported on this platform');
  }
}

