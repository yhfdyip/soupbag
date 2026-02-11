class SearchResultOriginEntity {
  const SearchResultOriginEntity({
    required this.sourceUrl,
    required this.sourceName,
    this.bookUrl,
    this.coverUrl,
    this.intro,
    this.kind,
    this.wordCount,
    this.latestChapter,
  });

  final String sourceUrl;
  final String sourceName;
  final String? bookUrl;
  final String? coverUrl;
  final String? intro;
  final String? kind;
  final String? wordCount;
  final String? latestChapter;
}

class SearchResultEntity {
  const SearchResultEntity({
    required this.sourceUrl,
    required this.sourceName,
    required this.name,
    this.author,
    this.bookUrl,
    this.coverUrl,
    this.intro,
    this.kind,
    this.wordCount,
    this.latestChapter,
    this.originCount = 1,
    this.origins = const [],
  });

  final String sourceUrl;
  final String sourceName;
  final String name;
  final String? author;
  final String? bookUrl;
  final String? coverUrl;
  final String? intro;
  final String? kind;
  final String? wordCount;
  final String? latestChapter;
  final int originCount;
  final List<SearchResultOriginEntity> origins;
}
