import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../logic/question_generator.dart';
import '../models/curriculum.dart';
import '../state/app_state.dart';
import '../widgets/mascot_bubble.dart';

/// "Math Moments" — a short, real-world-flavored daily mini-challenge
/// (Phase 2 feature from the design document). Unlike Co-op Quests,
/// Family Challenge and Offline downloads, this one is free on every
/// tier: it's a retention hook, not a premium feature. It resets once
/// every real calendar day.
class MathMomentScreen extends StatefulWidget {
  const MathMomentScreen({super.key});

  @override
  State<MathMomentScreen> createState() => _MathMomentScreenState();
}

class _MathMomentScreenState extends State<MathMomentScreen> {
  static const _topics = [
    TopicType.addition,
    TopicType.subtraction,
    TopicType.multiplication,
    TopicType.measurement,
  ];

  late final int _dayIndex;
  late final TopicType _topic;
  MathQuestion? _question;
  int _selected = -1;
  bool _answered = false;
  bool _claimed = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    _dayIndex = dayOfYear % 4;
    _topic = _topics[_dayIndex];
  }

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
    });
  }

  void _claim() {
    final appState = context.read<AppState>();
    appState.awardBonus(xp: 25, coins: 15);
    appState.markMathMomentClaimedToday();
    setState(() => _claimed = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final appState = context.watch<AppState>();
    _question ??= QuestionGenerator.generate(_topic, 20, t);

    final alreadyDoneToday = _claimed ? false : !appState.mathMomentAvailableToday;

    Widget body;
    if (_claimed) {
      body = _RewardCard(
        emoji: '🎉',
        title: t.t('math_moment_claimed_title'),
        body: t.t('math_moment_claimed_body', {'xp': 25, 'coins': 15}),
      );
    } else if (alreadyDoneToday) {
      body = _RewardCard(
        emoji: '✅',
        title: t.t('math_moment_already_title'),
        body: t.t('math_moment_already_body'),
      );
    } else {
      body = _buildQuestion(t);
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.t('math_moment_screen_title'))),
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(24), child: body),
        ),
      ),
    );
  }

  Widget _buildQuestion(AppLocalizations t) {
    final q = _question!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: NumeriaColors.yellow.withOpacity(0.25),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t.t('math_moment_context_${_dayIndex + 1}')),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          q.prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: NumeriaColors.tealDark),
        ),
        const SizedBox(height: 20),
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
        if (_answered) ...[
          if (_selected != q.correctIndex)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: MascotBubble(message: q.hint)),
          ElevatedButton(onPressed: _claim, child: Text(t.t('math_moment_claim_button'))),
        ],
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  const _RewardCard({required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
