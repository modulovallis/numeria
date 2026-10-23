import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/curriculum.dart';

class ResultScreen extends StatelessWidget {
  final LevelDef level;
  final int stars;
  final int xpEarned;
  final int coinsEarned;
  final Color themeColor;

  /// When provided, shows a "Play Again" button that replaces this screen
  /// with a fresh attempt (new random questions) at the same level — see
  /// Section 7 of the design document on encouraging retries to improve a
  /// star score rather than treating a level as "done forever".
  final WidgetBuilder? replayBuilder;

  const ResultScreen({
    super.key,
    required this.level,
    required this.stars,
    required this.xpEarned,
    required this.coinsEarned,
    required this.themeColor,
    this.replayBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      body: Container(
        decoration: numeriaBackground(colors: [themeColor.withOpacity(0.25), Colors.white]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 8),
                Text(
                  t.t('level_complete_title'),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: NumeriaColors.tealDark),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final filled = i < stars;
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: NumeriaColors.yellow,
                      size: 52,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(t.t('stars_earned_label'), style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _StatRow(emoji: '✨', label: t.t('xp_earned_label'), value: '+$xpEarned'),
                        const SizedBox(height: 10),
                        _StatRow(emoji: '🪙', label: t.t('coins_earned_label'), value: '+$coinsEarned'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (replayBuilder != null) ...[
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: replayBuilder!),
                    ),
                    icon: const Icon(Icons.replay_rounded),
                    label: Text(t.t('play_again_button')),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.t('back_to_map_button')),
                  ),
                ] else
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.t('back_to_map_button')),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  const _StatRow({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NumeriaColors.green)),
      ],
    );
  }
}
