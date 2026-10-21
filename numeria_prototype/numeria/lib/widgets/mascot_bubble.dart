import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';

/// The "Explain-It-Back Coach" mascot bubble from Section 7 of the design
/// document — short, kid-language hints delivered in the child's own
/// selected language whenever they get stuck.
class MascotBubble extends StatelessWidget {
  final String message;
  const MascotBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: NumeriaColors.yellow,
            shape: BoxShape.circle,
          ),
          child: const Text('🦊', style: TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: NumeriaColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('mascot_name'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: NumeriaColors.tealDark),
                ),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
