import 'package:drift/drift.dart';

class BookChapters extends Table {
  TextColumn get bookUrl => text()();

  IntColumn get chapterIndex => integer()();

  TextColumn get title => text()();

  TextColumn get chapterUrl => text().withDefault(const Constant(''))();

  TextColumn get content => text().nullable()();

  BoolColumn get isVolume => boolean().withDefault(const Constant(false))();

  IntColumn get updateTime => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {bookUrl, chapterIndex};
}
