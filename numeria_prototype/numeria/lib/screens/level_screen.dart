import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// document) before moving on. The question *interaction* varies with the
/// level's [QuestionKind]: multiple choice (the original format), True/False,
/// or typed numeric input — see Section 7 for the rationale (competitor
/// research showed Prodigy/SplashLearn/DoodleMaths all vary format, not
/// just content). The level can also be restarted mid-attempt or replayed
/// from the Result screen.
class LevelScreen extends StatefulWidget {
  final LevelDef level;
  final Color themeColor;

  const LevelScreen({super.key, required this.level, required this.themeColor});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  // Only one of these is populated, depending on widget.level.kind.
  List<MathQuestion>? _mcQuestions;
  List<TrueFalseQuestion>? _tfQuestions;

  int _index = 0;
  int _correctCount = 0;
  int? _selectedIndex; // multiple choice
  bool? _selectedBool; // true/false
  final TextEditingController _typedController = TextEditingController();
  bool _typedSubmittedCorrect = false;
  bool _answered = false;
  bool _generated = false;

  bool get _isTrueFalse => widget.level.kind == QuestionKind.trueFalse;
  bool get _isTypedInput => widget.level.kind == QuestionKind.typedInput;

  int get _questionCount =>
      _isTrueFalse ? _tfQuestions!.length : _mcQuestions!.length;

  @override
  void dispose() {
    _typedController.dispose();
    super.dispose();
  }

  void _ensureGenerated(AppLocalizations t) {
    if (_generated) return;
    if (_isTrueFalse) {
      _tfQuestions = List.generate(
        widget.level.questionCount,
        (_) => QuestionGenerator.generateTrueFalse(widget.level.topic, widget.level.maxValue, t),
      );
    } else {
      _mcQuestions = List.generate(
        widget.level.questionCount,
        (_) => QuestionGenerator.generate(widget.level.topic, widget.level.maxValue, t),
      );
    }
    _generated = true;
  }

  void _restart() {
    setState(() {
      _generated = false;
      _mcQuestions = null;
      _tfQuestions = null;
      _index = 0;
      _correctCount = 0;
      _selectedIndex = null;
      _selectedBool = null;
      _typedController.clear();
      _typedSubmittedCorrect = false;
      _answered = false;
    });
  }

  Future<void> _confirmRestart() async {
    if (_index == 0 && !_answered) {
      _restart();
      return;
    }
    final t = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.t('restart_level_title')),
        content: Text(t.t('restart_level_body')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(t.t('cancel_button'))),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(t.t('restart_button'))),
        ],
      ),
    );
    if (confirmed == true) _restart();
  }

  void _selectMultipleChoice(int i) {
    if (_answered) return;
    final appState = context.read<AppState>();
    final correct = i == _mcQuestions![_index].correctIndex;
    setState(() {
      _selectedIndex = i;
      _answered = true;
      if (correct) _correctCount++;
    });
    appState.recordAnswer(correct: correct);
  }

  void _selectTrueFalse(bool choice) {
    if (_answered) return;
    final appState = context.read<AppState>();
    final correct = choice == _tfQuestions![_index].isTrue;
    setState(() {
      _selectedBool = choice;
      _answered = true;
      if (correct) _correctCount++;
    });
    appState.recordAnswer(correct: correct);
  }

  void _submitTyped() {
    if (_answered) return;
    final appState = context.read<AppState>();
    final q = _mcQuestions![_index];
    final correctLabel = q.choices[q.correctIndex];
    final correct = _typedController.text.trim() == correctLabel;
    setState(() {
      _answered = true;
      _typedSubmittedCorrect = correct;
      if (correct) _correctCount++;
    });
    appState.recordAnswer(correct: correct);
  }

  void _next() {
    if (_index + 1 < _questionCount) {
      setState(() {
        _index++;
        _selectedIndex = null;
        _selectedBool = null;
        _typedController.clear();
        _typedSubmittedCorrect = false;
        _answered = false;
      });
    } else {
      final appState = context.read<AppState>();
      final ratio = _correctCount / _questionCount;
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
            replayBuilder: (_) => LevelScreen(level: widget.level, themeColor: widget.themeColor),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    _ensureGenerated(t);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.level.displayTitle(t)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: t.t('restart_button'),
            onPressed: _confirmRestart,
          ),
        ],
      ),
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
                    value: _index / _questionCount,
                    minHeight: 10,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation(widget.themeColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.t('question_progress', {'current': _index + 1, 'total': _questionCount}),
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _isTrueFalse
                      ? _buildTrueFalseBody(t)
                      : (_isTypedInput ? _buildTypedInputBody(t) : _buildMultipleChoiceBody(t)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceBody(AppLocalizations t) {
    final question = _mcQuestions![_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              onPressed: () => _selectMultipleChoice(i),
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(question.choices[i], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            );
          }),
        ),
        const SizedBox(height: 14),
        if (_answered) ...[
          if (_selectedIndex != question.correctIndex)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: MascotBubble(message: question.hint)),
          ElevatedButton(
            onPressed: _next,
            child: Text(_index + 1 < _questionCount ? t.t('next_button') : t.t('finish_level_button')),
          ),
        ],
      ],
    );
  }

  Widget _buildTrueFalseBody(AppLocalizations t) {
    final question = _tfQuestions![_index];
    Color trueBg = Colors.white, trueFg = NumeriaColors.tealDark;
    Color falseBg = Colors.white, falseFg = NumeriaColors.tealDark;
    if (_answered) {
      if (question.isTrue) {
        trueBg = NumeriaColors.green;
        trueFg = Colors.white;
        if (_selectedBool == false) {
          falseBg = NumeriaColors.pink;
          falseFg = Colors.white;
        }
      } else {
        falseBg = NumeriaColors.green;
        falseFg = Colors.white;
        if (_selectedBool == true) {
          trueBg = NumeriaColors.pink;
          trueFg = Colors.white;
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Text(
              question.statement,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: NumeriaColors.tealDark),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectTrueFalse(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: trueBg,
                  foregroundColor: trueFg,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(t.t('true_label'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectTrueFalse(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: falseBg,
                  foregroundColor: falseFg,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(t.t('false_label'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_answered) ...[
          if (_selectedBool != question.isTrue)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: MascotBubble(message: question.hint)),
          ElevatedButton(
            onPressed: _next,
            child: Text(_index + 1 < _questionCount ? t.t('next_button') : t.t('finish_level_button')),
          ),
        ],
      ],
    );
  }

  Widget _buildTypedInputBody(AppLocalizations t) {
    final question = _mcQuestions![_index];
    final correctLabel = question.choices[question.correctIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Text(
              question.prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: NumeriaColors.tealDark),
            ),
          ),
        ),
        TextField(
          controller: _typedController,
          enabled: !_answered,
          autofocus: true,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: t.t('typed_input_placeholder'),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submitTyped(),
        ),
        const SizedBox(height: 14),
        if (!_answered)
          ElevatedButton(
            onPressed: _typedController.text.trim().isEmpty ? null : _submitTyped,
            child: Text(t.t('typed_input_submit_button')),
          )
        else ...[
          Text(
            _typedSubmittedCorrect
                ? t.t('answer_correct_title')
                : t.t('typed_input_correct_answer_was', {'answer': correctLabel}),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _typedSubmittedCorrect ? NumeriaColors.green : NumeriaColors.pink,
            ),
          ),
          const SizedBox(height: 12),
          if (!_typedSubmittedCorrect)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: MascotBubble(message: question.hint)),
          ElevatedButton(
            onPressed: _next,
            child: Text(_index + 1 < _questionCount ? t.t('next_button') : t.t('finish_level_button')),
          ),
        ],
      ],
    );
  }
}
