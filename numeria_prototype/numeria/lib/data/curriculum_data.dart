import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../logic/question_generator.dart';
import '../models/curriculum.dart';

/// Curriculum content for the prototype, spanning Grade 1 through Grade 6
/// (roughly ages 6–12, the "primary school" range from the brief). In
/// production this would be data-driven (versioned JSON served from the
/// backend) so curriculum writers and translators can update it without
/// shipping app releases — see Section 11.2 of the design document.
///
/// Every Realm (exercise type) inside a Grade is reachable independently —
/// a child picks both the Grade *and* which type of exercise to practice,
/// rather than being forced down one linear path.
class CurriculumData {
  /// Builds a simple tiered chain of levels for one strand: level 1 is the
  /// easiest, each subsequent level needs the previous one, and the last
  /// tier is always the "boss" level for that strand. Each tier also gets
  /// an automatically-chosen [QuestionKind] via [_kindFor] so a strand
  /// naturally mixes multiple choice, True/False and typed-answer
  /// questions instead of staying one format end to end — see Section 7 of
  /// the design document and the competitor research behind this update
  /// (Prodigy/SplashLearn/DoodleMaths all vary interaction style).
  static List<LevelDef> _tiers({
    required String idPrefix,
    required TopicType topic,
    required String topicLabelKey,
    required List<int> maxValues,
    List<String> firstPrerequisites = const [],
    int questionCount = 20,
  }) {
    final levels = <LevelDef>[];
    for (var i = 0; i < maxValues.length; i++) {
      final isLast = i == maxValues.length - 1;
      levels.add(LevelDef(
        id: '${idPrefix}_${i + 1}',
        topic: topic,
        topicLabelKey: topicLabelKey,
        tierNumber: i + 1,
        maxValue: maxValues[i],
        questionCount: questionCount,
        isBoss: isLast,
        kind: _kindFor(topic, i, maxValues.length),
        prerequisiteIds: i == 0 ? firstPrerequisites : ['${idPrefix}_$i'],
      ));
    }
    return levels;
  }

  /// Picks the interaction style for one tier of a strand: the final
  /// ("boss") tier becomes a typed-answer challenge when the topic's
  /// answers are plain numbers, the middle tier becomes a True/False
  /// round when the topic's prompt shape supports it, and every other
  /// tier (including the always-safe first, easiest tier) stays multiple
  /// choice.
  static QuestionKind _kindFor(TopicType topic, int tierIndex, int tierCount) {
    final isLast = tierIndex == tierCount - 1;
    if (isLast && QuestionGenerator.typedInputSafeTopics.contains(topic)) {
      return QuestionKind.typedInput;
    }
    if (tierIndex == 1 && QuestionGenerator.trueFalseSafeTopics.contains(topic)) {
      return QuestionKind.trueFalse;
    }
    return QuestionKind.multipleChoice;
  }

  /// A bonus, always-replayable tap-to-match level appended after a
  /// strand's normal tiers — only needs the strand's first tier completed
  /// to unlock, since it's a fun variant rather than another difficulty
  /// step.
  static LevelDef _matchBonus({
    required String idPrefix,
    required TopicType topic,
    required String topicLabelKey,
    required int maxValue,
  }) {
    return LevelDef(
      id: '${idPrefix}_match',
      topic: topic,
      topicLabelKey: topicLabelKey,
      tierNumber: 0,
      maxValue: maxValue,
      questionCount: 6, // pair count for the matching puzzle (12 cards fits one screen)
      kind: QuestionKind.matching,
      prerequisiteIds: ['${idPrefix}_1'],
    );
  }

  // ---------------------------------------------------------------------
  // Grade 1 — Meadow Village (ages 6-7)
  // ---------------------------------------------------------------------
  static final GradeDef grade1 = GradeDef(
    id: 'g1',
    titleKey: 'grade1_title',
    ageKey: 'grade1_age',
    color: NumeriaColors.green,
    icon: Icons.park_rounded,
    realms: [
      RealmDef(
        id: 'g1_counting',
        titleKey: 'realm_counting_meadow',
        color: NumeriaColors.yellow,
        icon: Icons.looks_one_rounded,
        levels: const [
          LevelDef(
            id: 'g1_counting_1',
            titleKey: 'level_counting_10',
            topic: TopicType.counting,
            maxValue: 10,
          ),
          LevelDef(
            id: 'g1_counting_2',
            titleKey: 'level_counting_20',
            topic: TopicType.counting,
            maxValue: 20,
            prerequisiteIds: ['g1_counting_1'],
          ),
          LevelDef(
            id: 'g1_counting_3',
            titleKey: 'level_compare_numbers',
            topic: TopicType.compare,
            maxValue: 20,
            prerequisiteIds: ['g1_counting_2'],
            isBoss: true,
          ),
        ],
      ),
      RealmDef(
        id: 'g1_addition',
        titleKey: 'realm_addition_grove',
        color: NumeriaColors.orange,
        icon: Icons.add_rounded,
        levels: const [
          LevelDef(
            // Freely choosable like every other strand — no cross-realm
            // prerequisite — so a child can jump straight into addition.
            id: 'g1_add_1',
            titleKey: 'level_addition_5',
            topic: TopicType.addition,
            maxValue: 5,
          ),
          LevelDef(
            id: 'g1_add_2',
            titleKey: 'level_addition_10',
            topic: TopicType.addition,
            maxValue: 10,
            prerequisiteIds: ['g1_add_1'],
          ),
          LevelDef(
            id: 'g1_add_3',
            titleKey: 'level_addition_20_boss',
            topic: TopicType.addition,
            maxValue: 20,
            prerequisiteIds: ['g1_add_2'],
            isBoss: true,
          ),
        ],
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // Grade 2 — Candy Caverns (ages 7-8)
  // ---------------------------------------------------------------------
  static final GradeDef grade2 = GradeDef(
    id: 'g2',
    titleKey: 'grade2_title',
    ageKey: 'grade2_age',
    color: NumeriaColors.purple,
    icon: Icons.icecream_rounded,
    realms: [
      RealmDef(
        id: 'g2_place_value',
        titleKey: 'realm_place_value_mines',
        color: NumeriaColors.blue,
        icon: Icons.calculate_rounded,
        levels: const [
          LevelDef(
            id: 'g2_add_1',
            titleKey: 'level_addition_100',
            topic: TopicType.addition,
            maxValue: 100,
          ),
          LevelDef(
            id: 'g2_sub_1',
            titleKey: 'level_subtraction_100',
            topic: TopicType.subtraction,
            maxValue: 100,
            prerequisiteIds: ['g2_add_1'],
          ),
        ],
      ),
      RealmDef(
        id: 'g2_multiplication',
        titleKey: 'realm_multiplication_sparkle',
        color: NumeriaColors.pink,
        icon: Icons.close_rounded,
        levels: [
          const LevelDef(
            // Freely choosable — doesn't require finishing Place Value
            // Mines first, so multiplication is always one tap away.
            id: 'g2_mult_1',
            titleKey: 'level_multiplication_5',
            topic: TopicType.multiplication,
            maxValue: 5,
          ),
          const LevelDef(
            id: 'g2_mult_2',
            titleKey: 'level_multiplication_10_boss',
            topic: TopicType.multiplication,
            maxValue: 10,
            prerequisiteIds: ['g2_mult_1'],
            isBoss: true,
          ),
          _matchBonus(
            idPrefix: 'g2_mult',
            topic: TopicType.multiplication,
            topicLabelKey: 'realm_multiplication_sparkle',
            maxValue: 5,
          ),
        ],
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // Grade 3 — Puzzle Peaks (ages 8-9)
  // ---------------------------------------------------------------------
  static final GradeDef grade3 = GradeDef(
    id: 'g3',
    titleKey: 'grade3_title',
    ageKey: 'grade3_age',
    color: NumeriaColors.orange,
    icon: Icons.terrain_rounded,
    realms: [
      RealmDef(
        id: 'g3_subtraction',
        titleKey: 'realm_subtraction_swamp',
        color: NumeriaColors.blue,
        icon: Icons.remove_rounded,
        levels: _tiers(
          idPrefix: 'g3_sub',
          topic: TopicType.subtraction,
          topicLabelKey: 'realm_subtraction_swamp',
          maxValues: const [100, 500, 999],
        ),
      ),
      RealmDef(
        id: 'g3_multiplication',
        titleKey: 'realm_multiplication_sparkle',
        color: NumeriaColors.pink,
        icon: Icons.close_rounded,
        levels: [
          ..._tiers(
            idPrefix: 'g3_mult',
            topic: TopicType.multiplication,
            topicLabelKey: 'realm_multiplication_sparkle',
            maxValues: const [6, 10, 12],
          ),
          _matchBonus(
            idPrefix: 'g3_mult',
            topic: TopicType.multiplication,
            topicLabelKey: 'realm_multiplication_sparkle',
            maxValue: 10,
          ),
        ],
      ),
      RealmDef(
        id: 'g3_division',
        titleKey: 'realm_division_docks',
        color: NumeriaColors.teal,
        icon: Icons.call_split_rounded,
        levels: _tiers(
          idPrefix: 'g3_div',
          topic: TopicType.division,
          topicLabelKey: 'realm_division_docks',
          maxValues: const [5, 8, 10],
        ),
      ),
      RealmDef(
        id: 'g3_fractions',
        titleKey: 'realm_fractions_falls',
        color: NumeriaColors.purple,
        icon: Icons.pie_chart_rounded,
        levels: [
          ..._tiers(
            idPrefix: 'g3_frac',
            topic: TopicType.fractions,
            topicLabelKey: 'realm_fractions_falls',
            maxValues: const [4, 6, 8],
          ),
          _matchBonus(
            idPrefix: 'g3_frac',
            topic: TopicType.fractions,
            topicLabelKey: 'realm_fractions_falls',
            maxValue: 6,
          ),
        ],
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // Grade 4 — Starlight Summit (ages 9-10)
  // ---------------------------------------------------------------------
  static final GradeDef grade4 = GradeDef(
    id: 'g4',
    titleKey: 'grade4_title',
    ageKey: 'grade4_age',
    color: NumeriaColors.blue,
    icon: Icons.auto_awesome_rounded,
    realms: [
      RealmDef(
        id: 'g4_multiplication',
        titleKey: 'realm_multiplication_sparkle',
        color: NumeriaColors.pink,
        icon: Icons.close_rounded,
        levels: [
          ..._tiers(
            idPrefix: 'g4_mult',
            topic: TopicType.multiplication,
            topicLabelKey: 'realm_multiplication_sparkle',
            maxValues: const [12, 15, 20],
          ),
          _matchBonus(
            idPrefix: 'g4_mult',
            topic: TopicType.multiplication,
            topicLabelKey: 'realm_multiplication_sparkle',
            maxValue: 12,
          ),
        ],
      ),
      RealmDef(
        id: 'g4_division',
        titleKey: 'realm_division_docks',
        color: NumeriaColors.teal,
        icon: Icons.call_split_rounded,
        levels: _tiers(
          idPrefix: 'g4_div',
          topic: TopicType.division,
          topicLabelKey: 'realm_division_docks',
          maxValues: const [10, 12, 15],
        ),
      ),
      RealmDef(
        id: 'g4_fractions',
        titleKey: 'realm_fractions_falls',
        color: NumeriaColors.purple,
        icon: Icons.pie_chart_rounded,
        levels: [
          ..._tiers(
            idPrefix: 'g4_frac',
            topic: TopicType.fractions,
            topicLabelKey: 'realm_fractions_falls',
            maxValues: const [8, 10, 12],
          ),
          _matchBonus(
            idPrefix: 'g4_frac',
            topic: TopicType.fractions,
            topicLabelKey: 'realm_fractions_falls',
            maxValue: 10,
          ),
        ],
      ),
      RealmDef(
        id: 'g4_decimals',
        titleKey: 'realm_decimals_dunes',
        color: NumeriaColors.yellow,
        icon: Icons.numbers_rounded,
        levels: _tiers(
          idPrefix: 'g4_dec',
          topic: TopicType.decimals,
          topicLabelKey: 'realm_decimals_dunes',
          maxValues: const [10, 50, 100],
        ),
      ),
      RealmDef(
        id: 'g4_geometry',
        titleKey: 'realm_geometry_galaxy',
        color: NumeriaColors.green,
        icon: Icons.change_history_rounded,
        levels: _tiers(
          idPrefix: 'g4_geo',
          topic: TopicType.geometry,
          topicLabelKey: 'realm_geometry_galaxy',
          maxValues: const [6, 10, 15],
        ),
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // Grade 5 — Mystic Harbor (ages 10-11)
  // ---------------------------------------------------------------------
  static final GradeDef grade5 = GradeDef(
    id: 'g5',
    titleKey: 'grade5_title',
    ageKey: 'grade5_age',
    color: NumeriaColors.pink,
    icon: Icons.anchor_rounded,
    realms: [
      RealmDef(
        id: 'g5_fractions',
        titleKey: 'realm_fractions_falls',
        color: NumeriaColors.purple,
        icon: Icons.pie_chart_rounded,
        levels: [
          ..._tiers(
            idPrefix: 'g5_frac',
            topic: TopicType.fractions,
            topicLabelKey: 'realm_fractions_falls',
            maxValues: const [10, 15, 20],
          ),
          _matchBonus(
            idPrefix: 'g5_frac',
            topic: TopicType.fractions,
            topicLabelKey: 'realm_fractions_falls',
            maxValue: 12,
          ),
        ],
      ),
      RealmDef(
        id: 'g5_decimals',
        titleKey: 'realm_decimals_dunes',
        color: NumeriaColors.yellow,
        icon: Icons.numbers_rounded,
        levels: _tiers(
          idPrefix: 'g5_dec',
          topic: TopicType.decimals,
          topicLabelKey: 'realm_decimals_dunes',
          maxValues: const [50, 100, 200],
        ),
      ),
      RealmDef(
        id: 'g5_algebra',
        titleKey: 'realm_algebra_arcade',
        color: NumeriaColors.orange,
        icon: Icons.functions_rounded,
        levels: _tiers(
          idPrefix: 'g5_alg',
          topic: TopicType.algebra,
          topicLabelKey: 'realm_algebra_arcade',
          maxValues: const [10, 20, 30],
        ),
      ),
      RealmDef(
        id: 'g5_geometry',
        titleKey: 'realm_geometry_galaxy',
        color: NumeriaColors.green,
        icon: Icons.change_history_rounded,
        levels: _tiers(
          idPrefix: 'g5_geo',
          topic: TopicType.geometry,
          topicLabelKey: 'realm_geometry_galaxy',
          maxValues: const [10, 15, 20],
        ),
      ),
      RealmDef(
        id: 'g5_measurement',
        titleKey: 'realm_measurement_mountain',
        color: NumeriaColors.teal,
        icon: Icons.straighten_rounded,
        levels: _tiers(
          idPrefix: 'g5_meas',
          topic: TopicType.measurement,
          topicLabelKey: 'realm_measurement_mountain',
          maxValues: const [5, 10, 15],
        ),
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // Grade 6 — Infinity Isles (ages 11-12)
  // ---------------------------------------------------------------------
  static final GradeDef grade6 = GradeDef(
    id: 'g6',
    titleKey: 'grade6_title',
    ageKey: 'grade6_age',
    color: NumeriaColors.teal,
    icon: Icons.all_inclusive_rounded,
    realms: [
      RealmDef(
        id: 'g6_algebra',
        titleKey: 'realm_algebra_arcade',
        color: NumeriaColors.orange,
        icon: Icons.functions_rounded,
        levels: _tiers(
          idPrefix: 'g6_alg',
          topic: TopicType.algebra,
          topicLabelKey: 'realm_algebra_arcade',
          maxValues: const [20, 40, 60],
        ),
      ),
      RealmDef(
        id: 'g6_geometry',
        titleKey: 'realm_geometry_galaxy',
        color: NumeriaColors.green,
        icon: Icons.change_history_rounded,
        levels: _tiers(
          idPrefix: 'g6_geo',
          topic: TopicType.geometry,
          topicLabelKey: 'realm_geometry_galaxy',
          maxValues: const [15, 25, 35],
        ),
      ),
      RealmDef(
        id: 'g6_fractions',
        titleKey: 'realm_fractions_falls',
        color: NumeriaColors.purple,
        icon: Icons.pie_chart_rounded,
        levels: [
          ..._tiers(
            idPrefix: 'g6_frac',
            topic: TopicType.fractions,
            topicLabelKey: 'realm_fractions_falls',
            maxValues: const [15, 25, 35],
          ),
          _matchBonus(
            idPrefix: 'g6_frac',
            topic: TopicType.fractions,
            topicLabelKey: 'realm_fractions_falls',
            maxValue: 15,
          ),
        ],
      ),
      RealmDef(
        id: 'g6_decimals',
        titleKey: 'realm_decimals_dunes',
        color: NumeriaColors.yellow,
        icon: Icons.numbers_rounded,
        levels: _tiers(
          idPrefix: 'g6_dec',
          topic: TopicType.decimals,
          topicLabelKey: 'realm_decimals_dunes',
          maxValues: const [100, 300, 500],
        ),
      ),
      RealmDef(
        id: 'g6_measurement',
        titleKey: 'realm_measurement_mountain',
        color: NumeriaColors.teal,
        icon: Icons.straighten_rounded,
        levels: _tiers(
          idPrefix: 'g6_meas',
          topic: TopicType.measurement,
          topicLabelKey: 'realm_measurement_mountain',
          maxValues: const [10, 20, 30],
        ),
      ),
      RealmDef(
        id: 'g6_data',
        titleKey: 'realm_data_den',
        color: NumeriaColors.blue,
        icon: Icons.bar_chart_rounded,
        levels: _tiers(
          idPrefix: 'g6_data',
          topic: TopicType.dataProbability,
          topicLabelKey: 'realm_data_den',
          maxValues: const [10, 20, 30],
        ),
      ),
    ],
  );

  static final List<GradeDef> grades = [grade1, grade2, grade3, grade4, grade5, grade6];
}
