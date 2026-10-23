import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/curriculum.dart';

/// A single tappable node on a Realm Map, showing locked / unlocked /
/// completed state — see Section 5.2 of the design document. Completed
/// nodes stay tappable (replayable) and show the best star score earned
/// so far, plus a small replay badge as a visual hint that tapping again
/// starts a fresh attempt.
class LevelNode extends StatelessWidget {
  final LevelDef level;
  final bool unlocked;
  final bool completed;
  final int stars;
  final Color color;
  final VoidCallback onTap;

  const LevelNode({
    super.key,
    required this.level,
    required this.unlocked,
    required this.completed,
    this.stars = 0,
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
            Stack(
              clipBehavior: Clip.none,
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
                        ? (level.kind == QuestionKind.matching ? Icons.link_rounded : Icons.star_rounded)
                        : (unlocked
                            ? (level.isBoss
                                ? Icons.shield_moon_rounded
                                : (level.kind == QuestionKind.matching
                                    ? Icons.link_rounded
                                    : Icons.play_arrow_rounded))
                            : Icons.lock_rounded),
                    color: Colors.white,
                    size: level.isBoss ? 34 : 26,
                  ),
                ),
                if (completed)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: NumeriaColors.teal,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                      ),
                      child: const Icon(Icons.replay_rounded, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (completed) _StarRow(stars: stars) else const SizedBox(height: 14),
            const SizedBox(height: 2),
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

class _StarRow extends StatelessWidget {
  final int stars;
  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: NumeriaColors.yellow,
          size: 14,
        );
      }),
    );
  }
}
