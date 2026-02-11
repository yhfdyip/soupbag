import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';

abstract class BookSourceRepository {
  Stream<List<BookSourceEntity>> watchBookSources({bool? enabled});

  Future<List<BookSourceEntity>> getBookSources({bool? enabled});

  Future<BookSourceEntity?> findBookSourceByUrl(String sourceUrl);

  Future<void> saveBookSource(BookSourceEntity source);

  Future<void> saveBookSources(List<BookSourceEntity> sources);

  Future<void> removeBookSource(String sourceUrl);

  Future<void> setBookSourceEnabled(String sourceUrl, bool enabled);

  Future<void> moveBookSourceToTop(String sourceUrl);

  Future<void> moveBookSourceToBottom(String sourceUrl);
}
