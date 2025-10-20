import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetData{
  static String getUID() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  static dynamic getValueFromPath(Map<String, dynamic> data, String path) {
    dynamic cur = data;
    for (final part in path.split('.')) {
      if (cur is Map<String, dynamic> && cur.containsKey(part)) {
        cur = cur[part];
      } else {
        return null;
      }
    }
    return cur;
  }

  static String? getStringFromPath(Map<String, dynamic> data, String path,
      {String? defaultValue}) {
    final v = getValueFromPath(data, path);
    if (v == null) return defaultValue;
    if (v is String) return v;
    if (v is num) return v.toString();
    if (v is bool) return v ? 'true' : 'false';
    if (v is Timestamp) return v.toDate().toIso8601String();
    return v.toString();
  }

  static int? getIntFromPath(Map<String, dynamic> data, String path,
      {int? defaultValue}) {
    final v = getValueFromPath(data, path);
    if (v == null) return defaultValue;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return defaultValue;
  }

  static double? getDoubleFromPath(Map<String, dynamic> data, String path,
      {double? defaultValue}) {
    final v = getValueFromPath(data, path);
    if (v == null) return defaultValue;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return defaultValue;
  }

  static bool? getBoolFromPath(Map<String, dynamic> data, String path,
      {bool? defaultValue}) {
    final v = getValueFromPath(data, path);
    if (v == null) return defaultValue;
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    if (v is num) return v != 0;
    return defaultValue;
  }

  static List<String> getStringListFromPath(Map<String, dynamic> data, String path,
      {List<String>? defaultValue}) {
    final v = getValueFromPath(data, path);
    if (v == null) return defaultValue ?? <String>[];
    if (v is List) return v.map((e) => e.toString()).toList();
    return defaultValue ?? <String>[];
  }

}

