import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'audio/cue_player.dart';
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

class SprinturApp extends StatefulWidget {
  const SprinturApp({super.key});

  @override
  State<SprinturApp> createState() => _SprinturAppState();
}

class _SprinturAppState extends State<SprinturApp> {
  final _router = buildRouter();

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
    );
  }
}
