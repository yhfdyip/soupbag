import 'package:drift/drift.dart';
import 'package:soupbag/core/storage/database/app_database.dart';
import 'package:soupbag/features/reader/domain/models/chapter_entity.dart';

class ReaderPreferenceKeys {
  static const themePreset = 'reader.themePreset';
  static const fontSize = 'reader.fontSize';
  static const lineHeight = 'reader.lineHeight';
  static const pageMode = 'reader.pageMode';
  static const brightness = 'reader.brightness';
  static const followSystemBrightness = 'reader.followSystemBrightness';
  static const showBrightnessPanel = 'reader.showBrightnessPanel';
  static const tapToTurnPage = 'reader.tapToTurnPage';
  static const replaceRules = 'reader.replaceRules';
  static const bookmarks = 'reader.bookmarks';
  static const history = 'reader.history';
}

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

  Future<void> savePreference({required String key, required String value}) {
    return _database.saveReaderPreference(
      key: key,
      value: value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<String?> getPreference(String key) async {
    final row = await _database.getReaderPreference(key);
    return row?.value;
  }
}
