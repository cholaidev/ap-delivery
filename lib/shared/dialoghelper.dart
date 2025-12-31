import 'package:flutter/material.dart';

class DialogHelper {
  static Future<bool> showDiscardDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: const Text("Discard Changes?"),
                content: const Text(
                  "Are you sure you want to exit without saving?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Discard"),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
