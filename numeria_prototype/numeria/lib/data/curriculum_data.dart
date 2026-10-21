import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/curriculum.dart';

/// Sample curriculum content for the prototype (Phase 0 scope from the
/// design document: Grade 1–2 sample content). In production this would
/// be data-driven (versioned JSON served from the backend) so curriculum
/// writers and translators can update it without shipping app releases —
/// see Section 11.2 of the design document.
class CurriculumData {
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
        levels: const [
          LevelDef(
            id: 'g1_add_1',
            titleKey: 'level_addition_5',
            topic: TopicType.addition,
            maxValue: 5,
            prerequisiteIds: ['g1_counting_3'],
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
        levels: const [
          LevelDef(
            id: 'g2_mult_1',
            titleKey: 'level_multiplication_5',
            topic: TopicType.multiplication,
            maxValue: 5,
            prerequisiteIds: ['g2_sub_1'],
          ),
          LevelDef(
            id: 'g2_mult_2',
            titleKey: 'level_multiplication_10_boss',
            topic: TopicType.multiplication,
            maxValue: 10,
            prerequisiteIds: ['g2_mult_1'],
            isBoss: true,
          ),
        ],
      ),
    ],
  );

  static final List<GradeDef> grades = [grade1, grade2];
}
