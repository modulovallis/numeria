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
/// A True/False statement derived from a regular [MathQuestion] — see
/// [QuestionGenerator.generateTrueFalse].
class TrueFalseQuestion {
  final String statement;
  final bool isTrue;
  final String hint;

  const TrueFalseQuestion({required this.statement, required this.isTrue, required this.hint});
}

/// One prompt/answer pair for the tap-to-match puzzle (see
/// [QuestionGenerator.generateMatchingPairs] and MatchingLevelScreen).
class MatchPair {
  final String promptLabel;
  final String answerLabel;

  const MatchPair({required this.promptLabel, required this.answerLabel});
}

class QuestionGenerator {
  static final Random _rng = Random();

  /// Topics whose prompt is always exactly "... = ?" — safe to turn into a
  /// True/False statement by substituting a value for the trailing "?".
  /// Topics with full-sentence prompts (geometry, measurement, data,
  /// algebra's bare "x + b = c") are deliberately excluded since the
  /// substitution trick would corrupt their wording.
  static const Set<TopicType> trueFalseSafeTopics = {
    TopicType.addition,
    TopicType.subtraction,
    TopicType.multiplication,
    TopicType.division,
    TopicType.fractions,
    TopicType.decimals,
  };

  /// Topics whose correct answer is always a single plain number (not a
  /// fraction/decimal string), so a numeric keypad can check it exactly.
  static const Set<TopicType> typedInputSafeTopics = {
    TopicType.counting,
    TopicType.addition,
    TopicType.subtraction,
    TopicType.multiplication,
    TopicType.division,
    TopicType.algebra,
    TopicType.geometry,
    TopicType.measurement,
    TopicType.dataProbability,
  };

  /// Derives a True/False statement from a freshly generated question by
  /// substituting either the correct answer (statement is true) or a
  /// distractor (statement is false) for the question's trailing "?".
  /// Only call this for a topic in [trueFalseSafeTopics].
  static TrueFalseQuestion generateTrueFalse(TopicType topic, int maxValue, AppLocalizations t) {
    final mc = generate(topic, maxValue, t);
    final correctAnswer = mc.choices[mc.correctIndex];
    final showCorrect = _rng.nextBool();
    final shownAnswer = showCorrect
        ? correctAnswer
        : mc.choices.firstWhere((c) => c != correctAnswer, orElse: () => correctAnswer);
    final statement = mc.prompt.replaceFirst('?', shownAnswer);
    return TrueFalseQuestion(statement: statement, isTrue: showCorrect, hint: mc.hint);
  }

  /// Generates [pairCount] unique prompt/answer pairs for the matching
  /// puzzle, reusing the normal question generator for content and
  /// discarding any accidental duplicate prompt or answer so every card on
  /// screen is distinct.
  static List<MatchPair> generateMatchingPairs(
    TopicType topic,
    int maxValue,
    int pairCount,
    AppLocalizations t,
  ) {
    final pairs = <MatchPair>[];
    final seenPrompts = <String>{};
    final seenAnswers = <String>{};
    var attempts = 0;
    while (pairs.length < pairCount && attempts < pairCount * 20) {
      attempts++;
      final q = generate(topic, maxValue, t);
      final answer = q.choices[q.correctIndex];
      if (seenPrompts.contains(q.prompt) || seenAnswers.contains(answer)) continue;
      seenPrompts.add(q.prompt);
      seenAnswers.add(answer);
      pairs.add(MatchPair(promptLabel: q.prompt, answerLabel: answer));
    }
    return pairs;
  }

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
      case TopicType.division:
        return _division(maxValue, t);
      case TopicType.fractions:
        return _fractions(maxValue, t);
      case TopicType.decimals:
        return _decimals(maxValue, t);
      case TopicType.algebra:
        return _algebra(maxValue, t);
      case TopicType.geometry:
        return _geometry(maxValue, t);
      case TopicType.measurement:
        return _measurement(maxValue, t);
      case TopicType.dataProbability:
        return _dataProbability(maxValue, t);
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

  static MathQuestion _division(int maxValue, AppLocalizations t) {
    final safeMax = maxValue < 2 ? 2 : maxValue;
    final divisor = 2 + _rng.nextInt(min(10, safeMax));
    final quotient = 1 + _rng.nextInt(safeMax);
    final dividend = divisor * quotient;
    return MathQuestion(
      prompt: "$dividend ÷ $divisor = ?",
      choices: _choices(quotient, spread: max(3, safeMax ~/ 4)),
      correctIndex: 0,
      hint: t.t('mascot_hint_division', {'dividend': dividend, 'divisor': divisor}),
    )._withShuffledChoices(quotient);
  }

  static MathQuestion _fractions(int maxValue, AppLocalizations t) {
    // Denominator needs to be at least 4 so there's room for 4 distinct
    // multiple-choice numerators in [1, den].
    final denCeiling = maxValue < 4 ? 4 : maxValue;
    final den = 4 + _rng.nextInt(min(6, denCeiling - 3));
    final n1 = 1 + _rng.nextInt(den - 1);
    var n2 = 1 + _rng.nextInt(den - 1);
    while (n1 + n2 > den) {
      n2 = 1 + _rng.nextInt(den - 1);
    }
    final correctNum = n1 + n2;
    final correctLabel = "$correctNum/$den";
    final options = <int>{correctNum};
    while (options.length < 4) {
      final delta = 1 + _rng.nextInt(3);
      final candidate = _rng.nextBool() ? correctNum + delta : correctNum - delta;
      if (candidate >= 1 && candidate <= den) options.add(candidate);
      if (options.length >= den) break; // avoid infinite loop on tiny denominators
    }
    final labels = options.map((n) => "$n/$den").toList()..shuffle(_rng);
    return MathQuestion(
      prompt: "$n1/$den + $n2/$den = ?",
      choices: labels,
      correctIndex: labels.indexOf(correctLabel),
      hint: t.t('mascot_hint_fractions', {'den': den}),
    );
  }

  static MathQuestion _decimals(int maxValue, AppLocalizations t) {
    final safeMax = maxValue < 4 ? 4 : maxValue;
    final ceilingTenths = safeMax * 10;
    final aTenths = 1 + _rng.nextInt(ceilingTenths - 2);
    final bTenths = 1 + _rng.nextInt(ceilingTenths - aTenths);
    final correctTenths = aTenths + bTenths;
    String fmt(int tenths) => (tenths / 10).toStringAsFixed(1);
    final correctLabel = fmt(correctTenths);
    final options = <int>{correctTenths};
    while (options.length < 4) {
      final delta = 1 + _rng.nextInt(5);
      final candidate = _rng.nextBool() ? correctTenths + delta : correctTenths - delta;
      if (candidate >= 0) options.add(candidate);
    }
    final labels = options.map(fmt).toList()..shuffle(_rng);
    return MathQuestion(
      prompt: "${fmt(aTenths)} + ${fmt(bTenths)} = ?",
      choices: labels,
      correctIndex: labels.indexOf(correctLabel),
      hint: t.t('mascot_hint_decimals'),
    );
  }

  static MathQuestion _algebra(int maxValue, AppLocalizations t) {
    final safeMax = maxValue < 5 ? 5 : maxValue;
    final x = 1 + _rng.nextInt(safeMax);
    final b = 1 + _rng.nextInt(safeMax);
    final c = x + b;
    return MathQuestion(
      prompt: "x + $b = $c",
      choices: _choices(x, spread: max(3, safeMax ~/ 4)),
      correctIndex: 0,
      hint: t.t('mascot_hint_algebra', {'b': b, 'c': c}),
    )._withShuffledChoices(x);
  }

  static MathQuestion _geometry(int maxValue, AppLocalizations t) {
    final safeMax = maxValue < 4 ? 4 : maxValue;
    final w = 2 + _rng.nextInt(safeMax - 1);
    final h = 2 + _rng.nextInt(safeMax - 1);
    if (_rng.nextBool()) {
      final correct = w * h;
      return MathQuestion(
        prompt: t.t('geometry_area_prompt', {'w': w, 'h': h}),
        choices: _choices(correct, spread: max(4, safeMax)),
        correctIndex: 0,
        hint: t.t('mascot_hint_geometry_area', {'w': w, 'h': h}),
      )._withShuffledChoices(correct);
    } else {
      final correct = 2 * (w + h);
      return MathQuestion(
        prompt: t.t('geometry_perimeter_prompt', {'w': w, 'h': h}),
        choices: _choices(correct, spread: max(3, safeMax ~/ 2)),
        correctIndex: 0,
        hint: t.t('mascot_hint_geometry_perimeter', {'w': w, 'h': h}),
      )._withShuffledChoices(correct);
    }
  }

  static MathQuestion _measurement(int maxValue, AppLocalizations t) {
    final safeMax = maxValue < 5 ? 5 : maxValue;
    const conversions = [
      (100, 'cm', 'm'),
      (1000, 'g', 'kg'),
      (1000, 'ml', 'l'),
      (10, 'mm', 'cm'),
    ];
    final conv = conversions[_rng.nextInt(conversions.length)];
    final factor = conv.$1;
    final fromUnit = conv.$2;
    final toUnit = conv.$3;
    final k = 1 + _rng.nextInt(safeMax);
    final value = k * factor;
    return MathQuestion(
      prompt: t.t('measurement_convert_prompt', {'value': value, 'from': fromUnit, 'to': toUnit}),
      choices: _choices(k, spread: max(3, safeMax ~/ 3)),
      correctIndex: 0,
      hint: t.t('mascot_hint_measurement', {'factor': factor, 'from': fromUnit, 'to': toUnit}),
    )._withShuffledChoices(k);
  }

  static MathQuestion _dataProbability(int maxValue, AppLocalizations t) {
    final safeMax = maxValue < 5 ? 5 : maxValue;
    final start = 1 + _rng.nextInt(safeMax);
    final step = 1 + _rng.nextInt(max(1, safeMax ~/ 5));
    final a = start;
    final b = start + step;
    final c = start + 2 * step;
    final correct = b; // mean of an arithmetic sequence is its middle value
    return MathQuestion(
      prompt: t.t('data_mean_prompt', {'a': a, 'b': b, 'c': c}),
      choices: _choices(correct, spread: max(3, step + 2)),
      correctIndex: 0,
      hint: t.t('mascot_hint_data', {'sum': a + b + c}),
    )._withShuffledChoices(correct);
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
