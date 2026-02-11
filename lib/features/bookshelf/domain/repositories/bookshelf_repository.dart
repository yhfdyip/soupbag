import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';

abstract class BookshelfRepository {
  Stream<List<BookEntity>> watchBookshelf();

  Future<List<BookEntity>> getBookshelf();

  Future<void> saveBook(BookEntity book);

  Future<void> removeBook(String bookUrl);
}
