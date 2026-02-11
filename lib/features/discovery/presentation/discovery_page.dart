import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/core/bootstrap/app_services.dart';
import 'package:soupbag/core/parser/legado_search_rule_parser.dart';
import 'package:soupbag/features/discovery/domain/models/search_result_entity.dart';
import 'package:soupbag/features/discovery/domain/services/legado_search_service.dart';
import 'package:soupbag/features/reader/domain/services/legado_reader_service.dart';
import 'package:soupbag/features/source_management/data/local/book_source_local_repository.dart';
import 'package:soupbag/features/bookshelf/data/local/bookshelf_local_repository.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  late final TextEditingController _controller;
  late final LegadoSearchService _searchService;
  late final LegadoReaderService _readerService;

  List<SearchResultEntity> _results = const [];
  bool _searching = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    final services = AppServices.instance;
    final sourceRepository = BookSourceLocalRepository(services.database);
    _searchService = LegadoSearchService(
      httpGateway: services.legadoHttpGateway,
      sourceRepository: sourceRepository,
      parser: LegadoSearchRuleParser(),
    );
    _readerService = LegadoReaderService(
      httpGateway: services.legadoHttpGateway,
      sourceRepository: sourceRepository,
      bookshelfRepository: BookshelfLocalRepository(services.database),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_searching) return;

    final keyword = _controller.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _message = '请输入关键词';
      });
      return;
    }

    setState(() {
      _searching = true;
      _message = '正在搜索...';
    });

    try {
      final results = await _searchService.search(keyword);
      if (!mounted) return;
      setState(() {
        _results = results;
        _message = results.isEmpty
            ? '没有搜索到结果，请检查书源规则'
            : '找到 ${results.length} 条结果';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = '搜索失败，请稍后重试';
      });
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  void _clearResults() {
    setState(() {
      _results = const [];
      _message = '已清空搜索结果';
    });
  }

  void _openBookDetail(SearchResultEntity result) {
    context.push(
      '/discovery/book-detail',
      extra: {
        'sourceUrl': result.sourceUrl,
        'sourceName': result.sourceName,
        'name': result.name,
        'author': result.author,
        'bookUrl': result.bookUrl,
        'coverUrl': result.coverUrl,
        'intro': result.intro,
      },
    );
  }

  Future<void> _addToShelfAndRead(SearchResultEntity result) async {
    setState(() {
      _searching = true;
      _message = '正在加入书架...';
    });

    try {
      final book = await _readerService.addSearchResultToBookshelf(
        sourceUrl: result.sourceUrl,
        name: result.name,
        author: result.author,
        bookUrl: result.bookUrl,
        coverUrl: result.coverUrl,
        intro: result.intro,
      );

      if (!mounted) return;
      context.go(
        '/reader',
        extra: {
          'sourceUrl': result.sourceUrl,
          'bookUrl': book.bookUrl,
          'bookName': book.name,
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = '加入书架失败';
      });
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(largeTitle: Text('发现')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadInput(
                  controller: _controller,
                  placeholder: const Text('搜索书名 / 作者 / 关键词'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ShadButton(
                        onPressed: _searching ? null : _search,
                        child: Text(_searching ? '搜索中...' : '开始搜索'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShadButton.outline(
                        onPressed: _searching ? null : _clearResults,
                        child: const Text('清空结果'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_searching)
                  const Center(child: CupertinoActivityIndicator(radius: 12)),
                if (_message != null) ...[
                  Text(_message!),
                  const SizedBox(height: 12),
                ],
                if (_results.isEmpty)
                  const ShadCard(
                    title: Text('提示'),
                    description: Text('先在“设置”里导入 legado 兼容书源，再回来搜索。'),
                    child: SizedBox.shrink(),
                  ),
                ..._results
                    .take(30)
                    .map(
                      (result) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ShadCard(
                          title: Text(result.name),
                          description: Text(
                            '${result.author ?? '未知作者'} · ${result.sourceName}',
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(result.bookUrl ?? '无详情链接'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ShadButton.outline(
                                      onPressed: _searching
                                          ? null
                                          : () => _openBookDetail(result),
                                      child: const Text('查看详情'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ShadButton(
                                      onPressed: _searching
                                          ? null
                                          : () => _addToShelfAndRead(result),
                                      child: const Text('快速阅读'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
