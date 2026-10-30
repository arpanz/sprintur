import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../data/settings.dart';
import '../widgets/beep_style_picker.dart';
import '../widgets/common.dart';

/// Shown once, before the tabs. Picks the beep sound and, on Android, asks
/// for the notification that keeps a session running with the screen off.
class FirstRunScreen extends ConsumerStatefulWidget {
  const FirstRunScreen({super.key});

  @override
  ConsumerState<FirstRunScreen> createState() => _FirstRunScreenState();
}

class _FirstRunScreenState extends ConsumerState<FirstRunScreen> {
  BeepStyle _style = BeepStyle.classic;
  bool? _notificationsAllowed;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    final status = await FlutterForegroundTask.checkNotificationPermission();
    if (mounted) {
      setState(
        () => _notificationsAllowed = status == NotificationPermission.granted,
      );
    }
  }

  Future<void> _allowNotifications() async {
    HapticFeedback.selectionClick();
    final status = await FlutterForegroundTask.requestNotificationPermission();
    if (mounted) {
      setState(
        () => _notificationsAllowed = status == NotificationPermission.granted,
      );
    }
  }

  Future<void> _start() async {
    HapticFeedback.mediumImpact();
    final db = ref.read(databaseProvider);
    await db.setPref(AppSettings.keyBeepStyle, _style.name);
    await db.setPref(AppSettings.keyOnboarded, 'true');
  }

  @override
  Widget build(BuildContext context) {
    final allowed = _notificationsAllowed;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    const _Hero(),
                    const SizedBox(height: 28),
                    Text('RUN THE\nCLOCK.', style: SprintText.display(56)),
                    const SizedBox(height: 12),
                    const Text(
                      'Timed sprints with beeps that tell you when to go and '
                      'whether you hit your pace.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: SprintColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'BEEP SOUND · TAP TO HEAR IT',
                      style: SprintText.label,
                    ),
                    const SizedBox(height: 10),
                    BeepStylePicker(
                      value: _style,
                      onChanged: (s) => setState(() => _style = s),
                    ),
                    if (Platform.isAndroid) ...[
                      const SizedBox(height: 16),
                      SectionCard(
                        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                        radius: 16,
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notifications',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Keeps the timer running and on your '
                                    'lock screen with the screen off',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.3,
                                      color: SprintColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: allowed == true
                                  ? const Padding(
                                      key: ValueKey('on'),
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: SprintColors.lime,
                                      ),
                                    )
                                  : TextButton(
                                      key: const ValueKey('ask'),
                                      onPressed: _allowNotifications,
                                      child: const Text('Allow'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 28),
                    BigButton(label: 'Get started', onPressed: _start),
                    const SizedBox(height: 12),
                    const Text(
                      'No account. Everything stays on this phone. Back up to '
                      'a file any time in Settings.',
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
            ),
          ),
        ),
      ),
    );
  }
}

/// The app icon's lime tile.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: SprintColors.lime,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(
          Icons.timer_outlined,
          size: 38,
          color: SprintColors.bg,
        ),
      ),
    );
  }
}
