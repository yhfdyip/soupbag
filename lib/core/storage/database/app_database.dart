import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:soupbag/core/storage/database/tables/book_chapters.dart';
import 'package:soupbag/core/storage/database/tables/book_sources.dart';
import 'package:soupbag/core/storage/database/tables/books.dart';
import 'package:soupbag/core/storage/database/tables/reader_preferences.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Books, BookSources, BookChapters, ReaderPreferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(bookSources, bookSources.bookUrlPattern);
        await migrator.addColumn(bookSources, bookSources.customOrder);
        await migrator.addColumn(bookSources, bookSources.jsLib);
        await migrator.addColumn(bookSources, bookSources.enabledCookieJar);
        await migrator.addColumn(bookSources, bookSources.concurrentRate);
        await migrator.addColumn(bookSources, bookSources.loginUrl);
        await migrator.addColumn(bookSources, bookSources.loginUi);
        await migrator.addColumn(bookSources, bookSources.loginCheckJs);
        await migrator.addColumn(bookSources, bookSources.coverDecodeJs);
        await migrator.addColumn(bookSources, bookSources.bookSourceComment);
        await migrator.addColumn(bookSources, bookSources.variableComment);
        await migrator.addColumn(bookSources, bookSources.weight);
        await migrator.addColumn(bookSources, bookSources.exploreScreen);
        await migrator.addColumn(bookSources, bookSources.ruleExplore);
        await migrator.addColumn(bookSources, bookSources.ruleBookInfo);
        await migrator.addColumn(bookSources, bookSources.ruleReview);
      }
      if (from < 3) {
        await migrator.createTable(bookChapters);
      }
      if (from < 4) {
        await migrator.createTable(readerPreferences);
      }
    },
  );

  Future<void> upsertBook(BooksCompanion companion) async {
    await into(books).insertOnConflictUpdate(companion);
  }

  Future<Book?> findBookByUrl(String bookUrl) {
    return (select(
      books,
    )..where((table) => table.bookUrl.equals(bookUrl))).getSingleOrNull();
  }

  Future<List<Book>> getBookshelf() {
    return (select(books)..orderBy([
          (table) => OrderingTerm.desc(table.durChapterTime),
          (table) => OrderingTerm.asc(table.name),
        ]))
        .get();
  }

  Stream<List<Book>> watchBookshelf() {
    return (select(books)..orderBy([
          (table) => OrderingTerm.desc(table.durChapterTime),
          (table) => OrderingTerm.asc(table.name),
        ]))
        .watch();
  }

  Future<int> removeBookByUrl(String bookUrl) {
    return (delete(
      books,
    )..where((table) => table.bookUrl.equals(bookUrl))).go();
  }

  Future<void> upsertBookSource(BookSourcesCompanion companion) async {
    await into(bookSources).insertOnConflictUpdate(companion);
  }

  Future<void> upsertBookSourcesBatch(
    List<BookSourcesCompanion> companions,
  ) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(bookSources, companions);
    });
  }

  Future<BookSource?> findBookSourceByUrl(String sourceUrl) {
    return (select(bookSources)
          ..where((table) => table.bookSourceUrl.equals(sourceUrl)))
        .getSingleOrNull();
  }

  Future<List<BookSource>> getBookSources({bool? enabled}) {
    final query = select(bookSources)
      ..orderBy([(table) => OrderingTerm.asc(table.bookSourceName)]);

    if (enabled != null) {
      query.where((table) => table.enabled.equals(enabled));
    }

    return query.get();
  }

  Stream<List<BookSource>> watchBookSources({bool? enabled}) {
    final query = select(bookSources)
      ..orderBy([(table) => OrderingTerm.asc(table.bookSourceName)]);

    if (enabled != null) {
      query.where((table) => table.enabled.equals(enabled));
    }

    return query.watch();
  }

  Future<int> removeBookSourceByUrl(String sourceUrl) {
    return (delete(
      bookSources,
    )..where((table) => table.bookSourceUrl.equals(sourceUrl))).go();
  }

  Future<void> replaceBookChapters(
    String bookUrl,
    List<BookChaptersCompanion> companions,
  ) async {
    await transaction(() async {
      await (delete(
        bookChapters,
      )..where((table) => table.bookUrl.equals(bookUrl))).go();
      if (companions.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(bookChapters, companions);
        });
      }
    });
  }

  Future<List<BookChapter>> getBookChapters(String bookUrl) {
    return (select(bookChapters)
          ..where((table) => table.bookUrl.equals(bookUrl))
          ..orderBy([(table) => OrderingTerm.asc(table.chapterIndex)]))
        .get();
  }

  Future<void> saveChapterContent({
    required String bookUrl,
    required int chapterIndex,
    required String content,
    required int updateTime,
  }) async {
    await (update(bookChapters)..where(
          (table) =>
              table.bookUrl.equals(bookUrl) &
              table.chapterIndex.equals(chapterIndex),
        ))
        .write(
          BookChaptersCompanion(
            content: Value(content),
            updateTime: Value(updateTime),
          ),
        );
  }

  Future<void> saveReaderPreference({
    required String key,
    required String value,
    required int updatedAt,
  }) async {
    await into(readerPreferences).insertOnConflictUpdate(
      ReaderPreferencesCompanion(
        key: Value(key),
        value: Value(value),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<ReaderPreference?> getReaderPreference(String key) {
    return (select(
      readerPreferences,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
  }
}

QueryExecutor _openConnection() {
  if (kIsWeb) {
    throw UnsupportedError('Web 暂未接入数据库');
  }
  return driftDatabase(name: 'soupbag.sqlite');
}
