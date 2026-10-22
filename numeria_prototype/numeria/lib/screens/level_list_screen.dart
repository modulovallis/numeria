import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';
import '../widgets/level_node.dart';
import 'level_screen.dart';
import 'paywall_screen.dart';

/// Shows every level inside a single chosen strand (exercise type), as a
/// chain of unlockable nodes — see Section 5.2 of the design document.
class LevelListScreen extends StatelessWidget {
  final GradeDef grade;
  final RealmDef realm;
  const LevelListScreen({super.key, required this.grade, required this.realm});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(t.t(realm.titleKey))),
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 18,
              runSpacing: 18,
              children: realm.levels.map((level) {
                final unlocked = appState.isLevelUnlocked(level.prerequisiteIds);
                final completed = appState.completedLevelIds.contains(level.id);
                return LevelNode(
                  level: level,
                  unlocked: unlocked,
                  completed: completed,
                  color: realm.color,
                  onTap: () => _openLevel(context, level),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _openLevel(BuildContext context, LevelDef level) {
    final appState = context.read<AppState>();
    if (appState.freeDailyCapReached) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen(fromDailyLimit: true)),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LevelScreen(level: level, themeColor: realm.color)),
    );
  }
}
