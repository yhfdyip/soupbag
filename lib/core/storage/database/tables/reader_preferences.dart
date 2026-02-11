import 'package:drift/drift.dart';

class ReaderPreferences extends Table {
  TextColumn get key => text()();

  TextColumn get value => text().withDefault(const Constant(''))();

  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
