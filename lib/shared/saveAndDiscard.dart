import 'package:flutter/material.dart';

class FormActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final Future<bool> Function() onDiscard; // return true if confirmed

  const FormActionButtons({
    super.key,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () async {
            final confirm = await onDiscard();
            if (confirm) Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text("Discard", style: TextStyle(color: Colors.red)),
        ),

        // ✅ SAVE BUTTON
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2E7D32),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }
}
