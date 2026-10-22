import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/question_generator.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';
import '../widgets/mascot_bubble.dart';
import 'result_screen.dart';

/// The core practice loop: a short set of adaptive-style questions for one
/// Level. A wrong answer never just marks the question wrong — it shows
/// the "Explain-It-Back Coach" mascot hint (Section 7 of the design
/// document) before moving on.
class LevelScreen extends StatefulWidget {
  final LevelDef level;
  final Color themeColor;

  const LevelScreen({super.key, required this.level, required this.themeColor});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late final List<MathQuestion> _questions;
  int _index = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _generated = false;

  void _ensureGenerated(AppLocalizations t) {
    if (_generated) return;
    _questions = List.generate(
      widget.level.questionCount,
      (_) => QuestionGenerator.generate(widget.level.topic, widget.level.maxValue, t),
    );
    _generated = true;
  }

  void _selectAnswer(int i) {
    if (_answered) return;
    final appState = context.read<AppState>();
    final correct = i == _questions[_index].correctIndex;
    setState(() {
      _selectedIndex = i;
      _answered = true;
      if (correct) _correctCount++;
    });
    appState.recordAnswer(correct: correct);
  }

  void _next() {
    if (_index + 1 < _questions.length) {
      setState(() {
        _index++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      final appState = context.read<AppState>();
      final ratio = _correctCount / _questions.length;
      final stars = ratio >= 0.99 ? 3 : (ratio >= 0.7 ? 2 : 1);
      appState.completeLevel(widget.level.id, starsEarned: stars);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            level: widget.level,
            stars: stars,
            xpEarned: 20 * stars,
            coinsEarned: 10 * stars,
            themeColor: widget.themeColor,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    _ensureGenerated(t);
    final question = _questions[_index];

    return Scaffold(
      appBar: AppBar(title: Text(widget.level.displayTitle(t))),
      body: Container(
        decoration: numeriaBackground(colors: [Colors.white, widget.themeColor.withOpacity(0.12)]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (_index) / _questions.length,
                    minHeight: 10,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation(widget.themeColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.t('question_progress', {'current': _index + 1, 'total': _questions.length}),
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Text(
                      question.prompt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: NumeriaColors.tealDark),
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
                  children: List.generate(question.choices.length, (i) {
                    final isCorrect = i == question.correctIndex;
                    final isSelected = i == _selectedIndex;
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
                      onPressed: () => _selectAnswer(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bg,
                        foregroundColor: fg,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        question.choices[i],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                if (_answered) ...[
                  if (_selectedIndex != question.correctIndex)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MascotBubble(message: question.hint),
                    ),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _index + 1 < _questions.length ? t.t('next_button') : t.t('finish_level_button'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
