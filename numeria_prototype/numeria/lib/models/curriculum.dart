import 'package:flutter/material.dart';

/// The kinds of practice questions the prototype's question generator
/// (see lib/logic/question_generator.dart) knows how to produce.
enum TopicType { counting, addition, subtraction, multiplication, compare }

/// A single playable level inside a Realm.
class LevelDef {
  final String id;
  final String titleKey;
  final TopicType topic;
  final int maxValue;
  final int questionCount;
  final List<String> prerequisiteIds;
  final bool isBoss;

  const LevelDef({
    required this.id,
    required this.titleKey,
    required this.topic,
    required this.maxValue,
    this.questionCount = 5,
    this.prerequisiteIds = const [],
    this.isBoss = false,
  });
}

/// A themed unit of levels within a Grade ("Kingdom"), matching the
/// Realm concept from Section 5.2 of the design document.
class RealmDef {
  final String id;
  final String titleKey;
  final Color color;
  final List<LevelDef> levels;

  const RealmDef({
    required this.id,
    required this.titleKey,
    required this.color,
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
