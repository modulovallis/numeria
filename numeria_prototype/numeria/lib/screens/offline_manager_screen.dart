import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/curriculum_data.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';

/// Offline downloads (Monthly/Lifetime feature, Section 8 of the design
/// document): mark whole Kingdoms as available without a connection. This
/// prototype simulates the download with a short delay — there's no real
/// bundling/caching needed since every grade's content already ships
/// inside the app itself.
class OfflineManagerScreen extends StatefulWidget {
  const OfflineManagerScreen({super.key});

  @override
  State<OfflineManagerScreen> createState() => _OfflineManagerScreenState();
}

class _OfflineManagerScreenState extends State<OfflineManagerScreen> {
  final Set<String> _downloading = {};

  Future<void> _toggle(String gradeId) async {
    final appState = context.read<AppState>();
    if (appState.isGradeDownloaded(gradeId)) {
      appState.toggleGradeDownload(gradeId);
      return;
    }
    setState(() => _downloading.add(gradeId));
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    appState.toggleGradeDownload(gradeId);
    setState(() => _downloading.remove(gradeId));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(t.t('offline_manager_title'))),
      body: Container(
        decoration: numeriaBackground(),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(t.t('offline_manager_subtitle'), style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              ...CurriculumData.grades.map((grade) {
                final downloaded = appState.isGradeDownloaded(grade.id);
                final downloading = _downloading.contains(grade.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(grade.icon, color: grade.color),
                    title: Text(t.t(grade.titleKey)),
                    subtitle: Text(downloaded ? t.t('offline_downloaded_label') : t.t('offline_download_button')),
                    trailing: downloading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Icon(
                            downloaded ? Icons.check_circle_rounded : Icons.download_rounded,
                            color: downloaded ? NumeriaColors.green : NumeriaColors.teal,
                          ),
                    onTap: downloading ? null : () => _toggle(grade.id),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
