// Platform-specific utilities
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gizmoglobe_client/utils/web_utils.dart';
import 'package:gizmoglobe_client/utils/mobile_utils.dart';

class PlatformSpecificUtils {
  static void pushState(String url) {
    if (kIsWeb) {
      WebUtils.pushState(url);
    } else {
      MobileUtils.pushState(url);
    }
  }

  static void replaceState(String url) {
    if (kIsWeb) {
      WebUtils.replaceState(url);
    } else {
      MobileUtils.replaceState(url);
    }
  }

  static String getCurrentUrl() {
    if (kIsWeb) {
      return WebUtils.getCurrentUrl();
    } else {
      return MobileUtils.getCurrentUrl();
    }
  }

  static Stream<dynamic> get onHashChange {
    if (kIsWeb) {
      return WebUtils.onHashChange as Stream<dynamic>;
    } else {
      return MobileUtils.onHashChange;
    }
  }

  static Future<void> downloadFile(Uint8List bytes, String filename) async {
    if (kIsWeb) {
      WebUtils.downloadFile(bytes, filename);
    } else {
      await MobileUtils.downloadFile(bytes, filename);
    }
  }
}
