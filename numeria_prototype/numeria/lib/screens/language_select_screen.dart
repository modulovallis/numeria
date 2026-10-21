import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'home_screen.dart';

/// True first-class language switcher — Section 7 ("True Deep
/// Localization") and Section 9 of the design document. Every one of the
/// six languages is a full locale, selectable up front and changeable
/// again anytime from Settings.
class LanguageSelectScreen extends StatelessWidget {
  const LanguageSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final t = context.l10n;

    return Scaffold(
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  t.t('choose_language_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: NumeriaColors.tealDark),
                ),
                const SizedBox(height: 8),
                Text(
                  t.t('choose_language_subtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: kSupportedLocales.map((locale) {
                      final code = locale.languageCode;
                      final selected = appState.locale.languageCode == code;
                      return _LanguageCard(
                        code: code,
                        selected: selected,
                        onTap: () => appState.setLocale(locale),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: Text(t.t('continue_button')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageCard({required this.code, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? NumeriaColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? NumeriaColors.teal : Colors.black12, width: 2),
          boxShadow: const [
            BoxShadow(color: NumeriaColors.cardShadow, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(languageFlagEmoji[code] ?? '🌐', style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 6),
            Text(
              nativeLanguageName(code),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : NumeriaColors.tealDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
