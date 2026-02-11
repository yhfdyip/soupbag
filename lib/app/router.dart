import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:soupbag/features/bookshelf/presentation/bookshelf_page.dart';
import 'package:soupbag/features/discovery/presentation/book_detail_page.dart';
import 'package:soupbag/features/discovery/presentation/discovery_page.dart';
import 'package:soupbag/features/discovery/presentation/explore_results_page.dart';
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
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: BookshelfPage()),
        ),
        GoRoute(
          path: '/discovery',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DiscoveryPage()),
          routes: [
            GoRoute(
              path: 'book-detail',
              pageBuilder: (context, state) {
                final payload = state.extra;
                final map = payload is Map
                    ? payload
                    : const <String, dynamic>{};

                String readString(String key, {String fallback = ''}) {
                  final value = map[key];
                  if (value is String) {
                    final trimmed = value.trim();
                    return trimmed.isEmpty ? fallback : trimmed;
                  }
                  return fallback;
                }

                String? readNullableString(String key) {
                  final value = map[key];
                  if (value is String) {
                    final trimmed = value.trim();
                    return trimmed.isEmpty ? null : trimmed;
                  }
                  return null;
                }

                return CupertinoPage(
                  child: BookDetailPage(
                    sourceUrl: readString('sourceUrl'),
                    sourceName: readString('sourceName', fallback: '未知书源'),
                    name: readString('name', fallback: '未命名书籍'),
                    author: readNullableString('author'),
                    bookUrl: readNullableString('bookUrl'),
                    coverUrl: readNullableString('coverUrl'),
                    intro: readNullableString('intro'),
                  ),
                );
              },
            ),

            GoRoute(
              path: 'explore-results',
              pageBuilder: (context, state) {
                final payload = state.extra;
                final map = payload is Map
                    ? payload
                    : const <String, dynamic>{};

                String readString(String key, {String fallback = ''}) {
                  final value = map[key];
                  if (value is String) {
                    final trimmed = value.trim();
                    return trimmed.isEmpty ? fallback : trimmed;
                  }
                  return fallback;
                }

                String? readNullableString(String key) {
                  final value = map[key];
                  if (value is String) {
                    final trimmed = value.trim();
                    return trimmed.isEmpty ? null : trimmed;
                  }
                  return null;
                }

                return CupertinoPage(
                  child: ExploreResultsPage(
                    title: readString('title', fallback: '发现结果'),
                    sourceUrl: readNullableString('sourceUrl'),
                    sourceName: readNullableString('sourceName'),
                    exploreUrl: readNullableString('exploreUrl'),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/reader',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ReaderPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),
  ],
);
