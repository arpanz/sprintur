/// The beep tone set. Changing it changes every cue, not one sound.
enum BeepStyle {
  classic('Classic'),
  whistle('Whistle'),
  low('Low');

  const BeepStyle(this.label);
  final String label;
}

/// Typed view over the `prefs` table.
class AppSettings {
  const AppSettings({
    this.onboarded = false,
    this.beepStyle = BeepStyle.classic,
    this.autoBackup = true,
    this.lastBackupAt,
    this.reminderDays = const {},
    this.reminderMinutes = 18 * 60,
    this.checkUpdates = true,
    this.lastUpdateCheck,
    this.skippedVersion,
  });

  factory AppSettings.fromPrefs(Map<String, String> p) => AppSettings(
    onboarded: p[keyOnboarded] == 'true',
    beepStyle:
        BeepStyle.values.asNameMap()[p[keyBeepStyle]] ?? BeepStyle.classic,
    autoBackup: p[keyAutoBackup] != 'false',
    lastBackupAt: DateTime.tryParse(p[keyLastBackupAt] ?? ''),
    reminderDays: {
      for (final d in (p[keyReminderDays] ?? '').split(','))
        if (int.tryParse(d) case final n? when n >= 1 && n <= 7) n,
    },
    reminderMinutes: int.tryParse(p[keyReminderMinutes] ?? '') ?? 18 * 60,
    checkUpdates: p[keyCheckUpdates] != 'false',
    lastUpdateCheck: DateTime.tryParse(p[keyLastUpdateCheck] ?? ''),
    skippedVersion: p[keySkippedVersion],
  );

  static const keyOnboarded = 'onboarded';
  static const keyBeepStyle = 'beepStyle';
  static const keyAutoBackup = 'autoBackup';
  static const keyLastBackupAt = 'lastBackupAt';
  static const keyReminderDays = 'reminderDays';
  static const keyReminderMinutes = 'reminderMinutes';
  static const keyCheckUpdates = 'checkUpdates';
  static const keyLastUpdateCheck = 'lastUpdateCheck';
  static const keySkippedVersion = 'skippedVersion';

  /// Stored form of [reminderDays].
  static String encodeDays(Set<int> days) => (days.toList()..sort()).join(',');

  /// Preferences a backup carries to another phone. Device state such as
  /// [onboarded] and [lastBackupAt] stays behind.
  static const portableKeys = [
    keyBeepStyle,
    keyAutoBackup,
    keyReminderDays,
    keyReminderMinutes,
    keyCheckUpdates,
  ];

  final bool onboarded;
  final BeepStyle beepStyle;
  final bool autoBackup;
  final DateTime? lastBackupAt;

  /// Weekdays to remind on, 1 = Monday as in [DateTime.weekday].
  final Set<int> reminderDays;

  /// Reminder time as minutes after midnight.
  final int reminderMinutes;

  /// Ask GitHub once a day whether a newer release is out.
  final bool checkUpdates;
  final DateTime? lastUpdateCheck;

  /// A release the user chose "Later" on; not offered again.
  final String? skippedVersion;
}
