import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:soupbag/features/bookshelf/presentation/bookshelf_page.dart';
import 'package:soupbag/features/discovery/presentation/discovery_page.dart';
import 'package:soupbag/features/reader/presentation/reader_page.dart';
import 'package:soupbag/features/settings/presentation/settings_page.dart';

part 'shell_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/bookshelf',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/bookshelf',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BookshelfPage(),
          ),
        ),
        GoRoute(
          path: '/discovery',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DiscoveryPage(),
          ),
        ),
        GoRoute(
          path: '/reader',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ReaderPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);
