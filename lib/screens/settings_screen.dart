import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../data/auto_backup.dart';
import '../data/backup.dart';
import '../data/settings.dart';
import '../widgets/common.dart';
import '../widgets/beep_style_picker.dart';

final _versionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _exportKey = GlobalKey();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final db = ref.read(databaseProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text('SETTINGS', style: SprintText.display(40)),
            const SizedBox(height: 20),
            _BackupCard(
              lastBackupAt: settings.lastBackupAt,
              exportKey: _exportKey,
              busy: _busy,
              onExport: _export,
              onRestore: _restore,
            ),
            const SizedBox(height: 12),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Row(
                    title: 'Weekly auto backup',
                    subtitle: Platform.isIOS
                        ? 'Keeps the last $autoBackupsKept files in '
                              'Files › On My iPhone › Sprintur'
                        : 'Keeps the last $autoBackupsKept files inside the app',
                    trailing: SprintSwitch(
                      label: 'Weekly auto backup',
                      value: settings.autoBackup,
                      onChanged: (v) =>
                          db.setPref(AppSettings.keyAutoBackup, '$v'),
                    ),
                  ),
                  const _Divider(),
                  _Row(
                    title: 'Export sessions as CSV',
                    subtitle: 'One row per rep, for spreadsheets and coaches',
                    trailing: const Icon(
                      Icons.ios_share_rounded,
                      color: SprintColors.muted,
                      size: 20,
                    ),
                    onTap: _busy ? null : _exportCsv,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Beep sound',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to hear it',
                    style: TextStyle(fontSize: 12, color: SprintColors.muted),
                  ),
                  const SizedBox(height: 12),
                  BeepStylePicker(
                    value: settings.beepStyle,
                    onChanged: (s) =>
                        db.setPref(AppSettings.keyBeepStyle, s.name),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _RemindersCard(settings: settings, onChanged: _setReminders),
            const SizedBox(height: 12),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Row(
                    title: 'Check for updates',
                    subtitle:
                        'Once a day, from GitHub releases. The only time the '
                        'app goes online.',
                    trailing: SprintSwitch(
                      label: 'Check for updates',
                      value: settings.checkUpdates,
                      onChanged: (v) =>
                          db.setPref(AppSettings.keyCheckUpdates, '$v'),
                    ),
                  ),
                  const _Divider(),
                  _VersionRow(version: ref.watch(_versionProvider).value),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Open source. No account: everything stays on this phone '
              'unless you export it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: SprintColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Turning the first day on asks for notification permission.
  Future<void> _setReminders(Set<int> days, int minutes) async {
    final db = ref.read(databaseProvider);
    final before = ref.read(settingsProvider).value?.reminderDays ?? {};
    if (before.isEmpty && days.isNotEmpty) {
      final allowed = await ref.read(notificationsProvider).requestPermission();
      if (!allowed) {
        _toast(
          'Notifications are off for Sprintur. Turn them on in system '
          'settings to get reminders.',
        );
        return;
      }
    }
    await db.setPref(AppSettings.keyReminderDays, AppSettings.encodeDays(days));
    await db.setPref(AppSettings.keyReminderMinutes, '$minutes');
  }

  /// Anchors the share sheet on iPad; ignored on phones.
  Rect? _origin() {
    final box = _exportKey.currentContext?.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _share(String name, String text, String mime) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    await file.writeAsString(text, flush: true);
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mime)],
        sharePositionOrigin: _origin(),
      ),
    );
    if (result.status == ShareResultStatus.dismissed) throw const _Dismissed();
  }

  Future<void> _run(Future<void> Function() task) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await task();
    } on _Dismissed {
      // The share sheet was closed without picking anything.
    } on BackupException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() => _run(() async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    await _share(
      backupFileName(now),
      await db.exportJson(now: now),
      'application/json',
    );
    await db.setPref(
      AppSettings.keyLastBackupAt,
      now.toUtc().toIso8601String(),
    );
    HapticFeedback.mediumImpact();
  });

  Future<void> _exportCsv() => _run(() async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final name = backupFileName(now).replaceFirst('backup', 'sessions');
    await _share(
      name.replaceFirst('.json', '.csv'),
      await db.exportCsv(),
      'text/csv',
    );
  });

  Future<void> _restore() => _run(() async {
    // Any type: cloud drives often label .json files as plain data, and the
    // restore checks the contents anyway.
    final picked = await FilePicker.pickFiles(type: FileType.any);
    if (picked.isEmpty) return;
    final String text;
    try {
      text = utf8.decode(await picked.first.readAsBytes());
    } on FormatException {
      throw const BackupException('This file is not a Sprintur backup.');
    }
    final result = await ref.read(databaseProvider).restoreJson(text);
    HapticFeedback.mediumImpact();
    _toast(switch ((result.sessionsAdded, result.workoutsAdded)) {
      (0, 0) => 'Everything in that backup is already on this phone.',
      (final s, final w) =>
        'Restored ${_count(s, 'session')}'
            '${w > 0 ? ' and ${_count(w, 'saved workout')}' : ''}.',
    });
  });

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Dismissed implements Exception {
  const _Dismissed();
}

String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

/// "Just now", "Today", "Yesterday", "3 days ago", or a date.
String _ago(DateTime at, DateTime now) {
  final local = at.toLocal();
  if (now.difference(local) < const Duration(minutes: 2)) return 'Just now';
  final days = DateUtils.dateOnly(
    now,
  ).difference(DateUtils.dateOnly(local)).inDays;
  return switch (days) {
    <= 0 => 'Today, ${formatClock(local)}',
    1 => 'Yesterday',
    < 30 => '$days days ago',
    _ => formatDay(local),
  };
}

class _BackupCard extends StatelessWidget {
  const _BackupCard({
    required this.lastBackupAt,
    required this.exportKey,
    required this.busy,
    required this.onExport,
    required this.onRestore,
  });

  final DateTime? lastBackupAt;
  final GlobalKey exportKey;
  final bool busy;
  final VoidCallback onExport;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final last = lastBackupAt;
    final fresh =
        last != null && DateTime.now().difference(last) < autoBackupEvery;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: fresh ? SprintColors.lime : SprintColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  fresh ? Icons.check_rounded : Icons.history_rounded,
                  color: fresh ? SprintColors.bg : SprintColors.text,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last backup',
                      style: TextStyle(fontSize: 12, color: SprintColors.muted),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        last == null ? 'Never' : _ago(last, DateTime.now()),
                        key: ValueKey(last),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (last != null)
                      Text(
                        backupFileName(last.toLocal()),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: SprintColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BigButton(
                  key: exportKey,
                  label: 'Export',
                  icon: Icons.ios_share_rounded,
                  height: 48,
                  radius: 14,
                  onPressed: busy ? null : onExport,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BigButton(
                  label: 'Restore',
                  icon: Icons.download_rounded,
                  outlined: true,
                  foreground: SprintColors.text,
                  height: 48,
                  radius: 14,
                  onPressed: busy ? null : onRestore,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Export opens the share sheet: save to Files or Drive, or send it '
            'to yourself. Restore adds a backup to this phone without '
            'deleting anything.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: SprintColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: SprintColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 1,
    indent: 16,
    endIndent: 16,
    color: SprintColors.border,
  );
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    return _Row(
      title: 'Version',
      trailing: Text(
        version ?? '',
        style: const TextStyle(
          fontSize: 14,
          color: SprintColors.muted,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Weekday chips and a time. No days picked means no reminders.
class _RemindersCard extends StatelessWidget {
  const _RemindersCard({required this.settings, required this.onChanged});

  final AppSettings settings;
  final void Function(Set<int> days, int minutes) onChanged;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final days = settings.reminderDays;
    final minutes = settings.reminderMinutes;
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Training reminders',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      days.isEmpty
                          ? 'Pick your sprint days'
                          : 'With your next workout',
                      style: const TextStyle(
                        fontSize: 12,
                        color: SprintColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) {
                    onChanged(days, picked.hour * 60 + picked.minute);
                  }
                },
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: Text(time.format(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var day = 1; day <= 7; day++) ...[
                if (day > 1) const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChipButton(
                    label: _letters[day - 1],
                    selected: days.contains(day),
                    onTap: () => onChanged(
                      days.contains(day)
                          ? ({...days}..remove(day))
                          : {...days, day},
                      minutes,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
