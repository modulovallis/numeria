import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/paywall_screen.dart';
import '../state/app_state.dart';

/// Opens the screen built by [builder] when the account has Monthly or
/// Lifetime access; otherwise routes to the Paywall instead. Co-op Quests,
/// Family Challenge and Offline downloads are Monthly+ features per
/// Section 8 of the design document.
void openPremiumFeature(BuildContext context, WidgetBuilder builder) {
  final appState = context.read<AppState>();
  if (!appState.hasPremiumFeatures) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    return;
  }
  Navigator.of(context).push(MaterialPageRoute(builder: builder));
}
