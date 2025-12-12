// Web-specific utilities
import 'package:web/web.dart' as web;
import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';

class WebUtils {
  static final StreamController<web.Event> _hashChangeController =
      StreamController<web.Event>.broadcast();
  static bool _hashListenerInitialized = false;

  static void pushState(String url) {
    web.window.history.pushState(null, '', url);
    // Dispatch a hashchange event so listeners react immediately
    web.window.dispatchEvent(web.HashChangeEvent('hashchange'));
  }

  static void replaceState(String url) {
    web.window.history.replaceState(null, '', url);
    // Dispatch a hashchange event so listeners react immediately
    web.window.dispatchEvent(web.HashChangeEvent('hashchange'));
  }

  static String getCurrentUrl() {
    return web.window.location.href;
  }

  static Stream<web.Event> get onHashChange {
    if (!_hashListenerInitialized) {
      _hashListenerInitialized = true;
      // Register a JS listener and forward events into Dart stream
      web.window.addEventListener(
          'hashchange',
          (web.Event event) {
            _hashChangeController.add(event);
          }.toJS);
    }
    return _hashChangeController.stream;
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
