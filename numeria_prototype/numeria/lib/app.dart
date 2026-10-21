import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

class NumeriaApp extends StatelessWidget {
  const NumeriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Numeria',
            debugShowCheckedModeBanner: false,
            theme: NumeriaTheme.light,
            locale: appState.locale,
            supportedLocales: kSupportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supported) {
              if (locale != null) {
                for (final s in supported) {
                  if (s.languageCode == locale.languageCode) return s;
                }
              }
              return const Locale('en');
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
