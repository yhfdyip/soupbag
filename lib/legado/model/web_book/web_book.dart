import 'dart:convert';

import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/legado/model/web_book/book_chapter_list.dart';
import 'package:soupbag/legado/model/web_book/book_content.dart';
import 'package:soupbag/legado/model/web_book/book_info.dart';
import 'package:soupbag/legado/model/web_book/book_list.dart';
import 'package:soupbag/legado/model/web_book/explore_kinds.dart';
import 'package:soupbag/legado/model/web_book/rule_execution_context.dart';

class LegadoWebBookInfoResult {
  const LegadoWebBookInfoResult({
    required this.name,
    required this.author,
    required this.bookUrl,
    required this.tocUrl,
    this.coverUrl,
    this.intro,
    this.kind,
    this.wordCount,
    this.latestChapter,
    this.updateTime,
    this.downloadUrls = const [],
  });

  final String name;
  final String author;
  final String bookUrl;
  final String tocUrl;
  final String? coverUrl;
  final String? intro;
  final String? kind;
  final String? wordCount;
  final String? latestChapter;
  final String? updateTime;
  final List<String> downloadUrls;
}

class LegadoWebBook {
  LegadoWebBook({
    required LegadoHttpGateway httpGateway,
    LegadoBookInfoAnalyzer bookInfoAnalyzer = const LegadoBookInfoAnalyzer(),
    LegadoBookChapterListAnalyzer chapterListAnalyzer =
        const LegadoBookChapterListAnalyzer(),
    LegadoBookContentAnalyzer contentAnalyzer =
        const LegadoBookContentAnalyzer(),
    LegadoBookListAnalyzer bookListAnalyzer = const LegadoBookListAnalyzer(),
    LegadoExploreKindsAnalyzer exploreKindsAnalyzer =
        const LegadoExploreKindsAnalyzer(),
  }) : _executionContext = LegadoRuleExecutionContext(httpGateway: httpGateway),
       _bookInfoAnalyzer = bookInfoAnalyzer,
       _chapterListAnalyzer = chapterListAnalyzer,
       _contentAnalyzer = contentAnalyzer,
       _bookListAnalyzer = bookListAnalyzer,
       _exploreKindsAnalyzer = exploreKindsAnalyzer;

  final LegadoRuleExecutionContext _executionContext;
  final LegadoBookInfoAnalyzer _bookInfoAnalyzer;
  final LegadoBookChapterListAnalyzer _chapterListAnalyzer;
  final LegadoBookContentAnalyzer _contentAnalyzer;
  final LegadoBookListAnalyzer _bookListAnalyzer;
  final LegadoExploreKindsAnalyzer _exploreKindsAnalyzer;

  Future<List<ParsedLegadoBookListItem>> searchBook({
    required BookSourceEntity source,
    required String keyword,
    int page = 1,
  }) async {
    final searchUrlTemplate = source.searchUrl;
    final rawRuleSearch = source.ruleSearch;
    if (searchUrlTemplate == null ||
        searchUrlTemplate.trim().isEmpty ||
        rawRuleSearch == null ||
        rawRuleSearch.trim().isEmpty) {
      return const [];
    }

    final execution = await _executionContext.execute(
      source: source,
      rawUrl: searchUrlTemplate,
      baseUrl: source.bookSourceUrl,
      replacements: {'key': Uri.encodeQueryComponent(keyword), 'page': '$page'},
    );
    if (execution == null) {
      return const [];
    }

    if (_isBookDetailUrl(source: source, url: execution.responseUrl)) {
      final info = await getBookInfo(
        source: source,
        fallbackName: '',
        fallbackAuthor: '',
        fallbackBookUrl: execution.responseUrl,
        canReName: true,
      );

      if (info.name.trim().isEmpty) {
        return const [];
      }

      return [
        ParsedLegadoBookListItem(
          name: info.name,
          author: info.author,
          bookUrl: info.bookUrl,
          coverUrl: info.coverUrl,
          intro: info.intro,
          kind: info.kind,
          wordCount: info.wordCount,
          latestChapter: info.latestChapter,
        ),
      ];
    }

    final rules = _bookListAnalyzer.decodeRules(rawRuleSearch);
    return _bookListAnalyzer.parse(
      responseBody: execution.body,
      rules: rules,
      pageUrl: execution.responseUrl,
    );
  }

  Future<List<ParsedLegadoBookListItem>> exploreBook({
    required BookSourceEntity source,
    String? exploreUrl,
    int page = 1,
  }) async {
    final rawRuleExplore = source.ruleExplore;
    if (rawRuleExplore == null || rawRuleExplore.trim().isEmpty) {
      return const [];
    }

    final exploreUrlTemplate = _pickExploreUrlTemplate(
      sourceExploreUrl: source.exploreUrl,
      overrideExploreUrl: exploreUrl,
    );
    if (exploreUrlTemplate == null || exploreUrlTemplate.isEmpty) {
      return const [];
    }

    final execution = await _executionContext.execute(
      source: source,
      rawUrl: exploreUrlTemplate,
      baseUrl: source.bookSourceUrl,
      replacements: {'page': '$page', 'key': ''},
    );
    if (execution == null) {
      return const [];
    }

    final rules = _bookListAnalyzer.decodeRules(rawRuleExplore);
    return _bookListAnalyzer.parse(
      responseBody: execution.body,
      rules: rules,
      pageUrl: execution.responseUrl,
    );
  }

  List<LegadoExploreKind> getExploreKinds({
    required BookSourceEntity source,
    String? overrideExploreUrl,
  }) {
    final candidate = (overrideExploreUrl ?? '').trim().isNotEmpty
        ? overrideExploreUrl!.trim()
        : (source.exploreUrl ?? '').trim();
    if (candidate.isEmpty) {
      return const [];
    }

    final kinds = _exploreKindsAnalyzer.parse(rawExploreUrl: candidate);
    if (kinds.isEmpty) {
      return const [];
    }

    final screenStyles = _exploreKindsAnalyzer.parseScreenStyles(
      rawExploreScreen: source.exploreScreen,
    );
    if (screenStyles.isEmpty) {
      return kinds;
    }

    return kinds
        .map((kind) {
          if (kind.style != null) {
            return kind;
          }

          final style = screenStyles[kind.title.trim()];
          if (style == null) {
            return kind;
          }

          return kind.copyWith(style: style);
        })
        .toList(growable: false);
  }

  Future<LegadoWebBookInfoResult> getBookInfo({
    required BookSourceEntity source,
    required String fallbackName,
    String? fallbackAuthor,
    String? fallbackBookUrl,
    String? fallbackCoverUrl,
    String? fallbackIntro,
    bool canReName = true,
  }) async {
    final fallbackNameTrimmed = fallbackName.trim();
    var name = fallbackNameTrimmed.isEmpty ? '未命名书籍' : fallbackNameTrimmed;
    final fallbackNameWasEmpty = fallbackNameTrimmed.isEmpty;

    final fallbackAuthorTrimmed = (fallbackAuthor ?? '').trim();
    var author = fallbackAuthorTrimmed;
    final fallbackAuthorWasEmpty = fallbackAuthorTrimmed.isEmpty;

    var bookUrl = (fallbackBookUrl ?? '').trim();
    var tocUrl = '';
    var coverUrl = (fallbackCoverUrl ?? '').trim();
    var intro = (fallbackIntro ?? '').trim();
    var kind = '';
    var wordCount = '';
    var latestChapter = '';
    var updateTime = '';
    var downloadUrls = const <String>[];

    if (bookUrl.isEmpty) {
      bookUrl = 'generated://book/${DateTime.now().millisecondsSinceEpoch}';
    }
    tocUrl = bookUrl;

    final rawRuleBookInfo = source.ruleBookInfo;
    if (rawRuleBookInfo != null && rawRuleBookInfo.trim().isNotEmpty) {
      final rules = _bookInfoAnalyzer.decodeRules(rawRuleBookInfo);
      final infoUrl = _bookInfoAnalyzer.buildInfoUrl(
        rules: rules,
        fallbackBookUrl: bookUrl,
        sourceBaseUrl: source.bookSourceUrl,
      );

      if (infoUrl != null && infoUrl.isNotEmpty) {
        try {
          final execution = await _executionContext.execute(
            source: source,
            rawUrl: infoUrl,
            baseUrl: source.bookSourceUrl,
          );
          if (execution == null) {
            return LegadoWebBookInfoResult(
              name: name,
              author: author,
              bookUrl: bookUrl,
              tocUrl: tocUrl,
              coverUrl: coverUrl.trim().isEmpty ? null : coverUrl,
              intro: intro.trim().isEmpty ? null : intro,
              kind: kind.trim().isEmpty ? null : kind,
              wordCount: wordCount.trim().isEmpty ? null : wordCount,
              latestChapter: latestChapter.trim().isEmpty
                  ? null
                  : latestChapter,
              updateTime: updateTime.trim().isEmpty ? null : updateTime,
              downloadUrls: downloadUrls,
            );
          }

          final parsed = _bookInfoAnalyzer.parseResponse(
            responseBody: execution.body,
            rules: rules,
            pageUrl: execution.responseUrl,
          );

          final canRenameFromRule = canReName && parsed.canRenameRule;

          if (parsed.name != null &&
              parsed.name!.isNotEmpty &&
              (canRenameFromRule || fallbackNameWasEmpty)) {
            name = parsed.name!;
          }
          if (parsed.author != null &&
              parsed.author!.isNotEmpty &&
              (canRenameFromRule || fallbackAuthorWasEmpty)) {
            author = parsed.author!;
          }
          if (parsed.intro != null && parsed.intro!.isNotEmpty) {
            intro = parsed.intro!;
          }
          if (parsed.kind != null && parsed.kind!.isNotEmpty) {
            kind = parsed.kind!;
          }
          if (parsed.wordCount != null && parsed.wordCount!.isNotEmpty) {
            wordCount = parsed.wordCount!;
          }
          if (parsed.latestChapter != null &&
              parsed.latestChapter!.isNotEmpty) {
            latestChapter = parsed.latestChapter!;
          }
          if (parsed.updateTime != null && parsed.updateTime!.isNotEmpty) {
            updateTime = parsed.updateTime!;
          }
          if (parsed.bookUrl != null && parsed.bookUrl!.isNotEmpty) {
            bookUrl = parsed.bookUrl!;
          }
          if (parsed.tocUrl != null && parsed.tocUrl!.isNotEmpty) {
            tocUrl = parsed.tocUrl!;
          }
          if (parsed.coverUrl != null && parsed.coverUrl!.isNotEmpty) {
            coverUrl = parsed.coverUrl!;
          }
          if (parsed.downloadUrls.isNotEmpty) {
            downloadUrls = List.unmodifiable(parsed.downloadUrls);
          }
        } catch (_) {}
      }
    }

    if (tocUrl.trim().isEmpty) {
      tocUrl = bookUrl;
    }

    return LegadoWebBookInfoResult(
      name: name,
      author: author,
      bookUrl: bookUrl,
      tocUrl: tocUrl,
      coverUrl: coverUrl.trim().isEmpty ? null : coverUrl,
      intro: intro.trim().isEmpty ? null : intro,
      kind: kind.trim().isEmpty ? null : kind,
      wordCount: wordCount.trim().isEmpty ? null : wordCount,
      latestChapter: latestChapter.trim().isEmpty ? null : latestChapter,
      updateTime: updateTime.trim().isEmpty ? null : updateTime,
      downloadUrls: downloadUrls,
    );
  }

  Future<List<ChapterEntity>> getChapterList({
    required BookSourceEntity source,
    required String bookUrl,
    String? tocUrl,
  }) async {
    final rawRuleToc = source.ruleToc;
    if (rawRuleToc == null || rawRuleToc.trim().isEmpty) {
      return const [];
    }

    final rules = _chapterListAnalyzer.decodeRules(rawRuleToc);
    final requestUrl =
        _chapterListAnalyzer.buildTocUrl(
          rules: rules,
          bookUrl: bookUrl,
          tocUrl: tocUrl,
          sourceBaseUrl: source.bookSourceUrl,
        ) ??
        _executionContext.resolveUrlWithBase(rawUrl: tocUrl, baseUrl: bookUrl);
    final execution = await _executionContext.execute(
      source: source,
      rawUrl: requestUrl,
      baseUrl: source.bookSourceUrl,
    );
    if (execution == null) {
      return const [];
    }

    return _chapterListAnalyzer.parseChapterList(
      responseBody: execution.body,
      rules: rules,
      bookUrl: bookUrl,
      pageUrl: execution.responseUrl,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<String?> getContent({
    required BookSourceEntity source,
    required ChapterEntity chapter,
  }) async {
    if (chapter.chapterUrl.trim().isEmpty) {
      return null;
    }

    final rawRuleContent = source.ruleContent;
    if (rawRuleContent == null || rawRuleContent.trim().isEmpty) {
      return null;
    }

    final rules = _contentAnalyzer.decodeRules(rawRuleContent);
    final execution = await _executionContext.execute(
      source: source,
      rawUrl: chapter.chapterUrl,
      baseUrl: source.bookSourceUrl,
    );
    if (execution == null) {
      return null;
    }

    return _contentAnalyzer.parseContent(
      responseBody: execution.body,
      rules: rules,
      pageUrl: execution.responseUrl,
    );
  }

  String? _pickExploreUrlTemplate({
    required String? sourceExploreUrl,
    String? overrideExploreUrl,
  }) {
    final candidate = (overrideExploreUrl ?? '').trim().isNotEmpty
        ? overrideExploreUrl!.trim()
        : (sourceExploreUrl ?? '').trim();
    if (candidate.isEmpty) {
      return null;
    }

    final kinds = _exploreKindsAnalyzer.parse(rawExploreUrl: candidate);
    for (final kind in kinds) {
      final kindUrl = (kind.url ?? '').trim();
      if (kindUrl.isNotEmpty) {
        return kindUrl;
      }
    }

    final directFromJson = _extractExploreUrlFromJson(candidate);
    if (directFromJson != null && directFromJson.isNotEmpty) {
      return directFromJson;
    }

    final firstLine = candidate
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    if (firstLine.isEmpty) {
      return null;
    }

    if (firstLine.contains('::')) {
      final normalized = firstLine.split('::').last.trim();
      return normalized.isEmpty ? null : normalized;
    }

    return firstLine;
  }

  String? _extractExploreUrlFromJson(String raw) {
    if (!raw.startsWith('[') && !raw.startsWith('{')) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final entry in decoded) {
          if (entry is String && entry.trim().isNotEmpty) {
            return entry.trim();
          }
          if (entry is Map) {
            final value = entry['url'];
            if (value is String && value.trim().isNotEmpty) {
              return value.trim();
            }
          }
        }
      }
      if (decoded is Map) {
        final value = decoded['url'];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  bool _isBookDetailUrl({
    required BookSourceEntity source,
    required String url,
  }) {
    final pattern = (source.bookUrlPattern ?? '').trim();
    if (pattern.isEmpty) {
      return false;
    }

    try {
      return RegExp(pattern).hasMatch(url);
    } catch (_) {
      return false;
    }
  }
}
