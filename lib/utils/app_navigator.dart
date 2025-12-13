import 'package:flutter/material.dart';
import '../main.dart'; // imports rootNavigatorKey

class AppNavigator {
  static BuildContext? get context => rootNavigatorKey.currentContext;
  static NavigatorState? get _nav => rootNavigatorKey.currentState;

  static Future<dynamic>? push(Route route) {
    if (_nav == null) return Future.value(null);
    return _nav!.push(route);
  }

  static Future<dynamic>? pushNamed(String name, {Object? arguments}) {
    if (_nav == null) return Future.value(null);
    return _nav!.pushNamed(name, arguments: arguments);
  }

  static Future<dynamic>? pushReplacementNamed(String name, {Object? arguments, Object? result}) {
    if (_nav == null) return Future.value(null);
    return _nav!.pushReplacementNamed(name, result: result, arguments: arguments);
  }

  /// Async maybePop (returns Future<bool>)
  static Future<bool> maybePopAsync([Object? result]) async {
    if (_nav == null) return false;
    return await _nav!.maybePop(result);
  }

  static void pop([Object? result]) {
    _nav?.pop(result);
  }

  /// Show a dialog using the root navigator context. Returns null future if context not available.
  static Future<T?> showAppDialog<T>({required WidgetBuilder builder, bool barrierDismissible = true}) {
    final ctx = context;
    if (ctx == null) return Future.value(null);
    return showDialog<T>(
      context: ctx,
      barrierDismissible: barrierDismissible,
      builder: (c) => builder(c),
    );
  }
}
