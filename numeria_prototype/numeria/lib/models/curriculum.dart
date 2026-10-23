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

/// How a level's questions are presented, independent of *what* they ask
/// about ([TopicType]). Added in response to competitor research (Prodigy,
/// SplashLearn, DoodleMaths all vary their interaction style, not just
/// multiple choice) — see Section 7 of the design document.
enum QuestionKind {
  /// The original four-button format.
  multipleChoice,

  /// A statement is shown ("4 + 3 = 8") and the child taps True or False.
  trueFalse,

  /// The child types the numeric answer instead of picking from choices —
  /// a bigger challenge, reserved for later tiers.
  typedInput,

  /// A standalone tap-to-match puzzle (prompts on one side, answers on the
  /// other) rendered by its own screen rather than the usual question loop.
  matching,
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
  final QuestionKind kind;

  const LevelDef({
    required this.id,
    this.titleKey = '',
    this.topicLabelKey,
    this.tierNumber = 1,
    required this.topic,
    required this.maxValue,
    this.questionCount = 20,
    this.prerequisiteIds = const [],
    this.isBoss = false,
    this.kind = QuestionKind.multipleChoice,
  });

  /// Resolves the on-screen title for this level in the current locale.
  String displayTitle(AppLocalizations t) {
    final labelKey = topicLabelKey;
    if (labelKey != null) {
      final topicName = t.t(labelKey);
      if (kind == QuestionKind.matching) {
        return t.t('level_match_title', {'topic': topicName});
      }
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
