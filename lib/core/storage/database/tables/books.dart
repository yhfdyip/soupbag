import 'package:drift/drift.dart';

class Books extends Table {
  TextColumn get bookUrl => text()();

  TextColumn get tocUrl => text().withDefault(const Constant(''))();

  TextColumn get origin => text().withDefault(const Constant('local'))();

  TextColumn get originName => text().withDefault(const Constant(''))();

  TextColumn get name => text()();

  TextColumn get author => text().withDefault(const Constant(''))();

  TextColumn get coverUrl => text().nullable()();

  TextColumn get intro => text().nullable()();

  IntColumn get totalChapterNum => integer().withDefault(const Constant(0))();

  IntColumn get durChapterIndex => integer().withDefault(const Constant(0))();

  IntColumn get durChapterPos => integer().withDefault(const Constant(0))();

  IntColumn get durChapterTime => integer().withDefault(const Constant(0))();

  IntColumn get lastCheckTime => integer().withDefault(const Constant(0))();

  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {bookUrl};
}
