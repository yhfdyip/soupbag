import 'package:drift/drift.dart';
import 'package:soupbag/core/storage/database/app_database.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';

class BookshelfLocalRepository implements BookshelfRepository {
  BookshelfLocalRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<BookEntity>> watchBookshelf() {
    return _database
        .watchBookshelf()
        .map((rows) => rows.map(_toEntity).toList(growable: false));
  }

  @override
  Future<List<BookEntity>> getBookshelf() async {
    final rows = await _database.getBookshelf();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<void> saveBook(BookEntity book) {
    return _database.upsertBook(_toCompanion(book));
  }

  @override
  Future<void> removeBook(String bookUrl) async {
    await _database.removeBookByUrl(bookUrl);
  }

  BookEntity _toEntity(Book row) {
    return BookEntity(
      bookUrl: row.bookUrl,
      tocUrl: row.tocUrl,
      origin: row.origin,
      originName: row.originName,
      name: row.name,
      author: row.author,
      coverUrl: row.coverUrl,
      intro: row.intro,
      totalChapterNum: row.totalChapterNum,
      durChapterIndex: row.durChapterIndex,
      durChapterPos: row.durChapterPos,
      durChapterTime: row.durChapterTime,
      lastCheckTime: row.lastCheckTime,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  BooksCompanion _toCompanion(BookEntity book) {
    return BooksCompanion(
      bookUrl: Value(book.bookUrl),
      tocUrl: Value(book.tocUrl),
      origin: Value(book.origin),
      originName: Value(book.originName),
      name: Value(book.name),
      author: Value(book.author),
      coverUrl: Value(book.coverUrl),
      intro: Value(book.intro),
      totalChapterNum: Value(book.totalChapterNum),
      durChapterIndex: Value(book.durChapterIndex),
      durChapterPos: Value(book.durChapterPos),
      durChapterTime: Value(book.durChapterTime),
      lastCheckTime: Value(book.lastCheckTime),
      createdAt: Value(book.createdAt),
      updatedAt: Value(book.updatedAt),
    );
  }
}
