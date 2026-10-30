import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../screens/builder_screen.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/live_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/summary_screen.dart';
import '../timer/session_summary.dart';
import 'theme.dart';

/// One per app instance, so tests each start from a fresh navigation stack.
GoRouter buildRouter() => GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => TabShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) =>
                  _slide(state, const HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              pageBuilder: (context, state) =>
                  _slide(state, const HistoryScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) =>
                  _slide(state, const SettingsScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/builder',
      pageBuilder: (context, state) => _slide(state, const BuilderScreen()),
    ),
    GoRoute(
      path: '/live',
      pageBuilder: (context, state) => _rise(state, const LiveScreen()),
    ),
    GoRoute(
      path: '/summary',
      redirect: (context, state) => state.extra is SessionSummary ? null : '/',
      pageBuilder: (context, state) =>
          _rise(state, SummaryScreen(summary: state.extra! as SessionSummary)),
    ),
    GoRoute(
      path: '/session',
      redirect: (context, state) =>
          state.extra is StoredSession ? null : '/history',
      pageBuilder: (context, state) {
        final stored = state.extra! as StoredSession;
        return _slide(
          state,
          SummaryScreen(
            summary: stored.summary,
            sessionId: stored.id,
            rpe: stored.rpe,
          ),
        );
      },
    ),
  ],
);

/// The bottom bar shared by the top-level tabs.
class TabShell extends StatelessWidget {
  const TabShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: SprintColors.navBg,
          border: Border(top: BorderSide(color: Color(0xFF1C1F24))),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: SprintColors.navBg,
            indicatorColor: SprintColors.lime.withValues(alpha: 0.14),
            height: 64,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: states.contains(WidgetState.selected)
                    ? SprintColors.lime
                    : SprintColors.muted,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                size: 22,
                color: states.contains(WidgetState.selected)
                    ? SprintColors.lime
                    : SprintColors.muted,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _duration = Duration(milliseconds: 320);

/// Fade in while sliding 30 px from the right; the page underneath fades back.
CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: _duration,
    reverseTransitionDuration: _duration,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final out = CurvedAnimation(
        parent: secondary,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.4).animate(out),
        child: FadeTransition(
          opacity: curved,
          child: AnimatedBuilder(
            animation: curved,
            builder: (context, child) => Transform.translate(
              offset: Offset(30 * (1 - curved.value), 0),
              child: child,
            ),
            child: child,
          ),
        ),
      );
    },
  );
}

/// The session screens rise from below, so starting a run feels like a mode.
CustomTransitionPage<void> _rise(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: _duration,
    reverseTransitionDuration: _duration,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, 60 * (1 - curved.value)),
            child: child,
          ),
          child: child,
        ),
      );
    },
  );
}
