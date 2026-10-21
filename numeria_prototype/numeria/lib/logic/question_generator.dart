import 'dart:math';
import '../l10n/app_localizations.dart';
import '../models/curriculum.dart';

/// A single multiple-choice practice question.
class MathQuestion {
  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final String hint;

  const MathQuestion({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    required this.hint,
  });
}

/// Procedurally generates practice questions for a given [TopicType] and
/// difficulty ceiling. This mirrors the "data-driven content" approach from
/// Section 11.2 of the design document: in production, curriculum writers
/// would author question templates and this generator would fill them in
/// with numbers appropriate to the child's mastery level.
class QuestionGenerator {
  static final Random _rng = Random();

  static MathQuestion generate(TopicType topic, int maxValue, AppLocalizations t) {
    switch (topic) {
      case TopicType.counting:
        return _counting(maxValue, t);
      case TopicType.addition:
        return _addition(maxValue, t);
      case TopicType.subtraction:
        return _subtraction(maxValue, t);
      case TopicType.multiplication:
        return _multiplication(maxValue, t);
      case TopicType.compare:
        return _compare(maxValue, t);
    }
  }

  static MathQuestion _addition(int maxValue, AppLocalizations t) {
    final safeMax = maxValue < 2 ? 2 : maxValue;
    final a = 1 + _rng.nextInt(safeMax - 1); // a in [1, safeMax-1]
    final b = 1 + _rng.nextInt(safeMax - a); // b in [1, safeMax-a]
    final correct = a + b;
    return MathQuestion(
      prompt: "$a + $b = ?",
      choices: _choices(correct, spread: max(3, maxValue ~/ 4)),
      correctIndex: 0, // placeholder, overwritten below
      hint: t.t('mascot_hint_addition', {'a': a, 'b': b}),
    )._withShuffledChoices(correct);
  }

  static MathQuestion _subtraction(int maxValue, AppLocalizations t) {
    final a = 1 + _rng.nextInt(maxValue);
    final b = _rng.nextInt(a + 1);
    final correct = a - b;
    return MathQuestion(
      prompt: "$a − $b = ?",
      choices: _choices(correct, spread: max(3, maxValue ~/ 4)),
      correctIndex: 0,
      hint: t.t('mascot_hint_subtraction', {'a': a, 'b': b}),
    )._withShuffledChoices(correct);
  }

  static MathQuestion _multiplication(int maxTable, AppLocalizations t) {
    final a = 1 + _rng.nextInt(maxTable);
    final b = 1 + _rng.nextInt(maxTable);
    final correct = a * b;
    return MathQuestion(
      prompt: "$a × $b = ?",
      choices: _choices(correct, spread: max(4, maxTable)),
      correctIndex: 0,
      hint: t.t('mascot_hint_multiplication', {'a': a, 'b': b}),
    )._withShuffledChoices(correct);
  }

  static MathQuestion _counting(int maxValue, AppLocalizations t) {
    final correct = 1 + _rng.nextInt(maxValue);
    final stars = '⭐' * correct;
    return MathQuestion(
      prompt: stars,
      choices: _choices(correct, spread: max(3, maxValue ~/ 5)),
      correctIndex: 0,
      hint: t.t('mascot_hint_counting'),
    )._withShuffledChoices(correct);
  }

  static MathQuestion _compare(int maxValue, AppLocalizations t) {
    final a = 1 + _rng.nextInt(maxValue);
    var b = 1 + _rng.nextInt(maxValue);
    while (b == a) {
      b = 1 + _rng.nextInt(maxValue);
    }
    final correct = a > b ? a : b;
    final options = [a, b]..shuffle(_rng);
    final labels = options.map((n) => '$n').toList();
    final correctIndex = options.indexOf(correct);
    return MathQuestion(
      prompt: '$a … $b',
      choices: labels,
      correctIndex: correctIndex,
      hint: t.t('mascot_hint_compare'),
    );
  }

  /// Builds four unique distractor choices around [correct], returned in
  /// an arbitrary (not-yet-shuffled) order; callers that need the final
  /// shuffled order + correct index use [_withShuffledChoices].
  static List<String> _choices(int correct, {int spread = 5}) {
    final options = <int>{correct};
    while (options.length < 4) {
      final delta = 1 + _rng.nextInt(spread);
      final candidate = _rng.nextBool() ? correct + delta : correct - delta;
      if (candidate >= 0) options.add(candidate);
    }
    return options.map((n) => '$n').toList();
  }
}

extension _ShuffleChoices on MathQuestion {
  MathQuestion _withShuffledChoices(int correctValue) {
    final shuffled = [...choices]..shuffle(QuestionGenerator._rng);
    final correctIndex = shuffled.indexOf('$correctValue');
    return MathQuestion(
      prompt: prompt,
      choices: shuffled,
      correctIndex: correctIndex,
      hint: hint,
    );
  }
}
