import 'package:flutter/material.dart';

/// The three monetization tiers described in the Numeria design document.
enum AppTier { free, monthly, lifetime }

/// Central, in-memory app state for the prototype.
///
/// In a production build this would be backed by local persistence
/// (e.g. shared_preferences / Hive) and synced with a backend (see
/// Section 11 of the design document). For this prototype everything
/// lives in memory so the app is simple to read and run.
class AppState extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  AppTier tier = AppTier.free;
  void setTier(AppTier newTier) {
    tier = newTier;
    notifyListeners();
  }

  // --- Gamification state ---
  int xp = 120;
  int coins = 35;
  int streakDays = 3;
  int confidence = 62; // 0-100, the "Confidence Meter" from the design doc

  int _freeQuestionsAnsweredToday = 0;
  static const int freeDailyQuestionCap = 20;

  bool get freeDailyCapReached =>
      tier == AppTier.free && _freeQuestionsAnsweredToday >= freeDailyQuestionCap;

  final Set<String> completedLevelIds = {};

  bool isLevelUnlocked(List<String> prerequisiteIds) {
    if (prerequisiteIds.isEmpty) return true;
    return prerequisiteIds.every(completedLevelIds.contains);
  }

  /// Co-op mode, family challenge and offline downloads are Monthly/Lifetime
  /// features in the monetization plan (Section 8 of the design document).
  bool get hasPremiumFeatures => tier != AppTier.free;

  void recordAnswer({required bool correct}) {
    if (tier == AppTier.free) _freeQuestionsAnsweredToday++;
    if (correct) {
      xp += 10;
      coins += 2;
      confidence = (confidence + 4).clamp(0, 100);
    } else {
      // Wrong answers cost a little confidence but never XP/coins —
      // mistakes are a learning moment, not a punishment.
      confidence = (confidence - 2).clamp(0, 100);
    }
    notifyListeners();
  }

  void completeLevel(String levelId, {required int starsEarned}) {
    completedLevelIds.add(levelId);
    xp += 20 * starsEarned;
    coins += 10 * starsEarned;
    if (starsEarned >= 2) {
      confidence = (confidence + 6).clamp(0, 100);
    }
    notifyListeners();
  }

  /// Demo-only helper so the prototype can showcase the free-tier daily cap
  /// without waiting a real day. Not part of the production design.
  void debugResetDailyCap() {
    _freeQuestionsAnsweredToday = 0;
    notifyListeners();
  }
}
