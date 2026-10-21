import 'package:flutter/material.dart';

/// A small rounded pill showing a stat (XP, coins, streak, ...).
class StatChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const StatChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.95)),
          ),
        ],
      ),
    );
  }
}
