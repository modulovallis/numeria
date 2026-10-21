import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// A simple "grown-up check" gate — a short multiplication question an
/// adult answers instantly but a young child typically cannot — shown
/// before any purchase or plan change, per Section 8 / Section 10 of the
/// design document (Google Play Families Policy / COPPA parental-gate
/// expectations). This is a UX pattern demo only; production purchases
/// must still go through platform billing with its own consent flows.
Future<bool> showParentGate(BuildContext context) async {
  final rng = Random();
  final a = 6 + rng.nextInt(4); // 6-9
  final b = 6 + rng.nextInt(4); // 6-9
  final correct = a * b;
  final controller = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final t = context.l10n;
      String? errorText;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(t.t('parent_gate_title')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.t('parent_gate_question', {'a': a, 'b': b})),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(t.t('cancel_button')),
              ),
              ElevatedButton(
                onPressed: () {
                  if (int.tryParse(controller.text) == correct) {
                    Navigator.of(context).pop(true);
                  } else {
                    setState(() => errorText = t.t('parent_gate_wrong'));
                  }
                },
                child: Text(t.t('confirm_button')),
              ),
            ],
          );
        },
      );
    },
  );
  return result ?? false;
}
