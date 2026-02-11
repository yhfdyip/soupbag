import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/core/bootstrap/app_services.dart';
import 'package:soupbag/features/bookshelf/data/local/bookshelf_local_repository.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:soupbag/features/reader/data/local/reader_local_repository.dart';
import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';
import 'package:soupbag/features/reader/domain/services/legado_reader_service.dart';
import 'package:soupbag/features/source_management/data/local/book_source_local_repository.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key, this.initialBookUrl});

  final String? initialBookUrl;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late final BookshelfRepository _bookshelfRepository;
  late final BookSourceRepository _sourceRepository;
  late final ReaderLocalRepository _readerLocalRepository;
  late final LegadoReaderService _readerService;

  String? _currentBookUrl;
  String? _currentSourceUrl;
  String? _currentBookName;

  List<ChapterEntity> _chapters = const [];
  int _selectedIndex = 0;
  String? _currentContent;
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final services = AppServices.instance;
    _bookshelfRepository = BookshelfLocalRepository(services.database);
    _sourceRepository = BookSourceLocalRepository(services.database);
    _readerLocalRepository = ReaderLocalRepository(services.database);
    _readerService = LegadoReaderService(
      httpGateway: services.legadoHttpGateway,
      sourceRepository: _sourceRepository,
      bookshelfRepository: _bookshelfRepository,
    );

    final initial = widget.initialBookUrl;
    if (initial != null && initial.isNotEmpty) {
      _loadBook(initial);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      final sourceUrl = extra['sourceUrl'] as String?;
      final bookUrl = extra['bookUrl'] as String?;
      final bookName = extra['bookName'] as String?;
      if (sourceUrl != null && bookUrl != null) {
        _currentSourceUrl = sourceUrl;
        _currentBookName = bookName;
        _loadBook(bookUrl);
      }
    }
  }

  Future<void> _loadBook(String bookUrl) async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _message = '加载书籍中...';
    });

    final shelf = await _bookshelfRepository.getBookshelf();
    final target = shelf.where((book) => book.bookUrl == bookUrl).toList();
    if (target.isEmpty) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = '书籍不存在，请先在发现页添加到书架';
      });
      return;
    }

    final book = target.first;
    _currentBookUrl = book.bookUrl;
    _currentSourceUrl ??= book.origin;
    _currentBookName ??= book.name;

    final localChapters = await _readerLocalRepository.getChapters(book.bookUrl);
    if (localChapters.isNotEmpty) {
      setState(() {
        _chapters = localChapters;
        _selectedIndex = 0;
        _currentContent = localChapters.first.content;
        _busy = false;
        _message = '已加载本地缓存章节';
      });
      if (_currentContent == null || _currentContent!.isEmpty) {
        await _loadChapterContent(0);
      }
      return;
    }

    await _fetchChapters();
  }

  Future<void> _fetchChapters() async {
    final sourceUrl = _currentSourceUrl;
    final bookUrl = _currentBookUrl;
    if (sourceUrl == null || bookUrl == null) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = '缺少 sourceUrl/bookUrl，无法抓取目录';
      });
      return;
    }

    try {
      final chapters = await _readerService.fetchChapters(
        sourceUrl: sourceUrl,
        bookUrl: bookUrl,
      );

      await _readerLocalRepository.replaceChapters(bookUrl, chapters);
      if (!mounted) return;

      setState(() {
        _chapters = chapters;
        _selectedIndex = 0;
        _currentContent = null;
        _message = chapters.isEmpty ? '目录为空，请检查 ruleToc 规则' : '目录加载成功';
      });

      if (chapters.isNotEmpty) {
        await _loadChapterContent(0);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = '目录加载失败';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _loadChapterContent(int index) async {
    final sourceUrl = _currentSourceUrl;
    final bookUrl = _currentBookUrl;
    if (sourceUrl == null || bookUrl == null) {
      return;
    }
    if (index < 0 || index >= _chapters.length) {
      return;
    }

    setState(() {
      _busy = true;
      _selectedIndex = index;
      _message = '加载正文中...';
    });

    final chapter = _chapters[index];
    if (chapter.content != null && chapter.content!.isNotEmpty) {
      setState(() {
        _currentContent = chapter.content;
        _busy = false;
        _message = '正文来自本地缓存';
      });
      return;
    }

    try {
      final content = await _readerService.fetchChapterContent(
        sourceUrl: sourceUrl,
        bookUrl: bookUrl,
        chapter: chapter,
      );

      if (content != null && content.isNotEmpty) {
        await _readerLocalRepository.saveChapterContent(
          bookUrl: bookUrl,
          chapterIndex: chapter.chapterIndex,
          content: content,
        );
        final updated = List<ChapterEntity>.from(_chapters);
        updated[index] = ChapterEntity(
          bookUrl: chapter.bookUrl,
          chapterIndex: chapter.chapterIndex,
          title: chapter.title,
          chapterUrl: chapter.chapterUrl,
          content: content,
          isVolume: chapter.isVolume,
          updateTime: DateTime.now().millisecondsSinceEpoch,
        );

        if (!mounted) return;
        setState(() {
          _chapters = updated;
          _currentContent = content;
          _message = '正文加载成功';
        });
      } else {
        if (!mounted) return;
        setState(() {
          _message = '正文为空，请检查 ruleContent 规则';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = '正文加载失败';
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
    final theme = ShadTheme.of(context);

    return CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: Text(_currentBookName ?? '阅读'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ShadCard(
              title: Text('阅读器', style: theme.textTheme.h4),
              description: Text(_message ?? '等待选择书籍'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: CupertinoActivityIndicator(radius: 12),
                    ),
                  if (_chapters.isNotEmpty)
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final selected = index == _selectedIndex;
                          return ShadButton.outline(
                            onPressed: _busy ? null : () => _loadChapterContent(index),
                            child: Text(
                              _chapters[index].title,
                              style: TextStyle(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.foreground,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemCount: _chapters.length,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _currentContent ?? '暂无正文，请从发现页搜索并点击“加入书架并阅读”。',
                    style: theme.textTheme.p,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
