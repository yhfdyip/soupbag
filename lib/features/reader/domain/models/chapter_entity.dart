class ChapterEntity {
  const ChapterEntity({
    required this.bookUrl,
    required this.chapterIndex,
    required this.title,
    required this.chapterUrl,
    this.content,
    this.isVolume = false,
    this.updateTime = 0,
  });

  final String bookUrl;
  final int chapterIndex;
  final String title;
  final String chapterUrl;
  final String? content;
  final bool isVolume;
  final int updateTime;
}
