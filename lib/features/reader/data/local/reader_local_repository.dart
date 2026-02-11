import 'package:drift/drift.dart';
import 'package:soupbag/core/storage/database/app_database.dart';
import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';

class ReaderLocalRepository {
  ReaderLocalRepository(this._database);

  final AppDatabase _database;

  Future<void> replaceChapters(
    String bookUrl,
    List<ChapterEntity> chapters,
  ) async {
    final companions = chapters
        .map(
          (chapter) => BookChaptersCompanion.insert(
            bookUrl: chapter.bookUrl,
            chapterIndex: chapter.chapterIndex,
            title: chapter.title,
            chapterUrl: Value(chapter.chapterUrl),
            content: Value(chapter.content),
            isVolume: Value(chapter.isVolume),
            updateTime: Value(chapter.updateTime),
          ),
        )
        .toList(growable: false);

    await _database.replaceBookChapters(bookUrl, companions);
  }

  Future<List<ChapterEntity>> getChapters(String bookUrl) async {
    final rows = await _database.getBookChapters(bookUrl);
    return rows
        .map(
          (row) => ChapterEntity(
            bookUrl: row.bookUrl,
            chapterIndex: row.chapterIndex,
            title: row.title,
            chapterUrl: row.chapterUrl,
            content: row.content,
            isVolume: row.isVolume,
            updateTime: row.updateTime,
          ),
        )
        .toList(growable: false);
  }

  Future<void> saveChapterContent({
    required String bookUrl,
    required int chapterIndex,
    required String content,
  }) {
    return _database.saveChapterContent(
      bookUrl: bookUrl,
      chapterIndex: chapterIndex,
      content: content,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
