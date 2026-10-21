import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/parent_gate_dialog.dart';

/// The monetization screen — Section 8 of the design document. Three
/// tiers: Free, Monthly, and the Lifetime "Full Access" one-time purchase
/// that none of the three benchmarked competitors currently offer.
///
/// This is a UI prototype only: choosing a plan updates local demo state
/// after a parental-gate check, but does not process any real payment.
/// A production build would route this through Google Play Billing.
class PaywallScreen extends StatelessWidget {
  final bool fromDailyLimit;
  const PaywallScreen({super.key, this.fromDailyLimit = false});

  Future<void> _choosePlan(BuildContext context, AppTier tier) async {
    if (tier == AppTier.free) {
      context.read<AppState>().setTier(tier);
      return;
    }
    final approved = await showParentGate(context);
    if (!context.mounted) return;
    if (approved) {
      context.read<AppState>().setTier(tier);
      final t = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('prototype_payment_note'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(t.t('paywall_title'))),
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (fromDailyLimit) ...[
                Card(
                  color: NumeriaColors.yellow.withOpacity(0.25),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.t('daily_limit_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(t.t('daily_limit_body')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(t.t('paywall_subtitle'), style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              _TierCard(
                title: t.t('tier_free_title'),
                price: t.t('tier_free_price'),
                desc: t.t('tier_free_desc'),
                color: NumeriaColors.blue,
                isCurrent: appState.tier == AppTier.free,
                onChoose: () => _choosePlan(context, AppTier.free),
              ),
              const SizedBox(height: 14),
              _TierCard(
                title: t.t('tier_monthly_title'),
                price: t.t('tier_monthly_price'),
                desc: t.t('tier_monthly_desc'),
                color: NumeriaColors.orange,
                isCurrent: appState.tier == AppTier.monthly,
                onChoose: () => _choosePlan(context, AppTier.monthly),
              ),
              const SizedBox(height: 14),
              _TierCard(
                title: t.t('tier_lifetime_title'),
                price: t.t('tier_lifetime_price'),
                desc: t.t('tier_lifetime_desc'),
                color: NumeriaColors.purple,
                isCurrent: appState.tier == AppTier.lifetime,
                highlight: true,
                onChoose: () => _choosePlan(context, AppTier.lifetime),
              ),
              const SizedBox(height: 20),
              Text(
                t.t('prototype_payment_note'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black45, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String title;
  final String price;
  final String desc;
  final Color color;
  final bool isCurrent;
  final bool highlight;
  final VoidCallback onChoose;

  const _TierCard({
    required this.title,
    required this.price,
    required this.desc,
    required this.color,
    required this.isCurrent,
    required this.onChoose,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Card(
      elevation: highlight ? 8 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: highlight ? color : Colors.transparent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: isCurrent
                  ? OutlinedButton(onPressed: null, child: Text(t.t('current_plan_label')))
                  : ElevatedButton(
                      onPressed: onChoose,
                      style: ElevatedButton.styleFrom(backgroundColor: color),
                      child: Text(t.t('choose_plan_button')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
