class SearchResultEntity {
  const SearchResultEntity({
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
}
