import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/core/bootstrap/app_services.dart';
import 'package:soupbag/features/bookshelf/data/local/bookshelf_local_repository.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:soupbag/features/reader/data/local/reader_local_repository.dart';
import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';
import 'package:soupbag/features/reader/domain/services/legado_reader_service.dart';
import 'package:soupbag/features/source_management/data/local/book_source_local_repository.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

enum ReaderThemePreset { day, sepia, night }

class _ReaderPalette {
  const _ReaderPalette({
    required this.background,
    required this.text,
    required this.menuBackground,
    required this.menuText,
    required this.mutedText,
  });

  final Color background;
  final Color text;
  final Color menuBackground;
  final Color menuText;
  final Color mutedText;
}

class _LocalSearchMatch {
  const _LocalSearchMatch({
    required this.chapterListIndex,
    required this.chapterTitle,
    required this.chapterHitCount,
    required this.hitOrderInChapter,
    required this.keywordOffset,
    required this.preview,
  });

  final int chapterListIndex;
  final String chapterTitle;
  final int chapterHitCount;
  final int hitOrderInChapter;
  final int keywordOffset;
  final String preview;
}

class _ReplaceRule {
  const _ReplaceRule({
    required this.id,
    required this.pattern,
    required this.replacement,
    required this.enabled,
    required this.useRegex,
  });

  final String id;
  final String pattern;
  final String replacement;
  final bool enabled;
  final bool useRegex;

  _ReplaceRule copyWith({
    String? id,
    String? pattern,
    String? replacement,
    bool? enabled,
    bool? useRegex,
  }) {
    return _ReplaceRule(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      replacement: replacement ?? this.replacement,
      enabled: enabled ?? this.enabled,
      useRegex: useRegex ?? this.useRegex,
    );
  }
}

class _ReaderBookmark {
  const _ReaderBookmark({
    required this.id,
    required this.chapterIndex,
    required this.chapterTitle,
    required this.createdAt,
    required this.preview,
  });

  final String id;
  final int chapterIndex;
  final String chapterTitle;
  final int createdAt;
  final String preview;

  _ReaderBookmark copyWith({
    String? id,
    int? chapterIndex,
    String? chapterTitle,
    int? createdAt,
    String? preview,
  }) {
    return _ReaderBookmark(
      id: id ?? this.id,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      createdAt: createdAt ?? this.createdAt,
      preview: preview ?? this.preview,
    );
  }
}

class _ReaderHistoryItem {
  const _ReaderHistoryItem({
    required this.chapterIndex,
    required this.chapterTitle,
    required this.readAt,
  });

  final int chapterIndex;
  final String chapterTitle;
  final int readAt;
}

enum ReaderPageMode { scroll, cover }

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
  final ScrollController _contentScrollController = ScrollController();

  BookEntity? _currentBook;
  String? _currentBookUrl;
  String? _currentSourceUrl;
  String? _currentBookName;

  List<ChapterEntity> _chapters = const [];
  int _selectedIndex = 0;
  String? _currentContent;
  String? _message;
  bool _busy = false;

  ReaderThemePreset _themePreset = ReaderThemePreset.day;
  ReaderPageMode _pageMode = ReaderPageMode.scroll;
  double _fontSize = 20;
  double _lineHeight = 1.9;
  double _brightness = 1;
  bool _followSystemBrightness = true;
  bool _menuVisible = false;
  bool _showBrightnessPanel = true;
  bool _tapToTurnPage = true;
  bool _autoPaging = false;
  List<_ReplaceRule> _replaceRules = const [];
  List<_ReaderBookmark> _bookmarks = const [];
  List<_ReaderHistoryItem> _history = const [];
  String _replacePreview = '暂无预览';
  List<String> _coverPages = const [];
  int _coverPageIndex = 0;
  String _searchHighlightKeyword = '';
  int _searchHighlightChapterIndex = -1;
  int _searchHighlightOffset = -1;
  final PageController _coverPageController = PageController();
  Timer? _autoPagingTimer;

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

    _restoreReaderPreferences();

    final initial = widget.initialBookUrl;
    if (initial != null && initial.isNotEmpty) {
      _loadBook(initial);
    }
  }

  @override
  void dispose() {
    _autoPagingTimer?.cancel();
    _contentScrollController.dispose();
    _coverPageController.dispose();
    super.dispose();
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
      _bookmarks = const [];
      _history = const [];
      _searchHighlightKeyword = '';
      _searchHighlightChapterIndex = -1;
      _searchHighlightOffset = -1;
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
    _currentBook = book;
    _currentBookUrl = book.bookUrl;
    _currentSourceUrl ??= book.origin;
    _currentBookName ??= book.name;

    await _restoreBookScopedReadingData(book.bookUrl);

    final localChapters = await _readerLocalRepository.getChapters(
      book.bookUrl,
    );
    if (localChapters.isNotEmpty) {
      final startIndex = _normalizeIndex(
        value: book.durChapterIndex,
        size: localChapters.length,
      );
      setState(() {
        _chapters = localChapters;
        _selectedIndex = startIndex;
        _currentContent = localChapters[startIndex].content;
        _busy = false;
        _message = '已加载本地缓存章节';
      });
      _resetContentOffset();
      if (_currentContent == null || _currentContent!.isEmpty) {
        await _loadChapterContent(startIndex);
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

      final book = _currentBook;
      if (book != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        _currentBook = BookEntity(
          bookUrl: book.bookUrl,
          tocUrl: book.tocUrl,
          origin: book.origin,
          originName: book.originName,
          name: book.name,
          author: book.author,
          coverUrl: book.coverUrl,
          intro: book.intro,
          totalChapterNum: chapters.length,
          durChapterIndex: book.durChapterIndex,
          durChapterPos: book.durChapterPos,
          durChapterTime: book.durChapterTime,
          lastCheckTime: now,
          createdAt: book.createdAt,
          updatedAt: now,
        );
        await _bookshelfRepository.saveBook(_currentBook!);
      }

      await _readerLocalRepository.replaceChapters(bookUrl, chapters);
      if (!mounted) return;

      final startIndex = _normalizeIndex(
        value: _currentBook?.durChapterIndex ?? 0,
        size: chapters.length,
      );

      setState(() {
        _chapters = chapters;
        _selectedIndex = startIndex;
        _currentContent = null;
        _message = chapters.isEmpty ? '目录为空，请检查 ruleToc 规则' : '目录加载成功';
      });

      if (chapters.isNotEmpty) {
        await _loadChapterContent(startIndex);
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

  Future<void> _loadChapterContent(
    int index, {
    String? searchKeyword,
    int? searchHitOffset,
  }) async {
    final sourceUrl = _currentSourceUrl;
    final bookUrl = _currentBookUrl;
    if (sourceUrl == null || bookUrl == null) {
      return;
    }
    if (index < 0 || index >= _chapters.length) {
      return;
    }

    final normalizedSearchKeyword = searchKeyword?.trim() ?? '';
    final shouldHighlightSearch = normalizedSearchKeyword.isNotEmpty;

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
      _applySearchHighlightContext(
        chapterIndex: index,
        keyword: shouldHighlightSearch ? normalizedSearchKeyword : null,
        keywordOffset: shouldHighlightSearch ? searchHitOffset : null,
      );
      _updateReplacePreview();
      _rebuildCoverPages();
      _recordHistoryForChapter(index);
      await _saveReadProgress(index);
      _syncContentOffsetAfterLoad(highlightedSearch: shouldHighlightSearch);
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
        _applySearchHighlightContext(
          chapterIndex: index,
          keyword: shouldHighlightSearch ? normalizedSearchKeyword : null,
          keywordOffset: shouldHighlightSearch ? searchHitOffset : null,
        );
        _updateReplacePreview();
        _rebuildCoverPages();
        _recordHistoryForChapter(index);
        await _saveReadProgress(index);
        _syncContentOffsetAfterLoad(highlightedSearch: shouldHighlightSearch);
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

  Future<void> _saveReadProgress(int chapterIndex) async {
    final book = _currentBook;
    if (book == null) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedBook = BookEntity(
      bookUrl: book.bookUrl,
      tocUrl: book.tocUrl,
      origin: book.origin,
      originName: book.originName,
      name: book.name,
      author: book.author,
      coverUrl: book.coverUrl,
      intro: book.intro,
      totalChapterNum: _chapters.isEmpty
          ? book.totalChapterNum
          : _chapters.length,
      durChapterIndex: chapterIndex,
      durChapterPos: 0,
      durChapterTime: now,
      lastCheckTime: book.lastCheckTime,
      createdAt: book.createdAt,
      updatedAt: now,
    );

    _currentBook = updatedBook;
    await _bookshelfRepository.saveBook(updatedBook);
  }

  Future<void> _restoreReaderPreferences() async {
    final themeRaw = await _readerLocalRepository.getPreference(
      ReaderPreferenceKeys.themePreset,
    );
    final fontSizeRaw = await _readerLocalRepository.getPreference(
      ReaderPreferenceKeys.fontSize,
    );
    final lineHeightRaw = await _readerLocalRepository.getPreference(
      ReaderPreferenceKeys.lineHeight,
    );
    final pageModeRaw = await _readerLocalRepository.getPreference(
      ReaderPreferenceKeys.pageMode,
    );
    final brightnessRaw = await _readerLocalRepository.getPreference(
      ReaderPreferenceKeys.brightness,
    );
    final followSystemBrightnessRaw = await _readerLocalRepository
        .getPreference(ReaderPreferenceKeys.followSystemBrightness);
    final showBrightnessPanelRaw = await _readerLocalRepository.getPreference(
      ReaderPreferenceKeys.showBrightnessPanel,
    );
    final tapToTurnPageRaw = await _readerLocalRepository.getPreference(
      ReaderPreferenceKeys.tapToTurnPage,
    );
    final replaceRulesRaw = await _readerLocalRepository.getPreference(
      ReaderPreferenceKeys.replaceRules,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _themePreset = _decodeThemePreset(themeRaw);
      _pageMode = _decodePageMode(pageModeRaw);
      _fontSize = _decodeDouble(fontSizeRaw, fallback: 20, min: 14, max: 30);
      _lineHeight = _decodeDouble(
        lineHeightRaw,
        fallback: 1.9,
        min: 1.2,
        max: 2.6,
      );
      _brightness = _decodeDouble(
        brightnessRaw,
        fallback: 1,
        min: 0.25,
        max: 1,
      );
      _followSystemBrightness = _decodeBool(
        followSystemBrightnessRaw,
        fallback: true,
      );
      _showBrightnessPanel = _decodeBool(
        showBrightnessPanelRaw,
        fallback: true,
      );
      _tapToTurnPage = _decodeBool(tapToTurnPageRaw, fallback: true);
      _replaceRules = _decodeReplaceRules(replaceRulesRaw);
    });

    _updateReplacePreview();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rebuildCoverPages();
    });
  }

  ReaderThemePreset _decodeThemePreset(String? value) {
    if (value == null) {
      return ReaderThemePreset.day;
    }
    return ReaderThemePreset.values.firstWhere(
      (preset) => preset.name == value,
      orElse: () => ReaderThemePreset.day,
    );
  }

  ReaderPageMode _decodePageMode(String? value) {
    if (value == null) {
      return ReaderPageMode.scroll;
    }
    return ReaderPageMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ReaderPageMode.scroll,
    );
  }

  double _decodeDouble(
    String? value, {
    required double fallback,
    required double min,
    required double max,
  }) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null) {
      return fallback;
    }
    return parsed.clamp(min, max).toDouble();
  }

  bool _decodeBool(String? value, {required bool fallback}) {
    if (value == null) {
      return fallback;
    }
    if (value == 'true' || value == '1') {
      return true;
    }
    if (value == 'false' || value == '0') {
      return false;
    }
    return fallback;
  }

  void _savePreference(String key, String value) {
    unawaited(_readerLocalRepository.savePreference(key: key, value: value));
  }

  String _bookScopedPreferenceKey(String baseKey, String bookUrl) {
    return '$baseKey::$bookUrl';
  }

  String? _currentBookScopedPreferenceKey(String baseKey) {
    final bookUrl = _currentBookUrl;
    if (bookUrl == null || bookUrl.isEmpty) {
      return null;
    }
    return _bookScopedPreferenceKey(baseKey, bookUrl);
  }

  void _saveBookScopedPreference(String baseKey, String value) {
    final scopedKey = _currentBookScopedPreferenceKey(baseKey);
    if (scopedKey == null) {
      return;
    }
    _savePreference(scopedKey, value);
  }

  Future<void> _restoreBookScopedReadingData(String bookUrl) async {
    final bookmarksKey = _bookScopedPreferenceKey(
      ReaderPreferenceKeys.bookmarks,
      bookUrl,
    );
    final historyKey = _bookScopedPreferenceKey(
      ReaderPreferenceKeys.history,
      bookUrl,
    );

    var bookmarksRaw = await _readerLocalRepository.getPreference(bookmarksKey);
    if (bookmarksRaw == null || bookmarksRaw.trim().isEmpty) {
      final legacy = await _readerLocalRepository.getPreference(
        ReaderPreferenceKeys.bookmarks,
      );
      if (legacy != null && legacy.trim().isNotEmpty) {
        bookmarksRaw = legacy;
        _savePreference(bookmarksKey, legacy);
      }
    }

    var historyRaw = await _readerLocalRepository.getPreference(historyKey);
    if (historyRaw == null || historyRaw.trim().isEmpty) {
      final legacy = await _readerLocalRepository.getPreference(
        ReaderPreferenceKeys.history,
      );
      if (legacy != null && legacy.trim().isNotEmpty) {
        historyRaw = legacy;
        _savePreference(historyKey, legacy);
      }
    }

    if (!mounted || _currentBookUrl != bookUrl) {
      return;
    }

    setState(() {
      _bookmarks = _decodeBookmarks(bookmarksRaw);
      _history = _decodeHistory(historyRaw);
    });
  }

  void _saveLayoutPreferences() {
    _savePreference(ReaderPreferenceKeys.themePreset, _themePreset.name);
    _savePreference(ReaderPreferenceKeys.pageMode, _pageMode.name);
    _savePreference(
      ReaderPreferenceKeys.fontSize,
      _fontSize.toStringAsFixed(1),
    );
    _savePreference(
      ReaderPreferenceKeys.lineHeight,
      _lineHeight.toStringAsFixed(2),
    );
  }

  void _rebuildCoverPages() {
    if (_pageMode != ReaderPageMode.cover) {
      return;
    }

    final content = _effectiveContent();
    final pageSize = (_fontSize >= 24)
        ? 220
        : (_fontSize >= 20)
        ? 300
        : 380;
    final normalizedContent = content.trim();
    if (normalizedContent.isEmpty) {
      setState(() {
        _coverPages = const ['暂无正文'];
        _coverPageIndex = 0;
      });
      return;
    }

    final pages = <String>[];
    for (var start = 0; start < normalizedContent.length; start += pageSize) {
      final end = (start + pageSize).clamp(0, normalizedContent.length);
      pages.add(normalizedContent.substring(start, end));
    }
    if (pages.isEmpty) {
      pages.add('暂无正文');
    }

    setState(() {
      _coverPages = pages;
      _coverPageIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_coverPageController.hasClients) {
        _coverPageController.jumpToPage(0);
      }
    });
  }

  void _saveInteractionPreferences() {
    _savePreference(
      ReaderPreferenceKeys.followSystemBrightness,
      _followSystemBrightness.toString(),
    );
    _savePreference(
      ReaderPreferenceKeys.showBrightnessPanel,
      _showBrightnessPanel.toString(),
    );
    _savePreference(
      ReaderPreferenceKeys.tapToTurnPage,
      _tapToTurnPage.toString(),
    );
    _savePreference(
      ReaderPreferenceKeys.brightness,
      _brightness.toStringAsFixed(2),
    );
  }

  List<_ReplaceRule> _decodeReplaceRules(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((item) {
            final map = item.cast<String, dynamic>();
            return _ReplaceRule(
              id:
                  map['id'] as String? ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              pattern: map['pattern'] as String? ?? '',
              replacement: map['replacement'] as String? ?? '',
              enabled: map['enabled'] as bool? ?? true,
              useRegex: map['useRegex'] as bool? ?? false,
            );
          })
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  void _saveReplaceRules() {
    final serialized = jsonEncode(
      _replaceRules
          .map(
            (rule) => {
              'id': rule.id,
              'pattern': rule.pattern,
              'replacement': rule.replacement,
              'enabled': rule.enabled,
              'useRegex': rule.useRegex,
            },
          )
          .toList(growable: false),
    );

    _savePreference(ReaderPreferenceKeys.replaceRules, serialized);
  }

  List<_ReaderBookmark> _decodeBookmarks(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((item) {
            final map = item.cast<String, dynamic>();
            return _ReaderBookmark(
              id:
                  map['id'] as String? ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              chapterIndex: map['chapterIndex'] as int? ?? 0,
              chapterTitle: map['chapterTitle'] as String? ?? '未命名章节',
              createdAt: map['createdAt'] as int? ?? 0,
              preview: map['preview'] as String? ?? '',
            );
          })
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  List<_ReaderHistoryItem> _decodeHistory(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((item) {
            final map = item.cast<String, dynamic>();
            return _ReaderHistoryItem(
              chapterIndex: map['chapterIndex'] as int? ?? 0,
              chapterTitle: map['chapterTitle'] as String? ?? '未命名章节',
              readAt: map['readAt'] as int? ?? 0,
            );
          })
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  void _saveBookmarks() {
    final serialized = jsonEncode(
      _bookmarks
          .map(
            (item) => {
              'id': item.id,
              'chapterIndex': item.chapterIndex,
              'chapterTitle': item.chapterTitle,
              'createdAt': item.createdAt,
              'preview': item.preview,
            },
          )
          .toList(growable: false),
    );
    _saveBookScopedPreference(ReaderPreferenceKeys.bookmarks, serialized);
  }

  void _saveHistory() {
    final serialized = jsonEncode(
      _history
          .map(
            (item) => {
              'chapterIndex': item.chapterIndex,
              'chapterTitle': item.chapterTitle,
              'readAt': item.readAt,
            },
          )
          .toList(growable: false),
    );
    _saveBookScopedPreference(ReaderPreferenceKeys.history, serialized);
  }

  String _buildBookmarkPreview() {
    final content = _effectiveContent().replaceAll('\n', ' ').trim();
    if (content.isEmpty) {
      return '暂无内容';
    }
    final limit = content.length.clamp(0, 70);
    return '${content.substring(0, limit)}${content.length > 70 ? '...' : ''}';
  }

  void _recordHistoryForChapter(int chapterIndex) {
    if (chapterIndex < 0 || chapterIndex >= _chapters.length) {
      return;
    }

    final chapterTitle = _chapters[chapterIndex].title;
    final now = DateTime.now().millisecondsSinceEpoch;

    final nextHistory = [
      _ReaderHistoryItem(
        chapterIndex: chapterIndex,
        chapterTitle: chapterTitle,
        readAt: now,
      ),
      ..._history.where(
        (item) =>
            item.chapterIndex != chapterIndex ||
            item.chapterTitle != chapterTitle,
      ),
    ];

    setState(() {
      _history = nextHistory.take(100).toList(growable: false);
    });
    _saveHistory();
  }

  String _formatCompactTime(int timestamp) {
    if (timestamp <= 0) {
      return '未知时间';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }

  Future<void> _addCurrentBookmark() async {
    if (_chapters.isEmpty ||
        _selectedIndex < 0 ||
        _selectedIndex >= _chapters.length) {
      setState(() {
        _message = '当前无可添加书签的章节';
      });
      return;
    }

    final chapter = _chapters[_selectedIndex];
    final exists = _bookmarks.any(
      (bookmark) => bookmark.chapterIndex == _selectedIndex,
    );
    if (exists) {
      setState(() {
        _message = '该章节已存在书签';
      });
      return;
    }

    final bookmark = _ReaderBookmark(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      chapterIndex: _selectedIndex,
      chapterTitle: chapter.title,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      preview: _buildBookmarkPreview(),
    );

    setState(() {
      _bookmarks = [bookmark, ..._bookmarks];
      _message = '已添加书签：${chapter.title}';
    });
    _saveBookmarks();
  }

  Future<void> _openBookmarkHistoryPanel() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, panelSetState) {
            return SafeArea(
              top: false,
              child: CupertinoPopupSurface(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.78,
                  child: Column(
                    children: [
                      Container(
                        height: 54,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            CupertinoButton(
                              minimumSize: const Size(68, 32),
                              padding: EdgeInsets.zero,
                              onPressed: _addCurrentBookmark,
                              child: const Text('加书签'),
                            ),
                            const Expanded(
                              child: Text(
                                '书签与历史',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            CupertinoButton(
                              minimumSize: const Size(68, 32),
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('关闭'),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: CupertinoColors.separator),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '书签 ${_bookmarks.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '历史 ${_history.length}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: CupertinoColors.separator),
                      Expanded(
                        child: ListView(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(12, 10, 12, 4),
                              child: Text(
                                '书签',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (_bookmarks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(12, 6, 12, 10),
                                child: Text(
                                  '暂无书签',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              )
                            else
                              ..._bookmarks.map(
                                (bookmark) => CupertinoButton(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    8,
                                  ),
                                  onPressed: _busy
                                      ? null
                                      : () async {
                                          Navigator.of(context).pop();
                                          await _loadChapterContent(
                                            bookmark.chapterIndex,
                                          );
                                        },
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bookmark.chapterTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: CupertinoColors.label,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              bookmark.preview,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    CupertinoColors.systemGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatCompactTime(bookmark.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                      CupertinoButton(
                                        minimumSize: const Size(28, 28),
                                        padding: const EdgeInsets.only(left: 6),
                                        onPressed: () {
                                          setState(() {
                                            _bookmarks = _bookmarks
                                                .where(
                                                  (item) =>
                                                      item.id != bookmark.id,
                                                )
                                                .toList(growable: false);
                                          });
                                          panelSetState(() {});
                                          _saveBookmarks();
                                        },
                                        child: const Icon(
                                          CupertinoIcons.delete,
                                          color: CupertinoColors.destructiveRed,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(12, 10, 12, 4),
                              child: Text(
                                '阅读历史',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (_history.isEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(12, 6, 12, 10),
                                child: Text(
                                  '暂无阅读历史',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              )
                            else
                              ..._history
                                  .take(40)
                                  .map(
                                    (item) => CupertinoButton(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        8,
                                        12,
                                        8,
                                      ),
                                      onPressed: _busy
                                          ? null
                                          : () async {
                                              Navigator.of(context).pop();
                                              await _loadChapterContent(
                                                item.chapterIndex,
                                              );
                                            },
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.chapterTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: CupertinoColors.label,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatCompactTime(item.readAt),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _applyReplaceRules(String content) {
    var output = content;
    for (final rule in _replaceRules) {
      if (!rule.enabled || rule.pattern.trim().isEmpty) {
        continue;
      }

      if (rule.useRegex) {
        try {
          output = output.replaceAll(RegExp(rule.pattern), rule.replacement);
        } catch (_) {
          continue;
        }
      } else {
        output = output.replaceAll(rule.pattern, rule.replacement);
      }
    }

    return output;
  }

  String _effectiveContent() {
    final content = _currentContent;
    if (content == null || content.isEmpty) {
      return '暂无正文，请先在发现页搜索并加入书架。';
    }
    return _applyReplaceRules(content);
  }

  void _updateReplacePreview() {
    final content = _currentContent;
    if (content == null || content.trim().isEmpty) {
      setState(() {
        _replacePreview = '暂无正文可预览';
      });
      return;
    }

    final transformed = _applyReplaceRules(content);
    if (transformed == content) {
      setState(() {
        _replacePreview = '当前规则未命中本章内容';
      });
      return;
    }

    final preview = transformed.replaceAll('\n', ' ').trim();
    setState(() {
      _replacePreview = preview.isEmpty
          ? '净化后正文为空'
          : '${preview.substring(0, preview.length.clamp(0, 90))}${preview.length > 90 ? '...' : ''}';
    });
  }

  int _normalizeIndex({required int value, required int size}) {
    if (size <= 0) {
      return 0;
    }
    if (value < 0) {
      return 0;
    }
    if (value >= size) {
      return size - 1;
    }
    return value;
  }

  void _resetContentOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_contentScrollController.hasClients) {
        _contentScrollController.jumpTo(0);
      }
    });
  }

  void _syncContentOffsetAfterLoad({required bool highlightedSearch}) {
    if (highlightedSearch) {
      _scrollToSearchHighlight();
      return;
    }
    _resetContentOffset();
  }

  void _scrollToSearchHighlight() {
    if (_pageMode != ReaderPageMode.scroll) {
      _resetContentOffset();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_contentScrollController.hasClients) {
        return;
      }
      if (_searchHighlightKeyword.isEmpty ||
          _searchHighlightChapterIndex != _selectedIndex) {
        _resetContentOffset();
        return;
      }

      final content = _effectiveContent();
      if (content.trim().isEmpty) {
        _resetContentOffset();
        return;
      }

      final bodyTextStyle = TextStyle(
        color: CupertinoColors.label,
        fontSize: _fontSize,
        height: _lineHeight,
        letterSpacing: 0.2,
      );
      final titleTextStyle = TextStyle(
        color: CupertinoColors.label,
        fontSize: _fontSize + 2,
        fontWeight: FontWeight.w600,
      );
      final metaTextStyle = const TextStyle(fontSize: 12, letterSpacing: 0.3);

      final maxWidth = (MediaQuery.sizeOf(context).width - 40).clamp(
        120.0,
        double.infinity,
      );
      final bodyOffset = _estimateSearchBodyOffset(
        content: content,
        keyword: _searchHighlightKeyword,
        focusedOffset: _searchHighlightOffset,
        style: bodyTextStyle,
        maxWidth: maxWidth,
      );
      final headerOffset = _estimateReadingHeaderHeight(
        maxWidth: maxWidth,
        titleStyle: titleTextStyle,
        metaStyle: metaTextStyle,
      );

      final target = (headerOffset + bodyOffset - (_fontSize * 2.2))
          .clamp(0.0, _contentScrollController.position.maxScrollExtent)
          .toDouble();
      _contentScrollController.jumpTo(target);
    });
  }

  double _estimateReadingHeaderHeight({
    required double maxWidth,
    required TextStyle titleStyle,
    required TextStyle metaStyle,
  }) {
    var height = 0.0;

    if (_currentBookName != null) {
      final bookNamePainter = TextPainter(
        text: TextSpan(text: _currentBookName!, style: metaStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: maxWidth);
      height += bookNamePainter.height;
      height += 4;
    }

    final chapterTitle = _chapters.isNotEmpty
        ? _chapters[_selectedIndex].title
        : '未选择章节';
    final chapterTitlePainter = TextPainter(
      text: TextSpan(text: chapterTitle, style: titleStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
    height += chapterTitlePainter.height;
    height += 22;

    return height;
  }

  double _estimateSearchBodyOffset({
    required String content,
    required String keyword,
    required int focusedOffset,
    required TextStyle style,
    required double maxWidth,
  }) {
    final hitOffsets = _collectKeywordOffsets(content, keyword);
    if (hitOffsets.isEmpty) {
      return 0;
    }

    final focusedHitIndex = _resolveFocusedHitIndex(
      hitOffsets: hitOffsets,
      preferredOffset: focusedOffset,
    );
    final hitOffset = hitOffsets[focusedHitIndex]
        .clamp(0, content.length)
        .toInt();

    final prefixText = content.substring(0, hitOffset);
    final textPainter = TextPainter(
      text: TextSpan(text: prefixText, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.start,
    )..layout(maxWidth: maxWidth);

    return textPainter.height;
  }

  void _toggleMenu() {
    setState(() {
      _menuVisible = !_menuVisible;
    });
  }

  void _toggleNightTheme() {
    setState(() {
      _themePreset = _themePreset == ReaderThemePreset.night
          ? ReaderThemePreset.day
          : ReaderThemePreset.night;
      _message = _themePreset == ReaderThemePreset.night
          ? '已切换夜间模式'
          : '已切换白天模式';
    });
    _saveLayoutPreferences();
  }

  void _togglePageMode() {
    setState(() {
      _pageMode = _pageMode == ReaderPageMode.scroll
          ? ReaderPageMode.cover
          : ReaderPageMode.scroll;
      _message = _pageMode == ReaderPageMode.scroll ? '已切换滚动模式' : '已切换覆盖模式';
    });
    _saveLayoutPreferences();
    _rebuildCoverPages();
  }

  void _toggleAutoPaging() {
    setState(() {
      _autoPaging = !_autoPaging;
      _message = _autoPaging ? '自动翻页已开启' : '自动翻页已关闭';
    });

    _autoPagingTimer?.cancel();
    if (_autoPaging) {
      _autoPagingTimer = Timer.periodic(const Duration(seconds: 12), (_) {
        if (!_busy && _chapters.isNotEmpty) {
          _goNextChapter();
        }
      });
    }
  }

  void _handleReadTap(TapUpDetails details, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final x = details.localPosition.dx;

    if (!_tapToTurnPage) {
      _toggleMenu();
      return;
    }

    if (x < width * 0.32) {
      if (_pageMode == ReaderPageMode.cover && _coverPageIndex > 0) {
        _coverPageController.previousPage(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
        );
      } else {
        _goPreviousChapter();
      }
      return;
    }
    if (x > width * 0.68) {
      if (_pageMode == ReaderPageMode.cover &&
          _coverPageIndex < _coverPages.length - 1) {
        _coverPageController.nextPage(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
        );
      } else {
        _goNextChapter();
      }
      return;
    }
    _toggleMenu();
  }

  Future<void> _goPreviousChapter() async {
    if (_busy || _chapters.isEmpty || _selectedIndex <= 0) {
      return;
    }
    await _loadChapterContent(_selectedIndex - 1);
  }

  Future<void> _goNextChapter() async {
    if (_busy || _chapters.isEmpty || _selectedIndex >= _chapters.length - 1) {
      return;
    }
    await _loadChapterContent(_selectedIndex + 1);
  }

  List<_LocalSearchMatch> _searchInCachedChapters(String keyword) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) {
      return const [];
    }

    final matches = <_LocalSearchMatch>[];
    for (var index = 0; index < _chapters.length; index += 1) {
      final chapter = _chapters[index];
      final content = chapter.content;
      if (content == null || content.trim().isEmpty) {
        continue;
      }

      final normalizedContent = content.toLowerCase();
      final hitOffsets = <int>[];
      var offset = 0;
      while (true) {
        final foundAt = normalizedContent.indexOf(normalizedKeyword, offset);
        if (foundAt < 0) {
          break;
        }
        hitOffsets.add(foundAt);
        offset = foundAt + normalizedKeyword.length;
      }

      if (hitOffsets.isEmpty) {
        continue;
      }

      final chapterHitCount = hitOffsets.length;
      for (var hitOrder = 0; hitOrder < chapterHitCount; hitOrder += 1) {
        final hitOffset = hitOffsets[hitOrder];
        final preview = _buildSearchPreview(
          content: content,
          keyword: keyword,
          firstHitIndex: hitOffset,
        );

        matches.add(
          _LocalSearchMatch(
            chapterListIndex: index,
            chapterTitle: chapter.title,
            chapterHitCount: chapterHitCount,
            hitOrderInChapter: hitOrder,
            keywordOffset: hitOffset,
            preview: preview,
          ),
        );
      }
    }

    return matches;
  }

  String _buildSearchPreview({
    required String content,
    required String keyword,
    required int firstHitIndex,
  }) {
    const contextLength = 32;
    final start = (firstHitIndex - contextLength).clamp(0, content.length);
    final end = (firstHitIndex + keyword.length + contextLength).clamp(
      0,
      content.length,
    );

    final prefix = start > 0 ? '...' : '';
    final suffix = end < content.length ? '...' : '';
    final snippet = content.substring(start, end).replaceAll('\n', ' ').trim();
    if (snippet.isEmpty) {
      return '（命中关键词，片段为空）';
    }
    return '$prefix$snippet$suffix';
  }

  void _applySearchHighlightContext({
    required int chapterIndex,
    String? keyword,
    int? keywordOffset,
  }) {
    final normalizedKeyword = keyword?.trim() ?? '';
    final hasKeyword = normalizedKeyword.isNotEmpty;
    final nextKeyword = hasKeyword ? normalizedKeyword : '';
    final nextChapterIndex = hasKeyword ? chapterIndex : -1;
    final nextOffset = hasKeyword ? (keywordOffset ?? -1) : -1;

    if (_searchHighlightKeyword == nextKeyword &&
        _searchHighlightChapterIndex == nextChapterIndex &&
        _searchHighlightOffset == nextOffset) {
      return;
    }

    setState(() {
      _searchHighlightKeyword = nextKeyword;
      _searchHighlightChapterIndex = nextChapterIndex;
      _searchHighlightOffset = nextOffset;
    });
  }

  List<int> _collectKeywordOffsets(String content, String keyword) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    if (content.isEmpty || normalizedKeyword.isEmpty) {
      return const [];
    }

    final normalizedContent = content.toLowerCase();
    final hitOffsets = <int>[];
    var searchOffset = 0;
    while (true) {
      final foundAt = normalizedContent.indexOf(
        normalizedKeyword,
        searchOffset,
      );
      if (foundAt < 0) {
        break;
      }
      hitOffsets.add(foundAt);
      searchOffset = foundAt + normalizedKeyword.length;
    }
    return hitOffsets;
  }

  int _resolveFocusedHitIndex({
    required List<int> hitOffsets,
    required int preferredOffset,
  }) {
    if (hitOffsets.isEmpty) {
      return 0;
    }
    if (preferredOffset < 0) {
      return 0;
    }

    final exactIndex = hitOffsets.indexOf(preferredOffset);
    if (exactIndex >= 0) {
      return exactIndex;
    }

    var focusedIndex = 0;
    var minDistance = (hitOffsets.first - preferredOffset).abs();
    for (var index = 0; index < hitOffsets.length; index += 1) {
      final distance = (hitOffsets[index] - preferredOffset).abs();
      if (distance < minDistance) {
        minDistance = distance;
        focusedIndex = index;
      }
    }
    return focusedIndex;
  }

  List<InlineSpan> _buildSearchHighlightSpans({
    required String content,
    required String keyword,
    required TextStyle baseStyle,
    required Color highlightColor,
    required Color focusedHighlightColor,
    required int focusedOffset,
  }) {
    if (keyword.isEmpty || content.isEmpty) {
      return [TextSpan(text: content)];
    }

    final hitOffsets = _collectKeywordOffsets(content, keyword);
    if (hitOffsets.isEmpty) {
      return [TextSpan(text: content)];
    }

    final focusedHit = _resolveFocusedHitIndex(
      hitOffsets: hitOffsets,
      preferredOffset: focusedOffset,
    );

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (var hitIndex = 0; hitIndex < hitOffsets.length; hitIndex += 1) {
      final start = hitOffsets[hitIndex];
      final end = (start + keyword.length).clamp(0, content.length);
      if (start > cursor) {
        spans.add(TextSpan(text: content.substring(cursor, start)));
      }

      final isFocused = hitIndex == focusedHit;
      spans.add(
        TextSpan(
          text: content.substring(start, end),
          style: baseStyle.copyWith(
            backgroundColor: isFocused ? focusedHighlightColor : highlightColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      cursor = end;
    }

    if (cursor < content.length) {
      spans.add(TextSpan(text: content.substring(cursor)));
    }

    return spans;
  }

  Widget _buildContentText({
    required String content,
    required TextStyle style,
    required Color highlightColor,
    required Color focusedHighlightColor,
    bool useFocusedOffset = true,
  }) {
    final keyword = _searchHighlightKeyword;
    final highlightEnabled =
        keyword.isNotEmpty && _searchHighlightChapterIndex == _selectedIndex;

    if (!highlightEnabled) {
      return Text(content, style: style);
    }

    final spans = _buildSearchHighlightSpans(
      content: content,
      keyword: keyword,
      baseStyle: style,
      highlightColor: highlightColor,
      focusedHighlightColor: focusedHighlightColor,
      focusedOffset: useFocusedOffset ? _searchHighlightOffset : -1,
    );

    return RichText(
      text: TextSpan(style: style, children: spans),
      textAlign: TextAlign.start,
    );
  }

  Future<void> _openLocalSearchPanel() async {
    final cachedCount = _chapters.where(_chapterCached).length;
    if (_chapters.isEmpty || cachedCount == 0) {
      setState(() {
        _message = '暂无可搜索的本地缓存章节';
      });
      return;
    }

    final searchController = TextEditingController();
    var keyword = '';
    var results = const <_LocalSearchMatch>[];

    try {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, panelSetState) {
              return SafeArea(
                top: false,
                child: CupertinoPopupSurface(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.76,
                    child: Column(
                      children: [
                        Container(
                          height: 54,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const SizedBox(width: 32),
                              const Expanded(
                                child: Text(
                                  '全文搜索（仅本地缓存）',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              CupertinoButton(
                                minimumSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Icon(CupertinoIcons.clear_thick),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: CupertinoColors.separator),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '可搜索章节：$cachedCount / ${_chapters.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CupertinoSearchTextField(
                                controller: searchController,
                                placeholder: '输入关键词后，回车搜索',
                                onChanged: (value) {
                                  keyword = value.trim();
                                },
                                onSubmitted: (value) {
                                  panelSetState(() {
                                    keyword = value.trim();
                                    results = _searchInCachedChapters(keyword);
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                onPressed: () {
                                  panelSetState(() {
                                    keyword = searchController.text.trim();
                                    results = _searchInCachedChapters(keyword);
                                  });
                                },
                                child: const Text('搜索'),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: CupertinoColors.separator),
                        if (keyword.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text(
                                '输入关键词开始搜索',
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          )
                        else if (results.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text(
                                '本地缓存中未找到匹配内容',
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              itemCount: results.length,
                              separatorBuilder: (_, _) => Container(
                                height: 1,
                                color: CupertinoColors.separator,
                              ),
                              itemBuilder: (context, index) {
                                final result = results[index];
                                final selected =
                                    result.chapterListIndex == _selectedIndex &&
                                    result.keywordOffset ==
                                        _searchHighlightOffset &&
                                    _searchHighlightKeyword == keyword.trim();

                                return CupertinoButton(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    9,
                                    12,
                                    9,
                                  ),
                                  onPressed: _busy
                                      ? null
                                      : () async {
                                          Navigator.of(context).pop();
                                          await _loadChapterContent(
                                            result.chapterListIndex,
                                            searchKeyword: keyword,
                                            searchHitOffset:
                                                result.keywordOffset,
                                          );
                                          if (!mounted) {
                                            return;
                                          }
                                          setState(() {
                                            _message =
                                                '已跳转：${result.chapterTitle}（第 ${result.hitOrderInChapter + 1}/${result.chapterHitCount} 处）';
                                          });
                                        },
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              result.chapterTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: selected
                                                    ? CupertinoColors.activeBlue
                                                    : CupertinoColors.label,
                                                fontWeight: selected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '第 ${result.hitOrderInChapter + 1}/${result.chapterHitCount} 处',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        result.preview,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      searchController.dispose();
    }
  }

  Future<void> _openReplaceRulePanel() async {
    final patternController = TextEditingController();
    final replacementController = TextEditingController();
    var regexMode = false;

    Future<void> openAddRuleDialog(StateSetter panelSetState) async {
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, dialogSetState) {
              return CupertinoAlertDialog(
                title: const Text('新增净化规则'),
                content: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        controller: patternController,
                        placeholder: '匹配文本 / 正则',
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: replacementController,
                        placeholder: '替换为（可留空）',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('正则模式', style: TextStyle(fontSize: 13)),
                          const Spacer(),
                          CupertinoSwitch(
                            value: regexMode,
                            onChanged: (value) {
                              dialogSetState(() {
                                regexMode = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('取消'),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () {
                      final pattern = patternController.text.trim();
                      final replacement = replacementController.text;
                      if (pattern.isEmpty) {
                        return;
                      }

                      setState(() {
                        _replaceRules = [
                          ..._replaceRules,
                          _ReplaceRule(
                            id: DateTime.now().microsecondsSinceEpoch
                                .toString(),
                            pattern: pattern,
                            replacement: replacement,
                            enabled: true,
                            useRegex: regexMode,
                          ),
                        ];
                      });
                      panelSetState(() {});
                      _saveReplaceRules();
                      _updateReplacePreview();

                      patternController.clear();
                      replacementController.clear();
                      regexMode = false;
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('添加'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    try {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, panelSetState) {
              return SafeArea(
                top: false,
                child: CupertinoPopupSurface(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.72,
                    child: Column(
                      children: [
                        Container(
                          height: 54,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              CupertinoButton(
                                minimumSize: const Size(60, 32),
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    openAddRuleDialog(panelSetState),
                                child: const Text('新增'),
                              ),
                              const Expanded(
                                child: Text(
                                  '替换净化',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              CupertinoButton(
                                minimumSize: const Size(60, 32),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _message = '净化规则已应用到当前阅读';
                                  });
                                  _rebuildCoverPages();
                                },
                                child: const Text('完成'),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: CupertinoColors.separator),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '规则 ${_replaceRules.length} 条（启用 ${_replaceRules.where((rule) => rule.enabled).length} 条）',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '当前章预览：$_replacePreview',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: CupertinoColors.separator),
                        if (_replaceRules.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text(
                                '暂无净化规则',
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              itemCount: _replaceRules.length,
                              separatorBuilder: (_, _) => Container(
                                height: 1,
                                color: CupertinoColors.separator,
                              ),
                              itemBuilder: (context, index) {
                                final rule = _replaceRules[index];

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rule.pattern,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${rule.useRegex ? '正则' : '文本'} → ${rule.replacement.isEmpty ? '（空）' : rule.replacement}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    CupertinoColors.systemGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoSwitch(
                                        value: rule.enabled,
                                        onChanged: (value) {
                                          setState(() {
                                            _replaceRules = [
                                              for (final item in _replaceRules)
                                                if (item.id == rule.id)
                                                  item.copyWith(enabled: value)
                                                else
                                                  item,
                                            ];
                                          });
                                          panelSetState(() {});
                                          _saveReplaceRules();
                                          _updateReplacePreview();
                                        },
                                      ),
                                      CupertinoButton(
                                        minimumSize: const Size(28, 28),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          setState(() {
                                            _replaceRules = _replaceRules
                                                .where(
                                                  (item) => item.id != rule.id,
                                                )
                                                .toList(growable: false);
                                          });
                                          panelSetState(() {});
                                          _saveReplaceRules();
                                          _updateReplacePreview();
                                        },
                                        child: const Icon(
                                          CupertinoIcons.delete,
                                          color: CupertinoColors.destructiveRed,
                                          size: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      patternController.dispose();
      replacementController.dispose();
    }
  }

  bool _chapterCached(ChapterEntity chapter) {
    final content = chapter.content;
    return content != null && content.trim().isNotEmpty;
  }

  Future<void> _jumpFromCatalog(BuildContext popupContext, int index) async {
    Navigator.of(popupContext).pop();
    await _loadChapterContent(index);
  }

  Future<void> _openChapterCatalog() async {
    if (_chapters.isEmpty) {
      setState(() {
        _message = '暂无目录，请先加载章节';
      });
      return;
    }

    final searchController = TextEditingController();
    final listController = ScrollController(
      initialScrollOffset: (_selectedIndex * 58).toDouble(),
    );
    var keyword = '';

    final cachedCount = _chapters.where(_chapterCached).length;

    List<int> buildFilteredIndexes() {
      if (keyword.isEmpty) {
        return List<int>.generate(_chapters.length, (index) => index);
      }

      final normalizedKeyword = keyword.toLowerCase();
      return List<int>.generate(_chapters.length, (index) => index)
          .where(
            (index) => _chapters[index].title.toLowerCase().contains(
              normalizedKeyword,
            ),
          )
          .toList(growable: false);
    }

    try {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, panelSetState) {
              final filteredIndexes = buildFilteredIndexes();

              return SafeArea(
                top: false,
                child: CupertinoPopupSurface(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.78,
                    child: Column(
                      children: [
                        Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              const SizedBox(width: 32),
                              Expanded(
                                child: Text(
                                  '目录 (${_chapters.length} 章)',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              CupertinoButton(
                                minimumSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Icon(CupertinoIcons.clear_thick),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: CupertinoColors.separator),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '已缓存 $cachedCount 章 · 当前第 ${_selectedIndex + 1} 章',
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CupertinoSearchTextField(
                                controller: searchController,
                                placeholder: '搜索章节标题',
                                onChanged: (value) {
                                  panelSetState(() {
                                    keyword = value.trim();
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: CupertinoButton.filled(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      onPressed: _busy
                                          ? null
                                          : () => _jumpFromCatalog(context, 0),
                                      child: const Text('首章'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CupertinoButton.filled(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      onPressed: _busy
                                          ? null
                                          : () => _jumpFromCatalog(
                                              context,
                                              _selectedIndex,
                                            ),
                                      child: const Text('当前'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CupertinoButton.filled(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      onPressed: _busy
                                          ? null
                                          : () => _jumpFromCatalog(
                                              context,
                                              _chapters.length - 1,
                                            ),
                                      child: const Text('末章'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: CupertinoColors.separator),
                        if (filteredIndexes.isEmpty)
                          const Expanded(
                            child: Center(
                              child: Text(
                                '没有匹配章节',
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              controller: listController,
                              itemCount: filteredIndexes.length,
                              separatorBuilder: (_, _) => Container(
                                height: 1,
                                color: CupertinoColors.separator,
                              ),
                              itemBuilder: (context, listIndex) {
                                final index = filteredIndexes[listIndex];
                                final chapter = _chapters[index];
                                final selected = index == _selectedIndex;
                                final cached = _chapterCached(chapter);

                                return CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  onPressed: _busy
                                      ? null
                                      : () => _jumpFromCatalog(context, index),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '${index + 1}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          chapter.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: selected
                                                ? CupertinoColors.activeBlue
                                                : CupertinoColors.label,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      if (chapter.isVolume)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Text(
                                            '卷',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        cached ? '已缓存' : '未缓存',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: cached
                                              ? CupertinoColors.activeGreen
                                              : CupertinoColors.systemGrey,
                                        ),
                                      ),
                                      if (selected)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 6),
                                          child: Icon(
                                            CupertinoIcons
                                                .check_mark_circled_solid,
                                            color: CupertinoColors.activeBlue,
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      searchController.dispose();
      listController.dispose();
    }
  }

  Future<void> _openLayoutSettings() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, panelSetState) {
            return SafeArea(
              top: false,
              child: CupertinoPopupSurface(
                child: SizedBox(
                  height: 320,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '界面',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoSlidingSegmentedControl<ReaderThemePreset>(
                          groupValue: _themePreset,
                          children: const {
                            ReaderThemePreset.day: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('白天'),
                            ),
                            ReaderThemePreset.sepia: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('护眼'),
                            ),
                            ReaderThemePreset.night: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('夜间'),
                            ),
                          },
                          onValueChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _themePreset = value;
                            });
                            _saveLayoutPreferences();
                            panelSetState(() {});
                          },
                        ),
                        const SizedBox(height: 10),
                        CupertinoSlidingSegmentedControl<ReaderPageMode>(
                          groupValue: _pageMode,
                          children: const {
                            ReaderPageMode.scroll: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('滚动'),
                            ),
                            ReaderPageMode.cover: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('覆盖'),
                            ),
                          },
                          onValueChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _pageMode = value;
                              _message = _pageMode == ReaderPageMode.scroll
                                  ? '已切换滚动模式'
                                  : '已切换覆盖模式';
                            });
                            _saveLayoutPreferences();
                            _rebuildCoverPages();
                            panelSetState(() {});
                          },
                        ),
                        const SizedBox(height: 20),
                        Text('字号 ${_fontSize.toStringAsFixed(0)}'),
                        CupertinoSlider(
                          value: _fontSize,
                          min: 14,
                          max: 30,
                          divisions: 16,
                          onChanged: (value) {
                            setState(() {
                              _fontSize = value;
                            });
                            _saveLayoutPreferences();
                            _rebuildCoverPages();
                            panelSetState(() {});
                          },
                        ),
                        const SizedBox(height: 12),
                        Text('行距 ${_lineHeight.toStringAsFixed(1)}'),
                        CupertinoSlider(
                          value: _lineHeight,
                          min: 1.2,
                          max: 2.6,
                          divisions: 14,
                          onChanged: (value) {
                            setState(() {
                              _lineHeight = value;
                            });
                            _saveLayoutPreferences();
                            _rebuildCoverPages();
                            panelSetState(() {});
                          },
                        ),
                        const Spacer(),
                        CupertinoButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('完成'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openReaderSettings() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('阅读设置'),
          message: const Text('以下选项对当前书籍即时生效'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _tapToTurnPage = !_tapToTurnPage;
                  _message = _tapToTurnPage ? '点击翻页已开启' : '点击翻页已关闭';
                });
                _saveInteractionPreferences();
              },
              child: Text(_tapToTurnPage ? '关闭点击翻页' : '开启点击翻页'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showBrightnessPanel = !_showBrightnessPanel;
                  _message = _showBrightnessPanel ? '已显示亮度控件' : '已隐藏亮度控件';
                });
                _saveInteractionPreferences();
              },
              child: Text(_showBrightnessPanel ? '隐藏亮度控件' : '显示亮度控件'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _followSystemBrightness = !_followSystemBrightness;
                  _message = _followSystemBrightness ? '亮度改为跟随系统' : '亮度改为手动控制';
                });
                _saveInteractionPreferences();
              },
              child: Text(_followSystemBrightness ? '改为手动亮度' : '改为系统亮度'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _togglePageMode();
              },
              child: Text(
                _pageMode == ReaderPageMode.scroll ? '切换为覆盖模式' : '切换为滚动模式',
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        );
      },
    );
  }

  _ReaderPalette _paletteForPreset(ReaderThemePreset preset) {
    switch (preset) {
      case ReaderThemePreset.day:
        return const _ReaderPalette(
          background: Color(0xFFEEEEEE),
          text: Color(0xFF3E3D3B),
          menuBackground: Color(0xFFE0E0E0),
          menuText: Color(0xFF212121),
          mutedText: Color(0xFF666666),
        );
      case ReaderThemePreset.sepia:
        return const _ReaderPalette(
          background: Color(0xFFF4ECD8),
          text: Color(0xFF5C4B33),
          menuBackground: Color(0xFFE7DCC2),
          menuText: Color(0xFF4A3C2A),
          mutedText: Color(0xFF7A6A54),
        );
      case ReaderThemePreset.night:
        return const _ReaderPalette(
          background: Color(0xFF111317),
          text: Color(0xFFADADAD),
          menuBackground: Color(0xFF1A1E24),
          menuText: Color(0xFFE7E7E7),
          mutedText: Color(0xFF808080),
        );
    }
  }

  double _effectiveBrightness(BuildContext context) {
    if (_followSystemBrightness) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? 0.72
          : 1;
    }
    return _brightness;
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color menuBackground,
    required Color menuText,
    required VoidCallback onPressed,
    bool active = false,
  }) {
    final buttonBackground = active
        ? CupertinoColors.activeBlue.withValues(alpha: 0.2)
        : menuBackground.withValues(alpha: 0.88);

    return Expanded(
      child: Column(
        children: [
          CupertinoButton(
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(12),
            onPressed: onPressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: buttonBackground,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  icon,
                  size: 20,
                  color: active ? CupertinoColors.activeBlue : menuText,
                ),
              ),
            ),
          ),
          Text(label, style: TextStyle(color: menuText, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    final palette = _paletteForPreset(_themePreset);
    final safeTop = MediaQuery.paddingOf(context).top;
    final brightnessShade = (1 - _effectiveBrightness(context)).clamp(0.0, 0.6);
    final chapterTitle = _chapters.isNotEmpty
        ? _chapters[_selectedIndex].title
        : '未选择章节';
    final chapterProgress = _chapters.isEmpty
        ? '0 / 0'
        : '${_selectedIndex + 1} / ${_chapters.length}';
    final pageProgress =
        _pageMode == ReaderPageMode.cover && _coverPages.isNotEmpty
        ? ' · 第 ${_coverPageIndex + 1}/${_coverPages.length} 页'
        : '';

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          color: palette.background,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => _handleReadTap(details, constraints),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_pageMode == ReaderPageMode.scroll)
                      SingleChildScrollView(
                        controller: _contentScrollController,
                        padding: EdgeInsets.fromLTRB(20, safeTop + 18, 20, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_currentBookName != null)
                              Text(
                                _currentBookName!,
                                style: TextStyle(
                                  color: palette.mutedText,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              chapterTitle,
                              style: TextStyle(
                                color: palette.text,
                                fontSize: _fontSize + 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 22),
                            _buildContentText(
                              content: _effectiveContent(),
                              style: TextStyle(
                                color: palette.text,
                                fontSize: _fontSize,
                                height: _lineHeight,
                                letterSpacing: 0.2,
                              ),
                              highlightColor: CupertinoColors.systemYellow
                                  .withValues(alpha: 0.40),
                              focusedHighlightColor: CupertinoColors
                                  .activeOrange
                                  .withValues(alpha: 0.54),
                            ),
                            const SizedBox(height: 28),
                            Center(
                              child: Text(
                                '$chapterProgress$pageProgress',
                                style: TextStyle(
                                  color: palette.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, safeTop + 18, 20, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_currentBookName != null)
                              Text(
                                _currentBookName!,
                                style: TextStyle(
                                  color: palette.mutedText,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              chapterTitle,
                              style: TextStyle(
                                color: palette.text,
                                fontSize: _fontSize + 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: PageView.builder(
                                controller: _coverPageController,
                                itemCount: _coverPages.isEmpty
                                    ? 1
                                    : _coverPages.length,
                                onPageChanged: (value) {
                                  setState(() {
                                    _coverPageIndex = value;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final pageContent = _coverPages.isEmpty
                                      ? '暂无正文'
                                      : _coverPages[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 4,
                                    ),
                                    child: _buildContentText(
                                      content: pageContent,
                                      style: TextStyle(
                                        color: palette.text,
                                        fontSize: _fontSize,
                                        height: _lineHeight,
                                        letterSpacing: 0.2,
                                      ),
                                      highlightColor: CupertinoColors
                                          .systemYellow
                                          .withValues(alpha: 0.40),
                                      focusedHighlightColor: CupertinoColors
                                          .activeOrange
                                          .withValues(alpha: 0.54),
                                      useFocusedOffset: false,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                '$chapterProgress$pageProgress',
                                style: TextStyle(
                                  color: palette.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        color: CupertinoColors.black.withValues(
                          alpha: brightnessShade,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_busy)
          const Positioned(
            top: 16,
            right: 16,
            child: CupertinoActivityIndicator(radius: 12),
          ),
        if (_message != null)
          Positioned(
            top: safeTop + 10,
            left: 12,
            right: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: shadTheme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  _message!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: shadTheme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          top: _menuVisible ? 0 : -92,
          left: 0,
          right: 0,
          child: Container(
            color: palette.menuBackground.withValues(alpha: 0.96),
            padding: EdgeInsets.only(top: safeTop),
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () => context.go('/bookshelf'),
                    child: Icon(CupertinoIcons.back, color: palette.menuText),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentBookName ?? '阅读',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.menuText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          chapterTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: _busy ? null : _fetchChapters,
                    child: Icon(
                      CupertinoIcons.refresh,
                      color: palette.menuText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          left: _menuVisible && _showBrightnessPanel ? 8 : -72,
          top: safeTop + 76,
          bottom: 230,
          child: Container(
            width: 56,
            decoration: BoxDecoration(
              color: palette.menuBackground.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                CupertinoButton(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(24, 24),
                  onPressed: () {
                    setState(() {
                      _followSystemBrightness = !_followSystemBrightness;
                      _message = _followSystemBrightness
                          ? '亮度跟随系统'
                          : '亮度改为手动调节';
                    });
                    _saveInteractionPreferences();
                  },
                  child: Icon(
                    _followSystemBrightness
                        ? CupertinoIcons.brightness_solid
                        : CupertinoIcons.brightness,
                    size: 18,
                    color: palette.menuText,
                  ),
                ),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: CupertinoSlider(
                      value: _brightness,
                      min: 0.25,
                      max: 1,
                      divisions: 15,
                      onChanged: _followSystemBrightness
                          ? null
                          : (value) {
                              setState(() {
                                _brightness = value;
                              });
                              _saveInteractionPreferences();
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          left: 0,
          right: 0,
          bottom: _menuVisible ? 0 : -250,
          child: Container(
            color: palette.menuBackground.withValues(alpha: 0.96),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildQuickAction(
                      icon: CupertinoIcons.search,
                      label: '搜索',
                      menuBackground: palette.menuBackground,
                      menuText: palette.menuText,
                      onPressed: _openLocalSearchPanel,
                    ),
                    _buildQuickAction(
                      icon: CupertinoIcons.play_arrow,
                      label: '自动',
                      menuBackground: palette.menuBackground,
                      menuText: palette.menuText,
                      onPressed: _toggleAutoPaging,
                      active: _autoPaging,
                    ),
                    _buildQuickAction(
                      icon: CupertinoIcons.wand_stars,
                      label: '净化',
                      menuBackground: palette.menuBackground,
                      menuText: palette.menuText,
                      onPressed: _openReplaceRulePanel,
                    ),
                    _buildQuickAction(
                      icon: CupertinoIcons.moon,
                      label: '夜间',
                      menuBackground: palette.menuBackground,
                      menuText: palette.menuText,
                      onPressed: _toggleNightTheme,
                      active: _themePreset == ReaderThemePreset.night,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(24, 24),
                      onPressed: (_busy || _selectedIndex <= 0)
                          ? null
                          : _goPreviousChapter,
                      child: Text(
                        '上一章',
                        style: TextStyle(color: palette.menuText),
                      ),
                    ),
                    Expanded(
                      child: CupertinoSlider(
                        value: _chapters.isEmpty
                            ? 0
                            : _selectedIndex.toDouble(),
                        min: 0,
                        max: _chapters.isEmpty
                            ? 1
                            : (_chapters.length - 1).toDouble(),
                        onChanged: (_busy || _chapters.length <= 1)
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedIndex = value.round();
                                });
                              },
                        onChangeEnd: (_busy || _chapters.length <= 1)
                            ? null
                            : (value) {
                                _loadChapterContent(value.round());
                              },
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(24, 24),
                      onPressed:
                          (_busy ||
                              _chapters.isEmpty ||
                              _selectedIndex >= _chapters.length - 1)
                          ? null
                          : _goNextChapter,
                      child: Text(
                        '下一章',
                        style: TextStyle(color: palette.menuText),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        minimumSize: const Size(30, 30),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        onPressed: _openChapterCatalog,
                        child: Text(
                          '目录',
                          style: TextStyle(color: palette.menuText),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton(
                        minimumSize: const Size(30, 30),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        onPressed: _openBookmarkHistoryPanel,
                        child: Text(
                          '书签',
                          style: TextStyle(color: palette.menuText),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton(
                        minimumSize: const Size(30, 30),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        onPressed: _openLayoutSettings,
                        child: Text(
                          '界面',
                          style: TextStyle(color: palette.menuText),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton(
                        minimumSize: const Size(30, 30),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        onPressed: _openReaderSettings,
                        child: Text(
                          '设置',
                          style: TextStyle(color: palette.menuText),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
