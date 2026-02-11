import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/core/bootstrap/app_services.dart';
import 'package:soupbag/features/bookshelf/data/local/bookshelf_local_repository.dart';
import 'package:soupbag/features/reader/domain/services/legado_reader_service.dart';
import 'package:soupbag/features/source_management/data/local/book_source_local_repository.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({
    super.key,
    required this.sourceUrl,
    required this.sourceName,
    required this.name,
    this.author,
    this.bookUrl,
    this.coverUrl,
    this.intro,
  });

  final String sourceUrl;
  final String sourceName;
  final String name;
  final String? author;
  final String? bookUrl;
  final String? coverUrl;
  final String? intro;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late final LegadoReaderService _readerService;

  LegadoBookInfo? _bookInfo;
  bool _loading = false;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final services = AppServices.instance;
    final sourceRepository = BookSourceLocalRepository(services.database);
    _readerService = LegadoReaderService(
      httpGateway: services.legadoHttpGateway,
      sourceRepository: sourceRepository,
      bookshelfRepository: BookshelfLocalRepository(services.database),
    );
    _loadBookInfo();
  }

  LegadoBookInfo _fallbackBookInfo() {
    final rawBookUrl = widget.bookUrl?.trim();
    final bookUrl = (rawBookUrl == null || rawBookUrl.isEmpty)
        ? 'generated://book/${DateTime.now().millisecondsSinceEpoch}'
        : rawBookUrl;

    return LegadoBookInfo(
      sourceUrl: widget.sourceUrl,
      sourceName: widget.sourceName,
      name: widget.name,
      author: widget.author ?? '',
      bookUrl: bookUrl,
      tocUrl: bookUrl,
      coverUrl: widget.coverUrl,
      intro: widget.intro,
    );
  }

  Future<void> _loadBookInfo() async {
    if (_loading) {
      return;
    }

    setState(() {
      _loading = true;
      _message = '正在加载详情...';
    });

    try {
      final detail = await _readerService.fetchBookInfo(
        sourceUrl: widget.sourceUrl,
        fallbackName: widget.name,
        fallbackAuthor: widget.author,
        fallbackBookUrl: widget.bookUrl,
        fallbackCoverUrl: widget.coverUrl,
        fallbackIntro: widget.intro,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _bookInfo = detail;
        _message = '详情加载完成';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bookInfo = _fallbackBookInfo();
        _message = '详情加载失败，已使用搜索结果兜底';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _addToShelf({required bool openReader}) async {
    if (_busy) {
      return;
    }

    final info = _bookInfo ?? _fallbackBookInfo();

    setState(() {
      _busy = true;
      _message = openReader ? '正在加入书架并打开阅读...' : '正在加入书架...';
    });

    try {
      final book = await _readerService.addSearchResultToBookshelf(
        sourceUrl: info.sourceUrl,
        name: info.name,
        author: info.author,
        bookUrl: info.bookUrl,
        coverUrl: info.coverUrl,
        intro: info.intro,
        tocUrl: info.tocUrl,
      );

      if (!mounted) {
        return;
      }
      if (openReader) {
        context.go(
          '/reader',
          extra: {
            'sourceUrl': info.sourceUrl,
            'bookUrl': book.bookUrl,
            'bookName': book.name,
          },
        );
        return;
      }

      setState(() {
        _message = '已加入书架：${book.name}';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = openReader ? '加入书架并阅读失败' : '加入书架失败';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _bookInfo;
    final authorText = (() {
      final candidate = (info?.author ?? widget.author ?? '').trim();
      return candidate.isEmpty ? '未知作者' : candidate;
    })();
    final sourceText = info?.sourceName ?? widget.sourceName;

    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(largeTitle: Text('书籍详情')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadCard(
                  title: Text(info?.name ?? widget.name),
                  description: Text('$authorText · $sourceText'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('书籍链接：${info?.bookUrl ?? widget.bookUrl ?? '无'}'),
                      const SizedBox(height: 4),
                      Text('目录链接：${info?.tocUrl ?? '无'}'),
                      if (info?.kind?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text('分类：${info!.kind}'),
                      ],
                      if (info?.wordCount?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text('字数：${info!.wordCount}'),
                      ],
                      if (info?.latestChapter?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text('最新章节：${info!.latestChapter}'),
                      ],
                      if (info?.updateTime?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text('更新时间：${info!.updateTime}'),
                      ],
                      if ((info?.coverUrl ?? widget.coverUrl)
                              ?.trim()
                              .isNotEmpty ??
                          false) ...[
                        const SizedBox(height: 4),
                        Text('封面链接：${info?.coverUrl ?? widget.coverUrl}'),
                      ],
                      if (info?.downloadUrls.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text('下载链接：${info!.downloadUrls.length} 个'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ShadCard(
                  title: const Text('简介'),
                  description: const Text('来自 ruleBookInfo / 搜索结果兜底'),
                  child: Text(
                    (info?.intro ?? widget.intro)?.trim().isEmpty ?? true
                        ? '暂无简介'
                        : (info?.intro ?? widget.intro)!,
                  ),
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Center(child: CupertinoActivityIndicator(radius: 12)),
                if (_message != null) ...[
                  Text(_message!),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        onPressed: (_busy || _loading)
                            ? null
                            : () => _addToShelf(openReader: false),
                        child: Text(_busy ? '处理中...' : '加入书架'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShadButton(
                        onPressed: (_busy || _loading)
                            ? null
                            : () => _addToShelf(openReader: true),
                        child: const Text('加入并阅读'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ShadButton.outline(
                  onPressed: (_busy || _loading) ? null : _loadBookInfo,
                  child: const Text('刷新详情'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
