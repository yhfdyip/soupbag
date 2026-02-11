import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/core/bootstrap/app_services.dart';
import 'package:soupbag/features/bookshelf/data/local/bookshelf_local_repository.dart';
import 'package:soupbag/features/discovery/domain/models/explore_kind_entity.dart';
import 'package:soupbag/features/discovery/domain/models/search_result_entity.dart';
import 'package:soupbag/features/discovery/domain/services/legado_search_service.dart';
import 'package:soupbag/features/reader/domain/services/legado_reader_service.dart';
import 'package:soupbag/features/source_management/data/local/book_source_local_repository.dart';

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
  List<ExploreSourceKindsEntity> _exploreKinds = const [];
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
    if (_searching) {
      return;
    }

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
      if (!mounted) {
        return;
      }
      setState(() {
        _results = results;
        _message = results.isEmpty
            ? '没有搜索到结果，请检查书源规则'
            : '找到 ${results.length} 条结果';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
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

  void _openExploreResults({
    required String title,
    String? sourceUrl,
    String? sourceName,
    String? exploreUrl,
  }) {
    context.push(
      '/discovery/explore-results',
      extra: {
        'title': title,
        'sourceUrl': sourceUrl,
        'sourceName': sourceName,
        'exploreUrl': exploreUrl,
      },
    );
  }

  Future<void> _loadExploreKinds() async {
    if (_searching) {
      return;
    }

    setState(() {
      _searching = true;
      _message = '正在加载发现分类...';
    });

    try {
      final groups = await _searchService.getExploreKinds();
      if (!mounted) {
        return;
      }
      setState(() {
        _exploreKinds = groups;
        _message = groups.isEmpty
            ? '没有可用的发现分类（可能书源是纯 URL 或 JS 分类）'
            : '已加载 ${groups.length} 个书源分类';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = '发现分类加载失败，请稍后重试';
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

      if (!mounted) {
        return;
      }
      context.go(
        '/reader',
        extra: {
          'sourceUrl': result.sourceUrl,
          'bookUrl': book.bookUrl,
          'bookName': book.name,
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
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

  Widget _buildExploreKinds() {
    if (_exploreKinds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('发现分类（按书源）'),
        const SizedBox(height: 8),
        ..._exploreKinds.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ShadCard(
              title: Text(group.sourceName),
              description: Text(group.sourceUrl),
              child: LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildKindWidgets(
                    group: group,
                    maxWidth: constraints.maxWidth,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildKindWidgets({
    required ExploreSourceKindsEntity group,
    required double maxWidth,
  }) {
    final widgets = <Widget>[];

    for (final kind in group.kinds) {
      final kindUrl = (kind.exploreUrl ?? '').trim();
      final style = kind.style;

      var width = _resolveKindWidth(style: style, maxWidth: maxWidth);
      final alignSelf = style?.layoutAlignSelf ?? 'auto';
      final needAlignWidth =
          alignSelf == 'flex_end' ||
          alignSelf == 'center' ||
          alignSelf == 'stretch';
      if (needAlignWidth && width == null) {
        width = maxWidth;
      }

      final button = ShadButton.outline(
        onPressed: _searching || kindUrl.isEmpty
            ? null
            : () => _openExploreResults(
                title: '${group.sourceName} · ${kind.title}',
                sourceUrl: group.sourceUrl,
                sourceName: group.sourceName,
                exploreUrl: kindUrl,
              ),
        child: Text(kind.title),
      );

      Widget child = button;
      if (width != null) {
        child = SizedBox(width: width, child: child);
      }

      if (style != null) {
        child = Align(
          alignment: _resolveKindAlignment(style.layoutAlignSelf),
          child: child,
        );
      }

      if (style?.layoutWrapBefore == true) {
        widgets.add(SizedBox(width: maxWidth, height: 0));
      }
      widgets.add(child);
    }

    return widgets;
  }

  double? _resolveKindWidth({
    required ExploreKindStyleEntity? style,
    required double maxWidth,
  }) {
    if (style == null) {
      return null;
    }

    if (style.layoutAlignSelf == 'stretch') {
      return maxWidth;
    }

    final basisPercent = style.layoutFlexBasisPercent;
    if (basisPercent > 0 && basisPercent <= 1) {
      final rawWidth = maxWidth * basisPercent;
      return rawWidth.clamp(88, maxWidth).toDouble();
    }

    return null;
  }

  Alignment _resolveKindAlignment(String layoutAlignSelf) {
    switch (layoutAlignSelf) {
      case 'flex_end':
        return Alignment.centerRight;
      case 'center':
        return Alignment.center;
      case 'flex_start':
      case 'baseline':
      case 'auto':
      default:
        return Alignment.centerLeft;
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        onPressed: _searching
                            ? null
                            : () => _openExploreResults(title: '发现推荐'),
                        child: const Text('加载发现推荐'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShadButton.outline(
                        onPressed: _searching ? null : _loadExploreKinds,
                        child: const Text('加载发现分类'),
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
                _buildExploreKinds(),
                if (_exploreKinds.isNotEmpty) const SizedBox(height: 12),
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
                              if ((result.latestChapter ?? '')
                                  .trim()
                                  .isNotEmpty)
                                Text('最新：${result.latestChapter!}'),
                              if ((result.kind ?? '').trim().isNotEmpty)
                                Text('分类：${result.kind!}'),
                              if ((result.wordCount ?? '').trim().isNotEmpty)
                                Text('字数：${result.wordCount!}'),
                              Text(result.bookUrl ?? '无详情链接'),
                              if ((result.intro ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  result.intro!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
