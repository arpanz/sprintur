import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'audio/cue_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final player = CuePlayer();
  try {
    await player.init();
  } catch (e) {
    // The timer is still usable on haptics alone.
    debugPrint('Audio init failed, running without beeps: $e');
  }

  runApp(
    ProviderScope(
      overrides: [cuePlayerProvider.overrideWithValue(player)],
      child: const SprinturApp(),
    ),
  );
}

class SprinturApp extends StatelessWidget {
  const SprinturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sprintur',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: router,
    );
  }
}
