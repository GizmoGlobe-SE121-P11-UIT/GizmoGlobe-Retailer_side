import 'package:flutter/foundation.dart';

/// Platform detection utilities
class PlatformUtils {
  /// Check if the current platform is web
  static bool get isWeb => kIsWeb;

  /// Check if the current platform is mobile (Android or iOS)
  static bool get isMobile => !kIsWeb;

  /// Check if the current platform is Android
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Check if the current platform is iOS
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Check if the current platform is desktop (Windows, macOS, Linux)
  static bool get isDesktop => !kIsWeb && !isMobile;

  /// Check if the current platform is Windows
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  /// Check if the current platform is macOS
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  /// Check if the current platform is Linux
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  /// Get the current platform name as a string
  static String get platformName {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (isWindows) return 'windows';
    if (isMacOS) return 'macos';
    if (isLinux) return 'linux';
    return 'unknown';
  }

  /// Check if the app is running in debug mode
  static bool get isDebug => kDebugMode;

  /// Check if the app is running in release mode
  static bool get isRelease => kReleaseMode;

  /// Check if the app is running in profile mode
  static bool get isProfile => kProfileMode;
}
