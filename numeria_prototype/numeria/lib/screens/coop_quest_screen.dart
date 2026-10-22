import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/question_generator.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';

/// Co-op Quests (Monthly/Lifetime feature, Section 8 of the design
/// document): two kids pass one device back and forth, each answering
/// every other question, working toward one shared team score instead of
/// competing against each other.
class CoopQuestScreen extends StatefulWidget {
  const CoopQuestScreen({super.key});

  @override
  State<CoopQuestScreen> createState() => _CoopQuestScreenState();
}

class _CoopQuestScreenState extends State<CoopQuestScreen> {
  static const _questionCount = 6;
  static const _topics = [TopicType.addition, TopicType.subtraction, TopicType.multiplication];

  final List<MathQuestion> _questions = [];
  bool _generated = false;
  int _index = 0;
  int _selected = -1;
  bool _answered = false;
  bool _showPassScreen = true;
  int _p1Correct = 0;
  int _p2Correct = 0;

  int get _currentPlayer => _index.isEven ? 1 : 2;
  bool get _finished => _index >= _questionCount;

  void _ensureGenerated(AppLocalizations t) {
    if (_generated) return;
    for (var i = 0; i < _questionCount; i++) {
      final topic = _topics[i % _topics.length];
      _questions.add(QuestionGenerator.generate(topic, 20, t));
    }
    _generated = true;
  }

  void _select(int i) {
    if (_answered) return;
    final correct = i == _questions[_index].correctIndex;
    setState(() {
      _selected = i;
      _answered = true;
      if (correct) {
        if (_currentPlayer == 1) {
          _p1Correct++;
        } else {
          _p2Correct++;
        }
      }
    });
  }

  void _next() {
    setState(() {
      _index++;
      _selected = -1;
      _answered = false;
      _showPassScreen = true;
    });
    if (_finished) {
      final total = _p1Correct + _p2Correct;
      context.read<AppState>().awardBonus(xp: 15 * total, coins: 5 * total);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    _ensureGenerated(t);

    Widget body;
    if (_finished) {
      body = _buildResult(t);
    } else if (_showPassScreen) {
      body = _buildPassScreen(t);
    } else {
      body = _buildQuestion(t);
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.t('coop_screen_title'))),
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(24), child: body),
        ),
      ),
    );
  }

  Widget _buildPassScreen(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            t.t('coop_player_turn', {'n': _currentPlayer}),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _showPassScreen = false),
            child: Text(t.t('coop_pass_device_button')),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(AppLocalizations t) {
    final q = _questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.t('coop_player_turn', {'n': _currentPlayer}),
          style: const TextStyle(fontWeight: FontWeight.bold, color: NumeriaColors.tealDark),
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
              onPressed: () => _select(i),
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
        if (_answered) ElevatedButton(onPressed: _next, child: Text(t.t('next_button'))),
      ],
    );
  }

  Widget _buildResult(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(t.t('coop_result_title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            t.t('coop_result_body', {'p1': _p1Correct, 'p2': _p2Correct, 'total': _p1Correct + _p2Correct}),
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
