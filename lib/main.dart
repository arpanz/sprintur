import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'app/home_widgets.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'app/updates.dart';
import 'audio/cue_player.dart';
import 'data/auto_backup.dart';
import 'data/settings.dart';
import 'screens/first_run_screen.dart';
import 'widgets/update_sheet.dart';
import 'timer/keep_alive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await SessionKeepAlive.configure();
  } catch (e) {
    debugPrint('Audio session setup failed: $e');
  }
  final player = CuePlayer();

  runApp(
    ProviderScope(
      overrides: [cuePlayerProvider.overrideWithValue(player)],
      child: const SprinturApp(),
    ),
  );
}

class SprinturApp extends ConsumerStatefulWidget {
  const SprinturApp({super.key, this.launchTasks = true});

  /// Auto backup, the update check, and keeping reminders and widgets in
  /// step with the data. Off in widget tests, which have no platform.
  final bool launchTasks;

  @override
  ConsumerState<SprinturApp> createState() => _SprinturAppState();
}

class _SprinturAppState extends ConsumerState<SprinturApp> {
  final _router = buildRouter();
  final _widgets = HomeWidgets();
  StreamSubscription<Uri?>? _widgetClicks;

  @override
  void initState() {
    super.initState();
    if (!widget.launchTasks) return;
    ref.read(notificationsProvider)
      ..onOpen = _openFromNotification
      ..start();
    _autoBackup();
    _checkForUpdate();
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_openFromWidget);
    _widgetClicks = HomeWidget.widgetClicked.listen(_openFromWidget);
  }

  /// `sprintur://start` from the Next up widget starts the workout it shows;
  /// anything else just opens the app on the matching tab.
  void _openFromWidget(Uri? uri) {
    if (uri == null) return;
    switch (uri.host) {
      case 'start' when ref.read(settingsProvider).value?.onboarded ?? false:
        _router.go('/');
        _router.push('/live');
      case 'history':
        _router.go('/history');
      case 'settings':
        _router.go('/settings');
      default:
        _router.go('/');
    }
  }

  void _openFromNotification(String payload) => _router.go(switch (payload) {
    'history' => '/history',
    'settings' => '/settings',
    _ => '/',
  });

  Future<void> _checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final db = ref.read(databaseProvider);
      final release = await checkForUpdate(db, installed: info.version);
      final context = _router.routerDelegate.navigatorKey.currentContext;
      if (release == null || context == null || !context.mounted) return;
      final updated = await showUpdateSheet(context, release);
      if (!updated) {
        await db.setPref(AppSettings.keySkippedVersion, release.version);
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  /// Reminders mention the next workout and the backup nudge follows the
  /// last backup, so both are rescheduled when those change.
  void _syncOutside() {
    final settings = ref.read(settingsProvider).value;
    final sessions = ref.read(sessionsProvider).value;
    if (settings == null || sessions == null || !settings.onboarded) return;
    final notifications = ref.read(notificationsProvider);
    notifications.scheduleReminders(settings, ref.read(workoutProvider));
    notifications.scheduleBackupNudge(
      settings.lastBackupAt,
      sessions.isEmpty ? null : sessions.last.summary.finishedAt,
    );
    _widgets.publish(
      buildWidgetData(
        next: ref.read(workoutProvider),
        sessions: sessions,
        settings: settings,
        now: DateTime.now(),
      ),
    );
  }

  Future<void> _autoBackup() async {
    try {
      final file = await runAutoBackup(
        ref.read(databaseProvider),
        await getApplicationDocumentsDirectory(),
      );
      if (file != null) debugPrint('Auto backup written to ${file.path}');
    } catch (e) {
      debugPrint('Auto backup failed: $e');
    }
  }

  @override
  void dispose() {
    _widgetClicks?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.launchTasks) {
      ref.listen(settingsProvider, (_, _) => _syncOutside());
      ref.listen(sessionsProvider, (_, _) => _syncOutside());
      ref.listen(workoutProvider, (_, _) => _syncOutside());
    }
    return MaterialApp.router(
      title: 'Sprintur',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
      builder: (context, child) => _FirstRunGate(child: child!),
    );
  }
}

/// Shows the first-run screen over the app until it has been finished once.
class _FirstRunGate extends ConsumerWidget {
  const _FirstRunGate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarded = ref.watch(
      settingsProvider.select((s) => s.whenData((v) => v.onboarded)),
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      child: switch (onboarded) {
        AsyncData(value: true) => KeyedSubtree(
          key: const ValueKey('app'),
          child: child,
        ),
        AsyncData() => const FirstRunScreen(key: ValueKey('first-run')),
        // Prefs come from a local database, so this is a frame or two.
        _ => const ColoredBox(color: SprintColors.bg),
      },
    );
  }
}
