import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rrr/screens/health/daily_checklist/daily_checklist_result_screen.dart';
import 'package:rrr/screens/home_screen.dart';
import 'package:rrr/screens/profile_screen.dart';
import 'package:rrr/screens/fortune/fortune_screen.dart';
import 'package:rrr/screens/fortune/fortune_loading_screen.dart';
import 'package:rrr/screens/fortune/fortune_result_screen.dart';
import 'package:rrr/screens/health/daily_checklist/daily_checklist_screen.dart';
import 'package:rrr/screens/support/error_screen.dart';
import 'package:rrr/screens/support/onboarding_screen.dart';
import 'package:rrr/widgets/global/bottom_navigation_bar.dart';

GoRouter createRouter(bool seenOnboarding) {
  return GoRouter(
    initialLocation: seenOnboarding ? '/home' : '/onboarding',
    errorBuilder: (context, state) => const ErrorScreen(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomBottomNavigationBar(navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder:
                    (context, state) => _buildFadePage(
                      key: state.pageKey,
                      child: const HomeScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/error', builder: (context, state) => const ErrorScreen()),
      GoRoute(
        path: '/fortune',
        builder: (context, state) => const FortuneScreen(),
      ),
      GoRoute(
        path: '/fortuneLoading',
        pageBuilder: (context, state) {
          final sft = state.uri.queryParameters['sft'] ?? 'all';

          return _buildFadeScalePage(
            key: state.pageKey,
            child: FortuneLoadingScreen(selectedFortuneTheme: sft),
          );
        },
      ),
      GoRoute(
        path: '/fortuneResult',
        pageBuilder: (context, state) {
          final ftt = state.uri.queryParameters['ftt'] ?? '';
          final ft = state.uri.queryParameters['ft'] ?? '';
          final ftd = state.uri.queryParameters['ftd'] ?? '';

          return _buildFadeScalePage(
            key: state.pageKey,
            child: FortuneResultScreen(
              fortuneTheme: ftt,
              fortune: ft,
              fortuneDescription: ftd,
            ),
          );
        },
      ),
      GoRoute(
        path: '/dailyChecklist',
        builder: (context, state) => const DailyChecklistScreen(),
      ),
      GoRoute(
        path: '/dailyChecklistResult',
        pageBuilder:
            (context, state) => _buildFadePage(
              key: state.pageKey,
              child: const DailyChecklistResultScreen(),
            ),
      ),
    ],
  );
}

// Fade 전환 (홈 → 로딩)
CustomTransitionPage _buildFadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// Fade + Scale 전환 (로딩 → 결과)
CustomTransitionPage _buildFadeScalePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.9,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
  );
}
