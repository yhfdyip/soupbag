class BookEntity {
  const BookEntity({
    required this.bookUrl,
    required this.name,
    this.tocUrl = '',
    this.origin = 'local',
    this.originName = '',
    this.author = '',
    this.coverUrl,
    this.intro,
    this.totalChapterNum = 0,
    this.durChapterIndex = 0,
    this.durChapterPos = 0,
    this.durChapterTime = 0,
    this.lastCheckTime = 0,
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  final String bookUrl;
  final String tocUrl;
  final String origin;
  final String originName;
  final String name;
  final String author;
  final String? coverUrl;
  final String? intro;
  final int totalChapterNum;
  final int durChapterIndex;
  final int durChapterPos;
  final int durChapterTime;
  final int lastCheckTime;
  final int createdAt;
  final int updatedAt;
}
