import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/question_generator.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';

enum _Phase { childIntro, childPlay, handoff, parentPlay, result }

/// Family Challenge (Monthly/Lifetime feature, Section 8 of the design
/// document): the child plays a short round, then hands the device to a
/// grown-up for the same number of (harder) questions, and the app
/// compares scores with a friendly, non-competitive tone.
class FamilyChallengeScreen extends StatefulWidget {
  const FamilyChallengeScreen({super.key});

  @override
  State<FamilyChallengeScreen> createState() => _FamilyChallengeScreenState();
}

class _FamilyChallengeScreenState extends State<FamilyChallengeScreen> {
  static const _questionCount = 5;

  _Phase _phase = _Phase.childIntro;
  int _index = 0;
  int _selected = -1;
  bool _answered = false;
  int _childCorrect = 0;
  int _parentCorrect = 0;
  List<MathQuestion>? _childQuestions;
  List<MathQuestion>? _parentQuestions;

  void _generateIfNeeded(AppLocalizations t) {
    _childQuestions ??= List.generate(
      _questionCount,
      (_) => QuestionGenerator.generate(TopicType.multiplication, 10, t),
    );
    _parentQuestions ??= List.generate(
      _questionCount,
      (_) => QuestionGenerator.generate(TopicType.multiplication, 100, t),
    );
  }

  void _select(int i, {required bool isParentRound}) {
    if (_answered) return;
    final questions = isParentRound ? _parentQuestions! : _childQuestions!;
    final correct = i == questions[_index].correctIndex;
    setState(() {
      _selected = i;
      _answered = true;
      if (correct) {
        if (isParentRound) {
          _parentCorrect++;
        } else {
          _childCorrect++;
        }
      }
    });
  }

  void _next({required bool isParentRound}) {
    final isLast = _index + 1 >= _questionCount;
    setState(() {
      _selected = -1;
      _answered = false;
      if (isLast) {
        _index = 0;
        _phase = isParentRound ? _Phase.result : _Phase.handoff;
      } else {
        _index++;
      }
    });
    if (isLast && isParentRound) {
      final total = _childCorrect + _parentCorrect;
      context.read<AppState>().awardBonus(xp: 15 * total, coins: 5 * total);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    _generateIfNeeded(t);

    Widget body;
    switch (_phase) {
      case _Phase.childIntro:
        body = _buildIntro(
          emoji: '🧒',
          title: t.t('family_child_turn_title'),
          buttonLabel: t.t('family_start_button'),
          onStart: () => setState(() => _phase = _Phase.childPlay),
        );
        break;
      case _Phase.childPlay:
        body = _buildQuestion(t, _childQuestions!, isParentRound: false);
        break;
      case _Phase.handoff:
        body = _buildIntro(
          emoji: '👨‍👩‍👧',
          title: t.t('family_parent_turn_title'),
          buttonLabel: t.t('family_pass_to_parent_button'),
          onStart: () => setState(() => _phase = _Phase.parentPlay),
        );
        break;
      case _Phase.parentPlay:
        body = _buildQuestion(t, _parentQuestions!, isParentRound: true);
        break;
      case _Phase.result:
        body = _buildResult(t);
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.t('family_screen_title'))),
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(24), child: body),
        ),
      ),
    );
  }

  Widget _buildIntro({
    required String emoji,
    required String title,
    required String buttonLabel,
    required VoidCallback onStart,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onStart, child: Text(buttonLabel)),
        ],
      ),
    );
  }

  Widget _buildQuestion(AppLocalizations t, List<MathQuestion> questions, {required bool isParentRound}) {
    final q = questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.t('question_progress', {'current': _index + 1, 'total': _questionCount}),
          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Text(
              q.prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: NumeriaColors.tealDark),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 2.2,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(q.choices.length, (i) {
            final isCorrect = i == q.correctIndex;
            final isSelected = i == _selected;
            Color bg = Colors.white;
            Color fg = NumeriaColors.tealDark;
            if (_answered) {
              if (isCorrect) {
                bg = NumeriaColors.green;
                fg = Colors.white;
              } else if (isSelected) {
                bg = NumeriaColors.pink;
                fg = Colors.white;
              }
            }
            return ElevatedButton(
              onPressed: () => _select(i, isParentRound: isParentRound),
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(q.choices[i], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            );
          }),
        ),
        const SizedBox(height: 14),
        if (_answered)
          ElevatedButton(onPressed: () => _next(isParentRound: isParentRound), child: Text(t.t('next_button'))),
      ],
    );
  }

  Widget _buildResult(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(t.t('family_result_title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            t.t('family_result_body', {'child': _childCorrect, 'parent': _parentCorrect}),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.t('back_to_map_button')),
          ),
        ],
      ),
    );
  }
}
