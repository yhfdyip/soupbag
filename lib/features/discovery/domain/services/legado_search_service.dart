import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/discovery/domain/models/explore_kind_entity.dart';
import 'package:soupbag/features/discovery/domain/models/search_result_entity.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';
import 'package:soupbag/legado/model/web_book/book_list.dart';
import 'package:soupbag/legado/model/web_book/web_book.dart';

class LegadoSearchService {
  LegadoSearchService({
    required LegadoHttpGateway httpGateway,
    required BookSourceRepository sourceRepository,
  }) : _sourceRepository = sourceRepository,
       _webBook = LegadoWebBook(httpGateway: httpGateway);

  final BookSourceRepository _sourceRepository;
  final LegadoWebBook _webBook;

  Future<List<SearchResultEntity>> search(
    String keyword, {
    int page = 1,
    int maxSources = 8,
  }) async {
    final key = keyword.trim();
    if (key.isEmpty) {
      return const [];
    }

    final sources = await _sourceRepository.getBookSources(enabled: true);
    final candidates = sources
        .where(
          (source) =>
              source.searchUrl != null &&
              source.searchUrl!.isNotEmpty &&
              source.ruleSearch != null &&
              source.ruleSearch!.isNotEmpty,
        )
        .take(maxSources)
        .toList(growable: false);

    return _collectResults(
      candidates: candidates,
      fetcher: (source) =>
          _webBook.searchBook(source: source, keyword: key, page: page),
    );
  }

  Future<List<SearchResultEntity>> explore({
    int page = 1,
    int maxSources = 8,
    String? exploreUrl,
    String? sourceUrl,
  }) async {
    final normalizedSourceUrl = (sourceUrl ?? '').trim();
    final hasCustomExploreUrl =
        exploreUrl != null && exploreUrl.trim().isNotEmpty;

    if (normalizedSourceUrl.isNotEmpty) {
      final source = await _sourceRepository.findBookSourceByUrl(
        normalizedSourceUrl,
      );
      if (source == null ||
          !source.enabled ||
          !source.enabledExplore ||
          source.ruleExplore == null ||
          source.ruleExplore!.isEmpty ||
          (!hasCustomExploreUrl &&
              (source.exploreUrl == null || source.exploreUrl!.isEmpty))) {
        return const [];
      }

      return _collectResults(
        candidates: [source],
        fetcher: (target) => _webBook.exploreBook(
          source: target,
          exploreUrl: exploreUrl,
          page: page,
        ),
      );
    }

    final sources = await _sourceRepository.getBookSources(enabled: true);
    final candidates = sources
        .where(
          (source) =>
              source.enabledExplore &&
              source.ruleExplore != null &&
              source.ruleExplore!.isNotEmpty &&
              (hasCustomExploreUrl ||
                  (source.exploreUrl != null && source.exploreUrl!.isNotEmpty)),
        )
        .take(maxSources)
        .toList(growable: false);

    return _collectResults(
      candidates: candidates,
      fetcher: (source) => _webBook.exploreBook(
        source: source,
        exploreUrl: exploreUrl,
        page: page,
      ),
    );
  }

  Future<List<ExploreSourceKindsEntity>> getExploreKinds({
    int maxSources = 8,
  }) async {
    final sources = await _sourceRepository.getBookSources(enabled: true);
    final candidates = sources
        .where(
          (source) =>
              source.enabledExplore &&
              source.exploreUrl != null &&
              source.exploreUrl!.isNotEmpty &&
              source.ruleExplore != null &&
              source.ruleExplore!.isNotEmpty,
        )
        .take(maxSources)
        .toList(growable: false);

    final groups = <ExploreSourceKindsEntity>[];
    for (final source in candidates) {
      try {
        final kinds = _webBook
            .getExploreKinds(source: source)
            .where(
              (item) =>
                  item.title.trim().isNotEmpty &&
                  (item.url ?? '').trim().isNotEmpty,
            )
            .map(
              (item) => ExploreKindEntity(
                title: item.title,
                exploreUrl: item.url,
                style: item.style == null
                    ? null
                    : ExploreKindStyleEntity(
                        layoutFlexGrow: item.style!.layoutFlexGrow,
                        layoutFlexShrink: item.style!.layoutFlexShrink,
                        layoutAlignSelf: item.style!.layoutAlignSelf,
                        layoutFlexBasisPercent:
                            item.style!.layoutFlexBasisPercent,
                        layoutWrapBefore: item.style!.layoutWrapBefore,
                      ),
              ),
            )
            .toList(growable: false);

        if (kinds.isEmpty) {
          continue;
        }

        groups.add(
          ExploreSourceKindsEntity(
            sourceUrl: source.bookSourceUrl,
            sourceName: source.bookSourceName,
            kinds: kinds,
          ),
        );
      } catch (_) {
        continue;
      }
    }

    return groups;
  }

  Future<List<SearchResultEntity>> _collectResults({
    required List<BookSourceEntity> candidates,
    required Future<List<ParsedLegadoBookListItem>> Function(
      BookSourceEntity source,
    )
    fetcher,
  }) async {
    final mergedResults = <String, SearchResultEntity>{};
    final mergedOrigins = <String, Set<String>>{};
    final mergedOriginItems = <String, List<SearchResultOriginEntity>>{};

    for (final source in candidates) {
      try {
        final parsedItems = await fetcher(source);
        for (final item in parsedItems) {
          final mergeKey = _buildMergeKey(item: item);
          final currentOrigins = mergedOrigins.putIfAbsent(
            mergeKey,
            () => <String>{},
          );
          currentOrigins.add(source.bookSourceUrl);

          final originItems = mergedOriginItems.putIfAbsent(
            mergeKey,
            () => <SearchResultOriginEntity>[],
          );
          final originItem = _buildOriginItem(source: source, item: item);
          if (!_containsOrigin(
            originItems: originItems,
            sourceUrl: source.bookSourceUrl,
          )) {
            originItems.add(originItem);
          }

          final existing = mergedResults[mergeKey];
          if (existing == null) {
            mergedResults[mergeKey] = SearchResultEntity(
              sourceUrl: source.bookSourceUrl,
              sourceName: source.bookSourceName,
              name: item.name,
              author: item.author,
              bookUrl: item.bookUrl,
              coverUrl: item.coverUrl,
              intro: item.intro,
              kind: item.kind,
              wordCount: item.wordCount,
              latestChapter: item.latestChapter,
              originCount: currentOrigins.length,
              origins: List.unmodifiable(originItems),
            );
            continue;
          }

          mergedResults[mergeKey] = SearchResultEntity(
            sourceUrl: existing.sourceUrl,
            sourceName: existing.sourceName,
            name: existing.name,
            author: existing.author,
            bookUrl: existing.bookUrl,
            coverUrl: existing.coverUrl,
            intro: existing.intro,
            kind: existing.kind,
            wordCount: existing.wordCount,
            latestChapter: existing.latestChapter,
            originCount: currentOrigins.length,
            origins: List.unmodifiable(originItems),
          );
        }
      } catch (_) {
        continue;
      }
    }

    return mergedResults.values.toList(growable: false);
  }

  SearchResultOriginEntity _buildOriginItem({
    required BookSourceEntity source,
    required ParsedLegadoBookListItem item,
  }) {
    return SearchResultOriginEntity(
      sourceUrl: source.bookSourceUrl,
      sourceName: source.bookSourceName,
      bookUrl: item.bookUrl,
      coverUrl: item.coverUrl,
      intro: item.intro,
      kind: item.kind,
      wordCount: item.wordCount,
      latestChapter: item.latestChapter,
    );
  }

  bool _containsOrigin({
    required List<SearchResultOriginEntity> originItems,
    required String sourceUrl,
  }) {
    for (final item in originItems) {
      if (item.sourceUrl == sourceUrl) {
        return true;
      }
    }
    return false;
  }

  String _buildMergeKey({required ParsedLegadoBookListItem item}) {
    final name = item.name.trim();
    final author = (item.author ?? '').trim();
    final bookUrl = item.bookUrl.trim();

    if (name.isNotEmpty) {
      if (author.isNotEmpty) {
        return 'name_author:$name::$author';
      }
      return 'name:$name';
    }

    if (bookUrl.isNotEmpty) {
      return 'book_url:$bookUrl';
    }

    return 'fallback:${item.bookUrl}|${item.name}';
  }
}
