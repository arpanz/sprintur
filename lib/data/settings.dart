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
  });

  factory AppSettings.fromPrefs(Map<String, String> p) => AppSettings(
    onboarded: p[keyOnboarded] == 'true',
    beepStyle:
        BeepStyle.values.asNameMap()[p[keyBeepStyle]] ?? BeepStyle.classic,
    autoBackup: p[keyAutoBackup] != 'false',
    lastBackupAt: DateTime.tryParse(p[keyLastBackupAt] ?? ''),
  );

  static const keyOnboarded = 'onboarded';
  static const keyBeepStyle = 'beepStyle';
  static const keyAutoBackup = 'autoBackup';
  static const keyLastBackupAt = 'lastBackupAt';

  /// Preferences a backup carries to another phone. Device state such as
  /// [onboarded] and [lastBackupAt] stays behind.
  static const portableKeys = [keyBeepStyle, keyAutoBackup];

  final bool onboarded;
  final BeepStyle beepStyle;
  final bool autoBackup;
  final DateTime? lastBackupAt;
}
