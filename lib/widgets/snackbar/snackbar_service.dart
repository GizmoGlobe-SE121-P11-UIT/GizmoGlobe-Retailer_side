import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SnackbarService {
  static void showSuccess(BuildContext context, String title, String message) {
    _showSnackbar(context, title, message, ContentType.success);
  }

  static void showError(BuildContext context, String title, String message) {
    _showSnackbar(context, title, message, ContentType.failure);
  }

  static void showInfo(BuildContext context, String title, String message) {
    _showSnackbar(context, title, message, ContentType.help);
  }

  static void showWarning(BuildContext context, String title, String message) {
    _showSnackbar(context, title, message, ContentType.warning);
  }

  static void _showSnackbar(
      BuildContext context, String title, String message, ContentType type) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
