import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/question_generator.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';
import 'result_screen.dart';

class _MatchCard {
  final String label;
  final int pairIndex;
  const _MatchCard({required this.label, required this.pairIndex});
}

/// A standalone tap-to-match puzzle: prompts on the left, answers on the
/// right, tap one from each side to try a pair. One of the gameplay
/// formats added after competitor research (Section 7 of the design
/// document) — a lower-risk alternative to true drag-and-drop that still
/// delivers a distinctly different feel from the question-by-question
/// levels.
class MatchingLevelScreen extends StatefulWidget {
  final LevelDef level;
  final Color themeColor;

  const MatchingLevelScreen({super.key, required this.level, required this.themeColor});

  @override
  State<MatchingLevelScreen> createState() => _MatchingLevelScreenState();
}

class _MatchingLevelScreenState extends State<MatchingLevelScreen> {
  List<MatchPair>? _pairs;
  List<_MatchCard> _leftItems = [];
  List<_MatchCard> _rightItems = [];
  final Set<int> _matchedPairs = {};
  int? _selectedLeft;
  int? _selectedRight;
  bool _wrongFlash = false;
  int _wrongAttempts = 0;
  bool _generated = false;

  void _ensureGenerated(AppLocalizations t) {
    if (_generated) return;
    final pairs = QuestionGenerator.generateMatchingPairs(
      widget.level.topic,
      widget.level.maxValue,
      widget.level.questionCount,
      t,
    );
    _pairs = pairs;
    _leftItems = [
      for (var i = 0; i < pairs.length; i++) _MatchCard(label: pairs[i].promptLabel, pairIndex: i),
    ]..shuffle();
    _rightItems = [
      for (var i = 0; i < pairs.length; i++) _MatchCard(label: pairs[i].answerLabel, pairIndex: i),
    ]..shuffle();
    _generated = true;
  }

  void _restart() {
    setState(() {
      _generated = false;
      _pairs = null;
      _matchedPairs.clear();
      _selectedLeft = null;
      _selectedRight = null;
      _wrongFlash = false;
      _wrongAttempts = 0;
    });
  }

  Future<void> _confirmRestart() async {
    if (_matchedPairs.isEmpty) {
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

  void _tapLeft(int pos) {
    if (_wrongFlash || _matchedPairs.contains(_leftItems[pos].pairIndex)) return;
    setState(() => _selectedLeft = pos);
    _tryMatch();
  }

  void _tapRight(int pos) {
    if (_wrongFlash || _matchedPairs.contains(_rightItems[pos].pairIndex)) return;
    setState(() => _selectedRight = pos);
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedLeft == null || _selectedRight == null) return;
    final leftPair = _leftItems[_selectedLeft!].pairIndex;
    final rightPair = _rightItems[_selectedRight!].pairIndex;
    if (leftPair == rightPair) {
      setState(() {
        _matchedPairs.add(leftPair);
        _selectedLeft = null;
        _selectedRight = null;
      });
      if (_matchedPairs.length == _pairs!.length) _finish();
    } else {
      _wrongAttempts++;
      setState(() => _wrongFlash = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _wrongFlash = false;
          _selectedLeft = null;
          _selectedRight = null;
        });
      });
    }
  }

  void _finish() {
    final appState = context.read<AppState>();
    final stars = _wrongAttempts == 0 ? 3 : (_wrongAttempts <= 2 ? 2 : 1);
    appState.completeLevel(widget.level.id, starsEarned: stars);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          level: widget.level,
          stars: stars,
          xpEarned: 20 * stars,
          coinsEarned: 10 * stars,
          themeColor: widget.themeColor,
          replayBuilder: (_) => MatchingLevelScreen(level: widget.level, themeColor: widget.themeColor),
        ),
      ),
    );
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
                Text(
                  t.t('matching_instruction'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _matchedPairs.length / _pairs!.length,
                    minHeight: 10,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation(widget.themeColor),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: List.generate(_leftItems.length, (pos) => _buildCard(
                                label: _leftItems[pos].label,
                                matched: _matchedPairs.contains(_leftItems[pos].pairIndex),
                                selected: _selectedLeft == pos,
                                wrongFlash: _wrongFlash && _selectedLeft == pos,
                                onTap: () => _tapLeft(pos),
                              )),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: List.generate(_rightItems.length, (pos) => _buildCard(
                                label: _rightItems[pos].label,
                                matched: _matchedPairs.contains(_rightItems[pos].pairIndex),
                                selected: _selectedRight == pos,
                                wrongFlash: _wrongFlash && _selectedRight == pos,
                                onTap: () => _tapRight(pos),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String label,
    required bool matched,
    required bool selected,
    required bool wrongFlash,
    required VoidCallback onTap,
  }) {
    Color bg = Colors.white;
    Color fg = NumeriaColors.tealDark;
    if (matched) {
      bg = NumeriaColors.green;
      fg = Colors.white;
    } else if (wrongFlash) {
      bg = NumeriaColors.pink;
      fg = Colors.white;
    } else if (selected) {
      bg = NumeriaColors.yellow;
      fg = NumeriaColors.tealDark;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: matched ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? NumeriaColors.orange : Colors.black12, width: 2),
            boxShadow: const [
              BoxShadow(color: NumeriaColors.cardShadow, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: fg),
          ),
        ),
      ),
    );
  }
}
