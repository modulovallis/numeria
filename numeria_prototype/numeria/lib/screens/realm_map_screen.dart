import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';
import 'level_list_screen.dart';

/// The Strand Select screen — after choosing a Kingdom (Grade), the child
/// picks *which type of exercise* to practice (additions, subtractions,
/// fractions, geometry, ...). See Section 5.2 of the design document. This
/// screen directly implements the "choose grade AND exercise type" ask:
/// every strand card below is reachable on its own, independent of the
/// others, so a child who wants more subtraction practice today isn't
/// blocked by, say, geometry.
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.t('realm_map_subtitle'),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children:
                      grade.realms.map((realm) => _StrandCard(grade: grade, realm: realm)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrandCard extends StatelessWidget {
  final GradeDef grade;
  final RealmDef realm;
  const _StrandCard({required this.grade, required this.realm});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = context.l10n;
    final total = realm.levels.length;
    final done = realm.levels.where((l) => appState.completedLevelIds.contains(l.id)).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LevelListScreen(grade: grade, realm: realm)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: realm.color, shape: BoxShape.circle),
                child: Icon(realm.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.t(realm.titleKey), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        minHeight: 7,
                        backgroundColor: Colors.black12,
                        valueColor: AlwaysStoppedAnimation(realm.color),
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
