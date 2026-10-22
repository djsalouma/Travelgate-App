import 'package:flutter/material.dart';

import '../../config/app_config.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  Color? confirmColor,
  Color? cancelColor,
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: cancelColor,
          ),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? AppConfig.primaryColor,
          ),
          child: Text(
            confirmText,
            style: TextStyle(
              color: confirmColor ?? AppConfig.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  required String hintText,
  String? initialValue,
  String confirmText = 'Save',
  String cancelText = 'Cancel',
}) async {
  final controller = TextEditingController(text: initialValue);
  
  return await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          style: TextButton.styleFrom(
            foregroundColor: AppConfig.primaryColor,
          ),
          child: Text(
            confirmText,
            style: TextStyle(
              color: AppConfig.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
