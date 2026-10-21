import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';

/// The "Confidence Meter" from Section 7 of the design document: a growth
/// indicator that rewards persistence and improvement, shown alongside XP
/// rather than replacing it, so a child sees progress even after a mistake.
class ConfidenceMeter extends StatelessWidget {
  final int value; // 0-100
  const ConfidenceMeter({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('💪', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              t.t('confidence_label'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 10,
            width: 140,
            decoration: BoxDecoration(color: Colors.black12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (value / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [NumeriaColors.blue, NumeriaColors.green],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
