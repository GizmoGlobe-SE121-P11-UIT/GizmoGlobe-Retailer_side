// Web-specific utilities
import 'package:web/web.dart' as web;
import 'dart:typed_data';
import 'dart:js_interop';

class WebUtils {
  static void pushState(String url) {
    web.window.history.pushState(null, '', url);
  }

  static void replaceState(String url) {
    web.window.location.replace(url);
  }

  static String getCurrentUrl() {
    return web.window.location.href;
  }

  static Stream<web.Event> get onHashChange {
    return web.window.onPopState;
  }

  static void downloadFile(Uint8List bytes, String filename) {
    // Convert Uint8List to JSArray<JSNumber> for Blob
    final jsArray = bytes.map((b) => b.toJS).toList().toJS;
    final blobParts = [jsArray as web.BlobPart].toJS;
    final blob = web.Blob(blobParts);
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..setAttribute('download', filename);
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
