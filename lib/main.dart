import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'audio/cue_player.dart';
import 'data/auto_backup.dart';
import 'screens/first_run_screen.dart';
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
  const SprinturApp({super.key, this.autoBackup = true});

  /// Off in widget tests, which have no documents folder.
  final bool autoBackup;

  @override
  ConsumerState<SprinturApp> createState() => _SprinturAppState();
}

class _SprinturAppState extends ConsumerState<SprinturApp> {
  final _router = buildRouter();

  @override
  void initState() {
    super.initState();
    if (widget.autoBackup) _autoBackup();
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
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
