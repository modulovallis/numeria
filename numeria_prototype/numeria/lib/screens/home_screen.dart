import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/curriculum_data.dart';
import '../l10n/app_localizations.dart';
import '../logic/premium_gate.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';
import '../widgets/stat_chip.dart';
import 'coop_quest_screen.dart';
import 'family_challenge_screen.dart';
import 'math_moment_screen.dart';
import 'paywall_screen.dart';
import 'realm_map_screen.dart';
import 'settings_screen.dart';

/// The Kingdom Select screen — one colorful world per grade, per Section 5
/// of the design document.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = context.l10n;

    return Scaffold(
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.t('home_welcome_back'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NumeriaColors.tealDark),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: NumeriaColors.tealDark),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    StatChip(emoji: '✨', label: '${appState.xp} ${t.t('xp_label')}', color: NumeriaColors.purple),
                    StatChip(emoji: '🪙', label: '${appState.coins}', color: NumeriaColors.yellow),
                    StatChip(emoji: '🔥', label: '${appState.streakDays} ${t.t('streak_label')}', color: NumeriaColors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: _MathMomentBanner(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickFeatureButton(
                        icon: Icons.diversity_3_rounded,
                        label: t.t('coop_quick_label'),
                        color: NumeriaColors.blue,
                        onTap: () => openPremiumFeature(context, (_) => const CoopQuestScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickFeatureButton(
                        icon: Icons.family_restroom_rounded,
                        label: t.t('family_quick_label'),
                        color: NumeriaColors.pink,
                        onTap: () => openPremiumFeature(context, (_) => const FamilyChallengeScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.t('kingdoms_title'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.t('kingdoms_subtitle'), style: const TextStyle(color: Colors.black54)),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: CurriculumData.grades
                      .map((grade) => _KingdomCard(grade: grade))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: Text(t.t('upgrade_button')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KingdomCard extends StatelessWidget {
  final GradeDef grade;
  const _KingdomCard({required this.grade});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = context.l10n;
    final totalLevels = grade.allLevels.length;
    final completedLevels =
        grade.allLevels.where((l) => appState.completedLevelIds.contains(l.id)).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RealmMapScreen(grade: grade)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: grade.color, shape: BoxShape.circle),
                child: Icon(grade.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.t(grade.titleKey), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(t.t(grade.ageKey), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: totalLevels == 0 ? 0 : completedLevels / totalLevels,
                        minHeight: 8,
                        backgroundColor: Colors.black12,
                        valueColor: AlwaysStoppedAnimation(grade.color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _MathMomentBanner extends StatelessWidget {
  const _MathMomentBanner();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final appState = context.watch<AppState>();
    final available = appState.mathMomentAvailableToday;

    return Card(
      color: NumeriaColors.yellow.withOpacity(0.25),
      child: ListTile(
        leading: const Text('🌞', style: TextStyle(fontSize: 26)),
        title: Text(t.t('math_moment_card_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          available ? t.t('math_moment_card_subtitle_available') : t.t('math_moment_card_subtitle_done'),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black38),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MathMomentScreen()),
        ),
      ),
    );
  }
}

class _QuickFeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickFeatureButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
