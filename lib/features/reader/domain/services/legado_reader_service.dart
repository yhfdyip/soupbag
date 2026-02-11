import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';
import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';
import 'package:soupbag/legado/model/web_book/web_book.dart';

class LegadoBookInfo {
  const LegadoBookInfo({
    required this.sourceUrl,
    required this.sourceName,
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

  final String sourceUrl;
  final String sourceName;
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

class LegadoReaderService {
  LegadoReaderService({
    required LegadoHttpGateway httpGateway,
    required BookSourceRepository sourceRepository,
    required BookshelfRepository bookshelfRepository,
  }) : _sourceRepository = sourceRepository,
       _bookshelfRepository = bookshelfRepository,
       _webBook = LegadoWebBook(httpGateway: httpGateway);

  final BookSourceRepository _sourceRepository;
  final BookshelfRepository _bookshelfRepository;
  final LegadoWebBook _webBook;

  Future<LegadoBookInfo> fetchBookInfo({
    required String sourceUrl,
    required String fallbackName,
    String? fallbackAuthor,
    String? fallbackBookUrl,
    String? fallbackCoverUrl,
    String? fallbackIntro,
    bool canReName = true,
  }) async {
    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    final sourceName = source?.bookSourceName ?? sourceUrl;

    final fallback = _buildFallbackInfo(
      sourceUrl: sourceUrl,
      sourceName: sourceName,
      fallbackName: fallbackName,
      fallbackAuthor: fallbackAuthor,
      fallbackBookUrl: fallbackBookUrl,
      fallbackCoverUrl: fallbackCoverUrl,
      fallbackIntro: fallbackIntro,
    );
    if (source == null) {
      return fallback;
    }

    try {
      final parsed = await _webBook.getBookInfo(
        source: source,
        fallbackName: fallbackName,
        fallbackAuthor: fallbackAuthor,
        fallbackBookUrl: fallbackBookUrl,
        fallbackCoverUrl: fallbackCoverUrl,
        fallbackIntro: fallbackIntro,
        canReName: canReName,
      );

      return LegadoBookInfo(
        sourceUrl: sourceUrl,
        sourceName: sourceName,
        name: parsed.name,
        author: parsed.author,
        bookUrl: parsed.bookUrl,
        tocUrl: parsed.tocUrl,
        coverUrl: parsed.coverUrl,
        intro: parsed.intro,
        kind: parsed.kind,
        wordCount: parsed.wordCount,
        latestChapter: parsed.latestChapter,
        updateTime: parsed.updateTime,
        downloadUrls: parsed.downloadUrls,
      );
    } catch (_) {
      return fallback;
    }
  }

  Future<BookEntity> addSearchResultToBookshelf({
    required String sourceUrl,
    required String name,
    required String? author,
    required String? bookUrl,
    required String? coverUrl,
    required String? intro,
    String? tocUrl,
  }) async {
    final realBookUrl = (bookUrl == null || bookUrl.trim().isEmpty)
        ? 'generated://book/${DateTime.now().millisecondsSinceEpoch}'
        : bookUrl.trim();

    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    final now = DateTime.now().millisecondsSinceEpoch;

    final book = BookEntity(
      bookUrl: realBookUrl,
      tocUrl: (tocUrl == null || tocUrl.trim().isEmpty)
          ? realBookUrl
          : tocUrl.trim(),
      origin: sourceUrl,
      originName: source?.bookSourceName ?? sourceUrl,
      name: name,
      author: author ?? '',
      coverUrl: coverUrl,
      intro: intro,
      durChapterTime: now,
      createdAt: now,
      updatedAt: now,
      lastCheckTime: now,
    );

    await _bookshelfRepository.saveBook(book);
    return book;
  }

  Future<List<ChapterEntity>> fetchChapters({
    required String sourceUrl,
    required String bookUrl,
    String? tocUrl,
  }) async {
    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    if (source == null) {
      return const [];
    }

    return _webBook.getChapterList(
      source: source,
      bookUrl: bookUrl,
      tocUrl: tocUrl,
    );
  }

  Future<String?> fetchChapterContent({
    required String sourceUrl,
    required String bookUrl,
    required ChapterEntity chapter,
  }) async {
    final source = await _sourceRepository.findBookSourceByUrl(sourceUrl);
    if (source == null) {
      return null;
    }

    return _webBook.getContent(source: source, chapter: chapter);
  }

  LegadoBookInfo _buildFallbackInfo({
    required String sourceUrl,
    required String sourceName,
    required String fallbackName,
    String? fallbackAuthor,
    String? fallbackBookUrl,
    String? fallbackCoverUrl,
    String? fallbackIntro,
  }) {
    final rawName = fallbackName.trim();
    final realBookUrl = (fallbackBookUrl ?? '').trim().isEmpty
        ? 'generated://book/${DateTime.now().millisecondsSinceEpoch}'
        : fallbackBookUrl!.trim();

    return LegadoBookInfo(
      sourceUrl: sourceUrl,
      sourceName: sourceName,
      name: rawName.isEmpty ? '未命名书籍' : rawName,
      author: (fallbackAuthor ?? '').trim(),
      bookUrl: realBookUrl,
      tocUrl: realBookUrl,
      coverUrl: (fallbackCoverUrl ?? '').trim().isEmpty
          ? null
          : fallbackCoverUrl!.trim(),
      intro: (fallbackIntro ?? '').trim().isEmpty
          ? null
          : fallbackIntro!.trim(),
    );
  }
}
