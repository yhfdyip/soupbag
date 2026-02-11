import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/core/bootstrap/app_services.dart';
import 'package:soupbag/features/bookshelf/data/local/bookshelf_local_repository.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:soupbag/features/source_management/application/legado_source_importer.dart';
import 'package:soupbag/features/source_management/data/local/book_source_local_repository.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final BookshelfRepository _bookshelfRepository;
  late final BookSourceRepository _bookSourceRepository;
  late final LegadoSourceImporter _sourceImporter;

  int _bookCount = 0;
  int _sourceCount = 0;
  bool _loading = true;
  bool _busy = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    final database = AppServices.instance.database;
    _bookshelfRepository = BookshelfLocalRepository(database);
    _bookSourceRepository = BookSourceLocalRepository(database);
    _sourceImporter = LegadoSourceImporter(_bookSourceRepository);
    _refreshCounts();
  }

  Future<void> _refreshCounts() async {
    final books = await _bookshelfRepository.getBookshelf();
    final sources = await _bookSourceRepository.getBookSources();
    if (!mounted) return;
    setState(() {
      _bookCount = books.length;
      _sourceCount = sources.length;
      _loading = false;
    });
  }

  Future<void> _insertDemoData() async {
    if (_busy) return;
    setState(() => _busy = true);

    final now = DateTime.now().millisecondsSinceEpoch;

    await _bookshelfRepository.saveBook(
      BookEntity(
        bookUrl: 'demo://book/legado-sample',
        name: '示例小说（P1）',
        author: 'soupbag',
        origin: 'demo-source',
        originName: '示例书源',
        intro: '用于验证 Drift 最小读写闭环。',
        durChapterTime: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _bookSourceRepository.saveBookSource(
      BookSourceEntity(
        bookSourceUrl: 'demo://source/default',
        bookSourceName: '本地示例书源',
        searchUrl: 'https://example.com/search?q={{key}}',
        enabled: true,
        enabledExplore: true,
        lastUpdateTime: now,
      ),
    );

    await _refreshCounts();
    if (!mounted) return;
    setState(() {
      _statusMessage = '示例书籍与本地书源写入完成';
      _busy = false;
    });
  }

  Future<void> _importLegadoSampleSources() async {
    if (_busy) return;
    setState(() => _busy = true);

    final now = DateTime.now().millisecondsSinceEpoch;
    final payload = [
      {
        'bookSourceUrl': 'mock://search',
        'bookSourceName': 'Mock源（legado流程演示）',
        'bookSourceType': 0,
        'enabled': true,
        'enabledExplore': false,
        'bookSourceComment': '用于演示搜索->入架->目录->正文全链路',
        'lastUpdateTime': now,
        'searchUrl': 'mock://search?key={{key}}&page={{page}}',
        'ruleSearch': {
          'bookList': 'books',
          'name': 'name',
          'author': 'author',
          'bookUrl': 'bookUrl',
          'coverUrl': 'coverUrl',
          'intro': 'intro',
        },
        'ruleBookInfo': {
          'url': 'mock://book-info?book={{bookUrl}}',
          'name': 'name',
          'author': 'author',
          'intro': 'intro',
          'coverUrl': 'coverUrl',
          'tocUrl': 'tocUrl',
        },
        'ruleToc': {
          'url': 'mock://toc?book={{bookUrl}}',
          'chapterList': 'chapters',
          'chapterName': 'title',
          'chapterUrl': 'url',
        },
        'ruleContent': {'content': 'content'},
      },
      {
        'bookSourceUrl': 'https://openlibrary.org',
        'bookSourceName': 'OpenLibrary（legado兼容示例）',
        'bookSourceType': 0,
        'enabled': true,
        'enabledExplore': false,
        'bookSourceComment': '系统内置示例书源：用于验证 legado 导入与搜索链路',
        'lastUpdateTime': now,
        'searchUrl':
            'https://openlibrary.org/search.json?q={{key}}&page={{page}}',
        'ruleSearch': {
          'bookList': 'docs',
          'name': 'title',
          'author': 'author_name[0]',
          'bookUrl': 'key',
          'intro': 'first_sentence',
        },
      },
    ];

    final result = await _sourceImporter.importFromJsonString(
      jsonEncode(payload),
    );

    await _refreshCounts();
    if (!mounted) return;

    setState(() {
      _statusMessage =
          '导入完成：成功 ${result.successCount}，跳过 ${result.skippedCount}';
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(largeTitle: Text('设置')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadCard(
                  title: const Text('主题'),
                  description: const Text('已接入 Shadcn 亮暗主题（跟随系统）。'),
                  child: const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                ShadCard(
                  title: const Text('Legado 对标进度'),
                  description: Text(
                    _loading
                        ? '正在读取本地数据库...'
                        : '书籍：$_bookCount 本，书源：$_sourceCount 个',
                  ),
                  footer: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ShadButton.outline(
                              onPressed: _busy ? null : _refreshCounts,
                              child: const Text('刷新计数'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ShadButton(
                              onPressed: _busy ? null : _insertDemoData,
                              child: Text(_busy ? '处理中...' : '写入示例书籍'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ShadButton.outline(
                        onPressed: _busy ? null : _importLegadoSampleSources,
                        child: const Text('导入 legado 兼容示例书源'),
                      ),
                    ],
                  ),
                  child: _statusMessage == null
                      ? const SizedBox.shrink()
                      : Text(_statusMessage!),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
