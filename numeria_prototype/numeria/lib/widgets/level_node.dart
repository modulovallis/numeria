import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/curriculum.dart';

/// A single tappable node on a Realm Map, showing locked / unlocked /
/// completed state — see Section 5.2 of the design document.
class LevelNode extends StatelessWidget {
  final LevelDef level;
  final bool unlocked;
  final bool completed;
  final Color color;
  final VoidCallback onTap;

  const LevelNode({
    super.key,
    required this.level,
    required this.unlocked,
    required this.completed,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final nodeColor = completed
        ? NumeriaColors.green
        : (unlocked ? color : Colors.grey.shade400);

    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: level.isBoss ? 76 : 60,
              height: level.isBoss ? 76 : 60,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(color: NumeriaColors.cardShadow, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Icon(
                completed
                    ? Icons.star_rounded
                    : (unlocked
                        ? (level.isBoss ? Icons.shield_moon_rounded : Icons.play_arrow_rounded)
                        : Icons.lock_rounded),
                color: Colors.white,
                size: level.isBoss ? 34 : 26,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 90,
              child: Text(
                level.displayTitle(t),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
