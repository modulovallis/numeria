import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// The kinds of practice questions the prototype's question generator
/// (see lib/logic/question_generator.dart) knows how to produce. Grades 1-2
/// use the first five; grades 3-6 (up to age ~12) layer on the rest so kids
/// can practice everything from times tables to early algebra and geometry.
enum TopicType {
  counting,
  addition,
  subtraction,
  multiplication,
  compare,
  division,
  fractions,
  decimals,
  algebra,
  geometry,
  measurement,
  dataProbability,
}

/// A single playable level inside a Realm.
///
/// Two ways to title a level:
/// - Hand-authored content (Grade 1-2) sets [titleKey] to a specific,
///   flavorful translation key (e.g. "Addition Champion").
/// - Procedurally-listed content (Grade 3-6) leaves [titleKey] blank and
///   instead sets [topicLabelKey] (reusing the parent Realm's own title
///   key) plus [tierNumber]; the display title is then composed from the
///   generic "Level N" / "Boss" templates in [displayTitle]. This keeps a
///   single flat string-lookup localization system (see
///   lib/l10n/app_localizations.dart) scalable to many grades without
///   needing a unique translated string per level.
class LevelDef {
  final String id;
  final String titleKey;
  final String? topicLabelKey;
  final int tierNumber;
  final TopicType topic;
  final int maxValue;
  final int questionCount;
  final List<String> prerequisiteIds;
  final bool isBoss;

  const LevelDef({
    required this.id,
    this.titleKey = '',
    this.topicLabelKey,
    this.tierNumber = 1,
    required this.topic,
    required this.maxValue,
    this.questionCount = 5,
    this.prerequisiteIds = const [],
    this.isBoss = false,
  });

  /// Resolves the on-screen title for this level in the current locale.
  String displayTitle(AppLocalizations t) {
    final labelKey = topicLabelKey;
    if (labelKey != null) {
      final topicName = t.t(labelKey);
      return isBoss
          ? t.t('level_boss_title', {'topic': topicName})
          : t.t('level_tier_title', {'topic': topicName, 'n': tierNumber});
    }
    return t.t(titleKey);
  }
}

/// A themed unit of levels within a Grade ("Kingdom"), matching the
/// Realm concept from Section 5.2 of the design document. Every Realm is
/// reachable independently of the others in its Grade — a child chooses
/// both *which grade* and *which type of exercise* to practice.
class RealmDef {
  final String id;
  final String titleKey;
  final Color color;
  final IconData icon;
  final List<LevelDef> levels;

  const RealmDef({
    required this.id,
    required this.titleKey,
    required this.color,
    this.icon = Icons.extension_rounded,
    required this.levels,
  });
}

/// A full grade, presented on the map as a "Kingdom".
class GradeDef {
  final String id;
  final String titleKey;
  final String ageKey;
  final Color color;
  final IconData icon;
  final List<RealmDef> realms;

  const GradeDef({
    required this.id,
    required this.titleKey,
    required this.ageKey,
    required this.color,
    required this.icon,
    required this.realms,
  });

  List<LevelDef> get allLevels => realms.expand((r) => r.levels).toList();
}
