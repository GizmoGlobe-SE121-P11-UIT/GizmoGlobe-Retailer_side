// Mobile-specific utilities
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MobileUtils {
  static void pushState(String url) {
    // No-op for mobile platforms
    // URL routing is handled by Flutter's navigation system
  }

  static void replaceState(String url) {
    // No-op for mobile platforms
    // URL routing is handled by Flutter's navigation system
  }

  static String getCurrentUrl() {
    // Return a default URL for mobile platforms
    return '/';
  }

  static Stream<dynamic> get onHashChange {
    // Return an empty stream for mobile platforms
    return const Stream.empty();
  }

  static Future<void> downloadFile(Uint8List bytes, String filename) async {
    try {
      // Get the downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Downloads directory not available');
      }

      // Create the file
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);

      // Show a message to the user (you might want to use a proper notification system)
      print('File downloaded to: ${file.path}');
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }
}
