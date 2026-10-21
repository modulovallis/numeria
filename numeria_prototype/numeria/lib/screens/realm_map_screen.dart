import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';
import '../widgets/level_node.dart';
import 'level_screen.dart';
import 'paywall_screen.dart';

/// The Realm Map — a Kingdom (Grade) broken into themed Realms (topic
/// units), each containing a chain of Levels that unlock in order as the
/// child demonstrates mastery. See Section 5.2 of the design document.
class RealmMapScreen extends StatelessWidget {
  final GradeDef grade;
  const RealmMapScreen({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(t.t(grade.titleKey))),
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  t.t('realm_map_subtitle'),
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: grade.realms.map((realm) => _RealmSection(realm: realm)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RealmSection extends StatelessWidget {
  final RealmDef realm;
  const _RealmSection({required this.realm});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: realm.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(t.t(realm.titleKey), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: realm.levels.map((level) {
                final unlocked = appState.isLevelUnlocked(level.prerequisiteIds);
                final completed = appState.completedLevelIds.contains(level.id);
                return LevelNode(
                  level: level,
                  unlocked: unlocked,
                  completed: completed,
                  color: realm.color,
                  onTap: () => _openLevel(context, level, realm.color),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _openLevel(BuildContext context, LevelDef level, Color color) {
    final appState = context.read<AppState>();
    if (appState.freeDailyCapReached) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen(fromDailyLimit: true)),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LevelScreen(level: level, themeColor: color)),
    );
  }
}
