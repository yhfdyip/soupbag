import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/core/bootstrap/app_services.dart';
import 'package:soupbag/features/bookshelf/data/local/bookshelf_local_repository.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/discovery/domain/models/search_result_entity.dart';
import 'package:soupbag/features/discovery/domain/services/legado_search_service.dart';
import 'package:soupbag/features/source_management/data/local/book_source_local_repository.dart';
import 'package:soupbag/features/source_management/data/local/source_score_local_repository.dart';

enum _OriginManageAction { toTop, toBottom, disable, delete }

class _OriginSortSnapshot {
  const _OriginSortSnapshot({
    required this.origins,
    required this.bookScores,
    required this.sourceScores,
  });

  final List<SearchResultOriginEntity> origins;
  final Map<String, int> bookScores;
  final Map<String, int> sourceScores;
}

class ExploreResultsPage extends StatefulWidget {
  const ExploreResultsPage({
    super.key,
    required this.title,
    this.sourceUrl,
    this.sourceName,
    this.exploreUrl,
  });

  final String title;
  final String? sourceUrl;
  final String? sourceName;
  final String? exploreUrl;

  @override
  State<ExploreResultsPage> createState() => _ExploreResultsPageState();
}

class _ExploreResultsPageState extends State<ExploreResultsPage> {
  late final LegadoSearchService _searchService;
  late final BookSourceLocalRepository _sourceRepository;
  late final SourceScoreLocalRepository _sourceScoreRepository;
  late final BookshelfLocalRepository _bookshelfRepository;
  late final ScrollController _scrollController;

  StreamSubscription<List<BookEntity>>? _bookshelfSubscription;

  List<SearchResultEntity> _results = const [];
  final Set<String> _seenIdentities = <String>{};
  final Set<String> _bookshelfIdentities = <String>{};
  final ValueNotifier<int> _bookshelfVersion = ValueNotifier<int>(0);

  bool _loadingInitial = false;
  bool _loadingMore = false;
  bool _reloading = false;
  bool _loadingOrigins = false;
  bool _hasMore = true;
  int _nextPage = 1;

  String? _message;
  String? _errorMessage;

  String _scoreKey({
    required String sourceUrl,
    required String name,
    required String author,
  }) {
    return '$sourceUrl\u0000$name\u0000$author';
  }

  String _sourceOrderKey(String sourceUrl) {
    return sourceUrl;
  }

  Future<_OriginSortSnapshot> _buildSortedOriginSnapshot(
    SearchResultEntity result,
  ) async {
    final origins = _resolveOrigins(result);
    if (origins.length <= 1) {
      return _OriginSortSnapshot(
        origins: origins,
        bookScores: const <String, int>{},
        sourceScores: const <String, int>{},
      );
    }

    final author = (result.author ?? '').trim();
    final name = result.name.trim();
    final scores = <String, int>{};
    final sourceScores = <String, int>{};

    for (final origin in origins) {
      final sourceUrl = origin.sourceUrl.trim();
      if (sourceUrl.isEmpty) {
        continue;
      }

      final score = await _sourceScoreRepository.getBookScore(
        sourceUrl: sourceUrl,
        name: name,
        author: author,
      );
      scores[_scoreKey(sourceUrl: sourceUrl, name: name, author: author)] =
          score;

      final sourceScore = await _sourceScoreRepository.getSourceScore(
        sourceUrl,
      );
      sourceScores[_sourceOrderKey(sourceUrl)] = sourceScore;
    }

    final orderMap = <String, int>{};
    final bookSources = await _sourceRepository.getBookSources();
    for (final source in bookSources) {
      orderMap[source.bookSourceUrl] = source.customOrder;
    }

    final sortedOrigins = [...origins]
      ..sort((left, right) {
        final leftSourceUrl = left.sourceUrl.trim();
        final rightSourceUrl = right.sourceUrl.trim();

        final leftScore =
            scores[_scoreKey(
              sourceUrl: leftSourceUrl,
              name: name,
              author: author,
            )] ??
            0;
        final rightScore =
            scores[_scoreKey(
              sourceUrl: rightSourceUrl,
              name: name,
              author: author,
            )] ??
            0;
        final scoreCompare = rightScore.compareTo(leftScore);
        if (scoreCompare != 0) {
          return scoreCompare;
        }

        final leftSourceScore =
            sourceScores[_sourceOrderKey(leftSourceUrl)] ?? 0;
        final rightSourceScore =
            sourceScores[_sourceOrderKey(rightSourceUrl)] ?? 0;
        final sourceScoreCompare = rightSourceScore.compareTo(leftSourceScore);
        if (sourceScoreCompare != 0) {
          return sourceScoreCompare;
        }

        final leftOrder = orderMap[leftSourceUrl] ?? 0;
        final rightOrder = orderMap[rightSourceUrl] ?? 0;
        final orderCompare = leftOrder.compareTo(rightOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }

        return left.sourceName.compareTo(right.sourceName);
      });

    return _OriginSortSnapshot(
      origins: sortedOrigins,
      bookScores: scores,
      sourceScores: sourceScores,
    );
  }

  @override
  void initState() {
    super.initState();
    final services = AppServices.instance;
    _sourceRepository = BookSourceLocalRepository(services.database);
    _sourceScoreRepository = SourceScoreLocalRepository(services.database);
    _searchService = LegadoSearchService(
      httpGateway: services.legadoHttpGateway,
      sourceRepository: _sourceRepository,
    );
    _bookshelfRepository = BookshelfLocalRepository(services.database);

    _bookshelfSubscription = _bookshelfRepository.watchBookshelf().listen((
      books,
    ) {
      final identities = <String>{};
      for (final book in books) {
        final name = book.name.trim();
        final author = book.author.trim();
        final bookUrl = book.bookUrl.trim();

        if (name.isNotEmpty) {
          identities.add(name);
          if (author.isNotEmpty) {
            identities.add('$name-$author');
          }
        }
        if (bookUrl.isNotEmpty) {
          identities.add(bookUrl);
        }
      }

      if (!mounted) {
        return;
      }
      final same =
          identities.length == _bookshelfIdentities.length &&
          _bookshelfIdentities.containsAll(identities);
      if (same) {
        return;
      }

      _bookshelfIdentities
        ..clear()
        ..addAll(identities);
      _bookshelfVersion.value = _bookshelfVersion.value + 1;
    });

    _scrollController = ScrollController()..addListener(_onScroll);
    unawaited(_loadNextPage(isInitial: true));
  }

  @override
  void dispose() {
    _bookshelfSubscription?.cancel();
    _bookshelfVersion.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter > 240) {
      return;
    }

    unawaited(_loadNextPage());
  }

  Future<void> _loadNextPage({bool isInitial = false}) async {
    if (_loadingInitial ||
        _loadingMore ||
        _reloading ||
        (!_hasMore && !isInitial)) {
      return;
    }

    setState(() {
      if (isInitial) {
        _loadingInitial = true;
        _errorMessage = null;
        _message = '正在加载发现列表...';
        _hasMore = true;
        _nextPage = 1;
        _seenIdentities.clear();
        _results = const [];
      } else {
        _loadingMore = true;
        _errorMessage = null;
      }
    });

    try {
      final fetched = await _searchService.explore(
        page: _nextPage,
        sourceUrl: widget.sourceUrl,
        exploreUrl: widget.exploreUrl,
      );

      final appended = <SearchResultEntity>[];
      for (final item in fetched) {
        final identity = '${item.sourceUrl}|${item.bookUrl}|${item.name}';
        if (_seenIdentities.add(identity)) {
          appended.add(item);
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        if (isInitial) {
          _results = appended;
        } else {
          _results = [..._results, ...appended];
        }

        if (fetched.isEmpty || appended.isEmpty) {
          _hasMore = false;
        } else {
          _nextPage += 1;
        }

        _message = _results.isEmpty ? '暂无发现结果' : '已加载 ${_results.length} 条';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = isInitial ? '加载失败，请稍后重试' : '加载更多失败，请点击重试';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingInitial = false;
          _loadingMore = false;
        });
      }
    }
  }

  bool _isInBookshelf(SearchResultEntity result) {
    final name = result.name.trim();
    final author = (result.author ?? '').trim();
    final bookUrl = (result.bookUrl ?? '').trim();

    final key = author.isNotEmpty ? '$name-$author' : name;
    if (key.isNotEmpty && _bookshelfIdentities.contains(key)) {
      return true;
    }
    if (name.isNotEmpty && _bookshelfIdentities.contains(name)) {
      return true;
    }
    if (bookUrl.isNotEmpty && _bookshelfIdentities.contains(bookUrl)) {
      return true;
    }
    return false;
  }

  void _openBookDetail(
    SearchResultEntity result, {
    SearchResultOriginEntity? origin,
  }) {
    final selectedOrigin = origin;

    context.push(
      '/discovery/book-detail',
      extra: {
        'sourceUrl': selectedOrigin?.sourceUrl ?? result.sourceUrl,
        'sourceName': selectedOrigin?.sourceName ?? result.sourceName,
        'name': result.name,
        'author': result.author,
        'bookUrl': selectedOrigin?.bookUrl ?? result.bookUrl,
        'coverUrl': selectedOrigin?.coverUrl ?? result.coverUrl,
        'intro': selectedOrigin?.intro ?? result.intro,
      },
    );
  }

  List<SearchResultOriginEntity> _resolveOrigins(SearchResultEntity result) {
    if (result.origins.isNotEmpty) {
      return result.origins;
    }

    return [
      SearchResultOriginEntity(
        sourceUrl: result.sourceUrl,
        sourceName: result.sourceName,
        bookUrl: result.bookUrl,
        coverUrl: result.coverUrl,
        intro: result.intro,
        kind: result.kind,
        wordCount: result.wordCount,
        latestChapter: result.latestChapter,
      ),
    ];
  }

  bool _isCurrentOrigin(
    SearchResultEntity result,
    SearchResultOriginEntity origin,
  ) {
    final currentSource = result.sourceUrl.trim();
    final currentBookUrl = (result.bookUrl ?? '').trim();
    final originSource = origin.sourceUrl.trim();
    final originBookUrl = (origin.bookUrl ?? '').trim();

    if (currentSource.isEmpty ||
        originSource.isEmpty ||
        currentSource != originSource) {
      return false;
    }

    if (currentBookUrl.isEmpty || originBookUrl.isEmpty) {
      return true;
    }

    return currentBookUrl == originBookUrl;
  }

  String _buildOriginSummary(SearchResultOriginEntity origin) {
    final parts = <String>[];

    final latest = (origin.latestChapter ?? '').trim();
    if (latest.isNotEmpty) {
      parts.add('最新：$latest');
    }

    final wordCount = (origin.wordCount ?? '').trim();
    if (wordCount.isNotEmpty) {
      parts.add('字数：$wordCount');
    }

    return parts.join(' · ');
  }

  List<SearchResultOriginEntity> _filterOrigins({
    required List<SearchResultOriginEntity> origins,
    required String keyword,
  }) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) {
      return origins;
    }

    return origins
        .where((origin) {
          final sourceName = origin.sourceName.toLowerCase();
          final sourceUrl = origin.sourceUrl.toLowerCase();
          final latestChapter = (origin.latestChapter ?? '').toLowerCase();
          final wordCount = (origin.wordCount ?? '').toLowerCase();

          return sourceName.contains(normalized) ||
              sourceUrl.contains(normalized) ||
              latestChapter.contains(normalized) ||
              wordCount.contains(normalized);
        })
        .toList(growable: false);
  }

  Future<void> _showTipDialog(String message) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('提示'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    String confirmText = '确认',
    bool destructive = false,
  }) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: destructive,
              isDefaultAction: !destructive,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  void _showResultMessage(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _message = message;
    });
  }

  Future<void> _reloadFromFirstPage({
    String loadingMessage = '正在刷新发现列表...',
  }) async {
    if (_reloading || _loadingInitial || _loadingMore) {
      return;
    }

    setState(() {
      _reloading = true;
      _errorMessage = null;
      _message = loadingMessage;
      _hasMore = true;
      _nextPage = 1;
      _seenIdentities.clear();
      _results = const [];
    });

    try {
      final fetched = await _searchService.explore(
        page: 1,
        sourceUrl: widget.sourceUrl,
        exploreUrl: widget.exploreUrl,
      );

      final appended = <SearchResultEntity>[];
      for (final item in fetched) {
        final identity = '${item.sourceUrl}|${item.bookUrl}|${item.name}';
        if (_seenIdentities.add(identity)) {
          appended.add(item);
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _results = appended;
        if (fetched.isEmpty || appended.isEmpty) {
          _hasMore = false;
        } else {
          _nextPage = 2;
        }
        _message = _results.isEmpty ? '暂无发现结果' : '已加载 ${_results.length} 条';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _results.isEmpty ? '加载失败，请稍后重试' : '刷新失败，请稍后重试';
      });
    } finally {
      if (mounted) {
        setState(() {
          _reloading = false;
        });
      }
    }
  }

  Future<void> _applyOriginManageAction({
    required SearchResultOriginEntity origin,
    required _OriginManageAction action,
  }) async {
    if (_reloading || _loadingInitial || _loadingMore) {
      return;
    }

    final sourceUrl = origin.sourceUrl.trim();
    if (sourceUrl.isEmpty) {
      await _showTipDialog('当前来源缺少 sourceUrl，无法执行操作');
      return;
    }

    final sourceName = origin.sourceName.trim().isEmpty
        ? sourceUrl
        : origin.sourceName.trim();

    switch (action) {
      case _OriginManageAction.toTop:
        await _sourceRepository.moveBookSourceToTop(sourceUrl);
        await _reloadFromFirstPage(loadingMessage: '已置顶来源，正在刷新列表...');
        _showResultMessage('已置顶：$sourceName');
        return;
      case _OriginManageAction.toBottom:
        await _sourceRepository.moveBookSourceToBottom(sourceUrl);
        await _reloadFromFirstPage(loadingMessage: '已置底来源，正在刷新列表...');
        _showResultMessage('已置底：$sourceName');
        return;
      case _OriginManageAction.disable:
        final confirmed = await _confirmDialog(
          title: '禁用来源',
          message: '确认禁用“$sourceName”？禁用后将不参与搜索与发现。',
          confirmText: '禁用',
          destructive: true,
        );
        if (!confirmed) {
          return;
        }
        await _sourceRepository.setBookSourceEnabled(sourceUrl, false);
        await _sourceScoreRepository.clearSourceScores(sourceUrl);
        await _reloadFromFirstPage(loadingMessage: '来源已禁用，正在刷新列表...');
        _showResultMessage('已禁用：$sourceName');
        return;
      case _OriginManageAction.delete:
        final confirmed = await _confirmDialog(
          title: '删除来源',
          message: '确认删除“$sourceName”？该操作不可撤销。',
          confirmText: '删除',
          destructive: true,
        );
        if (!confirmed) {
          return;
        }
        await _sourceRepository.removeBookSource(sourceUrl);
        await _sourceScoreRepository.clearSourceScores(sourceUrl);
        await _reloadFromFirstPage(loadingMessage: '来源已删除，正在刷新列表...');
        _showResultMessage('已删除：$sourceName');
        return;
    }
  }

  Future<void> _showOriginManageSheet(SearchResultOriginEntity origin) async {
    final sourceName = origin.sourceName.trim().isEmpty
        ? origin.sourceUrl
        : origin.sourceName.trim();

    final action = await showCupertinoModalPopup<_OriginManageAction>(
      context: context,
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: Text(sourceName),
          message: const Text('来源管理'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(_OriginManageAction.toTop),
              child: const Text('置顶书源'),
            ),
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(_OriginManageAction.toBottom),
              child: const Text('置底书源'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () =>
                  Navigator.of(sheetContext).pop(_OriginManageAction.disable),
              child: const Text('禁用书源'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () =>
                  Navigator.of(sheetContext).pop(_OriginManageAction.delete),
              child: const Text('删除书源'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('取消'),
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    try {
      await _applyOriginManageAction(origin: origin, action: action);
    } catch (_) {
      if (!mounted) {
        return;
      }
      await _showTipDialog('来源管理操作失败，请稍后重试');
    }
  }

  Future<void> _selectOriginAndOpenDetail(SearchResultEntity result) async {
    if (_loadingOrigins) {
      return;
    }

    setState(() {
      _loadingOrigins = true;
    });

    _OriginSortSnapshot snapshot;
    try {
      snapshot = await _buildSortedOriginSnapshot(result);
    } finally {
      if (mounted) {
        setState(() {
          _loadingOrigins = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    var origins = snapshot.origins;

    if (origins.length <= 1) {
      _openBookDetail(result);
      return;
    }

    var filteredOrigins = origins;
    var keyword = '';
    var scoreMap = snapshot.bookScores;
    var sourceScoreMap = snapshot.sourceScores;

    final selected = await showCupertinoModalPopup<SearchResultOriginEntity>(
      context: context,
      builder: (popupContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final popupHeight = MediaQuery.of(context).size.height * 0.72;
            final borderColor = CupertinoColors.separator.resolveFrom(context);
            final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(
              context,
            );

            return SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: popupHeight,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground.resolveFrom(
                      context,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey3.resolveFrom(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${result.name} · 选择书源',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: const Size(52, 28),
                              onPressed: () => Navigator.of(popupContext).pop(),
                              child: const Text('关闭'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: CupertinoSearchTextField(
                          placeholder: '搜索来源 / 最新章节 / 字数',
                          onChanged: (value) {
                            setModalState(() {
                              keyword = value;
                              filteredOrigins = _filterOrigins(
                                origins: origins,
                                keyword: value,
                              );
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              '排序：书籍评分 > 书源评分 > 书源顺序',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filteredOrigins.isEmpty
                            ? Center(
                                child: Text(
                                  '没有匹配的书源',
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 10),
                                itemCount: filteredOrigins.length,
                                separatorBuilder:
                                    (separatorContext, separatorIndex) =>
                                        Container(
                                          height: 1,
                                          color: borderColor,
                                        ),
                                itemBuilder: (context, index) {
                                  final origin = filteredOrigins[index];
                                  final isCurrent = _isCurrentOrigin(
                                    result,
                                    origin,
                                  );
                                  final summary = _buildOriginSummary(origin);
                                  final score =
                                      scoreMap[_scoreKey(
                                        sourceUrl: origin.sourceUrl.trim(),
                                        name: result.name.trim(),
                                        author: (result.author ?? '').trim(),
                                      )] ??
                                      0;
                                  final sourceScore =
                                      sourceScoreMap[_sourceOrderKey(
                                        origin.sourceUrl.trim(),
                                      )] ??
                                      0;

                                  Future<void> updateScore(int next) async {
                                    final sourceUrl = origin.sourceUrl.trim();
                                    if (sourceUrl.isEmpty) {
                                      return;
                                    }

                                    final name = result.name.trim();
                                    final author = (result.author ?? '').trim();

                                    await _sourceScoreRepository.setBookScore(
                                      sourceUrl: sourceUrl,
                                      name: name,
                                      author: author,
                                      score: next,
                                    );

                                    final refreshedSnapshot =
                                        await _buildSortedOriginSnapshot(
                                          result,
                                        );
                                    final refreshedFiltered = _filterOrigins(
                                      origins: refreshedSnapshot.origins,
                                      keyword: keyword,
                                    );

                                    setModalState(() {
                                      origins = refreshedSnapshot.origins;
                                      filteredOrigins = refreshedFiltered;
                                      scoreMap = refreshedSnapshot.bookScores;
                                      sourceScoreMap =
                                          refreshedSnapshot.sourceScores;
                                    });
                                  }

                                  final activeGoodColor = CupertinoColors
                                      .systemRed
                                      .resolveFrom(context);
                                  final inactiveGoodColor = CupertinoColors
                                      .systemRed
                                      .resolveFrom(context)
                                      .withValues(alpha: 0.35);
                                  final activeBadColor = CupertinoColors
                                      .systemBlue
                                      .resolveFrom(context);
                                  final inactiveBadColor = CupertinoColors
                                      .systemBlue
                                      .resolveFrom(context)
                                      .withValues(alpha: 0.35);

                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onLongPress: () async {
                                      Navigator.of(popupContext).pop();
                                      await _showOriginManageSheet(origin);
                                    },
                                    onTap: () =>
                                        Navigator.of(popupContext).pop(origin),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        8,
                                        16,
                                        8,
                                      ),
                                      color: isCurrent
                                          ? CupertinoColors.systemGrey6
                                                .resolveFrom(context)
                                          : null,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            child: Column(
                                              children: [
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(
                                                    30,
                                                    24,
                                                  ),
                                                  onPressed: () => updateScore(
                                                    score == 1 ? 0 : 1,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/ic_praise.svg',
                                                    width: 14,
                                                    height: 14,
                                                    colorFilter: ColorFilter.mode(
                                                      score == 1
                                                          ? activeGoodColor
                                                          : inactiveGoodColor,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                                ),
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(
                                                    30,
                                                    24,
                                                  ),
                                                  onPressed: () => updateScore(
                                                    score == -1 ? 0 : -1,
                                                  ),
                                                  child: Transform(
                                                    alignment: Alignment.center,
                                                    transform:
                                                        Matrix4.identity()
                                                          ..rotateX(math.pi),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/ic_praise.svg',
                                                      width: 14,
                                                      height: 14,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                            score == -1
                                                                ? activeBadColor
                                                                : inactiveBadColor,
                                                            BlendMode.srcIn,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        origin.sourceName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: Center(
                                                        child: isCurrent
                                                            ? SvgPicture.asset(
                                                                'assets/icons/ic_check.svg',
                                                                width: 24,
                                                                height: 24,
                                                                colorFilter: ColorFilter.mode(
                                                                  CupertinoColors
                                                                      .label
                                                                      .resolveFrom(
                                                                        context,
                                                                      ),
                                                                  BlendMode
                                                                      .srcIn,
                                                                ),
                                                              )
                                                            : const SizedBox.shrink(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '评分：$score · 书源评分：$sourceScore',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: secondaryColor,
                                                  ),
                                                ),
                                                if (summary.isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    summary,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: secondaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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

    if (!mounted || selected == null) {
      return;
    }
    _openBookDetail(result, origin: selected);
  }

  Widget _buildResultCard(SearchResultEntity result) {
    final kinds = _parseKinds(result.kind);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openBookDetail(result),
        child: ShadCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCover(result.coverUrl, result.name),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: _bookshelfVersion,
                          builder: (context, version, child) {
                            if (!_isInBookshelf(result)) {
                              return const SizedBox.shrink();
                            }
                            return Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGreen
                                        .resolveFrom(context),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                            );
                          },
                        ),
                        Expanded(
                          child: Text(
                            result.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (result.originCount > 1) ...[
                          const SizedBox(width: 6),
                          _buildOriginCountBadge(
                            count: result.originCount,
                            onTap: () => _selectOriginAndOpenDetail(result),
                          ),
                        ],
                        if ((result.wordCount ?? '').trim().isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            result.wordCount!,
                            style: TextStyle(
                              fontSize: 11,
                              color: CupertinoColors.secondaryLabel.resolveFrom(
                                context,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '作者：${result.author ?? '未知作者'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                    if (kinds.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: kinds
                            .map(
                              (kind) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: CupertinoColors.systemGrey4
                                        .resolveFrom(context),
                                  ),
                                ),
                                child: Text(
                                  kind,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                    if ((result.latestChapter ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '最新：${result.latestChapter!}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    if ((result.intro ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.intro!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 6),
                    ValueListenableBuilder<int>(
                      valueListenable: _bookshelfVersion,
                      builder: (context, version, child) {
                        final inBookshelf = _isInBookshelf(result);
                        return Text(
                          inBookshelf ? '已在书架 · 点击查看详情' : '点击查看详情',
                          style: TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.secondaryLabel.resolveFrom(
                              context,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginCountBadge({
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _loadingOrigins ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$count源',
          style: TextStyle(
            fontSize: 11,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCover(String? coverUrl, String fallbackTitle) {
    final normalizedUrl = (coverUrl ?? '').trim();

    Widget placeholder() {
      return Container(
        width: 80,
        height: 110,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          fallbackTitle.isEmpty ? '封面' : fallbackTitle.substring(0, 1),
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 12,
          ),
        ),
      );
    }

    if (normalizedUrl.isEmpty) {
      return placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        normalizedUrl,
        width: 80,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder(),
      ),
    );
  }

  List<String> _parseKinds(String? rawKinds) {
    final raw = (rawKinds ?? '').trim();
    if (raw.isEmpty) {
      return const [];
    }

    final values = raw
        .replaceAll('，', ',')
        .replaceAll('|', ',')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (values.isEmpty) {
      return const [];
    }

    final seen = <String>{};
    final kinds = <String>[];
    for (final value in values) {
      if (seen.add(value)) {
        kinds.add(value);
      }
      if (kinds.length >= 4) {
        break;
      }
    }
    return kinds;
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CupertinoActivityIndicator(radius: 10)),
      );
    }

    if (_errorMessage != null && _results.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ShadButton.outline(
          onPressed: (_loadingInitial || _loadingMore)
              ? null
              : () => _loadNextPage(),
          child: const Text('加载更多失败，点击重试'),
        ),
      );
    }

    if (!_hasMore && _results.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text('没有更多了')),
      );
    }

    return const SizedBox(height: 8);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        CupertinoSliverNavigationBar(largeTitle: Text(widget.title)),
        if ((widget.sourceName ?? '').trim().isNotEmpty ||
            (widget.sourceUrl ?? '').trim().isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ShadCard(
                title: Text(
                  widget.sourceName?.trim().isNotEmpty ?? false
                      ? widget.sourceName!
                      : '发现来源',
                ),
                description: Text(
                  widget.sourceUrl?.trim().isNotEmpty ?? false
                      ? widget.sourceUrl!
                      : '聚合发现',
                ),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        if (_loadingInitial)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CupertinoActivityIndicator(radius: 12)),
            ),
          ),
        if (!_loadingInitial && _results.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ShadCard(
                title: const Text('提示'),
                description: Text(_errorMessage ?? (_message ?? '暂无发现结果')),
                footer: (_errorMessage == null)
                    ? null
                    : ShadButton.outline(
                        onPressed: (_loadingInitial || _loadingMore)
                            ? null
                            : () => _loadNextPage(isInitial: true),
                        child: const Text('重新加载'),
                      ),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        if (!_loadingInitial && _results.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final result = _results[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: index == 0 ? 8 : 0,
                ),
                child: _buildResultCard(result),
              );
            }, childCount: _results.length),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFooter(),
          ),
        ),
      ],
    );
  }
}
