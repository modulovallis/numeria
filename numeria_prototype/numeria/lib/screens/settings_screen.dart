import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/confidence_meter.dart';
import '../widgets/stat_chip.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(t.t('settings_title'))),
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🦊', style: TextStyle(fontSize: 34)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                StatChip(emoji: '✨', label: '${appState.xp} ${t.t('xp_label')}', color: NumeriaColors.purple),
                                StatChip(emoji: '🪙', label: '${appState.coins}', color: NumeriaColors.yellow),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ConfidenceMeter(value: appState.confidence),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(t.t('language_label'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: kSupportedLocales.map((locale) {
                    final code = locale.languageCode;
                    final selected = appState.locale.languageCode == code;
                    return ListTile(
                      leading: Text(languageFlagEmoji[code] ?? '🌐', style: const TextStyle(fontSize: 22)),
                      title: Text(nativeLanguageName(code)),
                      trailing: selected ? const Icon(Icons.check_circle_rounded, color: NumeriaColors.green) : null,
                      onTap: () => appState.setLocale(locale),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text(t.t('account_tier_label'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(t.t('switch_tier_demo_note'), style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    children: AppTier.values.map((tier) {
                      final labelKey = switch (tier) {
                        AppTier.free => 'tier_free_title',
                        AppTier.monthly => 'tier_monthly_title',
                        AppTier.lifetime => 'tier_lifetime_title',
                      };
                      return RadioListTile<AppTier>(
                        value: tier,
                        groupValue: appState.tier,
                        title: Text(t.t(labelKey)),
                        onChanged: (v) {
                          if (v != null) appState.setTier(v);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _ComingSoonTile(icon: Icons.diversity_3_rounded, text: t.t('coop_mode_teaser'), badge: t.t('coming_soon_badge')),
              _ComingSoonTile(icon: Icons.family_restroom_rounded, text: t.t('family_mode_teaser'), badge: t.t('coming_soon_badge')),
              _ComingSoonTile(icon: Icons.wifi_off_rounded, text: t.t('offline_mode_teaser'), badge: t.t('coming_soon_badge')),
              _ComingSoonTile(icon: Icons.explore_rounded, text: t.t('math_moments_teaser'), badge: t.t('coming_soon_badge')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String badge;
  const _ComingSoonTile({required this.icon, required this.text, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: NumeriaColors.teal),
        title: Text(text, style: const TextStyle(fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: NumeriaColors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NumeriaColors.orange)),
        ),
      ),
    );
  }
}
