import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/core/storage/database/app_database.dart';

const bool _enableNativeDbTests = bool.fromEnvironment(
  'ENABLE_NATIVE_DB_TESTS',
);

void main() {
  group(
    'AppDatabase',
    skip: _enableNativeDbTests
        ? false
        : '当前运行环境 sqlite 版本不兼容，默认跳过原生 Drift FFI 测试',
    () {
      late AppDatabase database;

      setUp(() {
        database = AppDatabase.test(NativeDatabase.memory());
      });

      tearDown(() async {
        await database.close();
      });

      test('可写入并读取书籍', () async {
        final now = DateTime.now().millisecondsSinceEpoch;

        await database.upsertBook(
          BooksCompanion.insert(
            bookUrl: 'demo://book/1',
            name: '测试书籍',
            author: const Value('测试作者'),
            durChapterTime: Value(now),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        final list = await database.getBookshelf();
        expect(list, hasLength(1));
        expect(list.first.bookUrl, 'demo://book/1');
        expect(list.first.name, '测试书籍');
      });

      test('可写入并筛选书源', () async {
        await database.upsertBookSource(
          BookSourcesCompanion.insert(
            bookSourceUrl: 'demo://source/1',
            bookSourceName: '启用源',
            enabled: Value(true),
          ),
        );

        await database.upsertBookSource(
          BookSourcesCompanion.insert(
            bookSourceUrl: 'demo://source/2',
            bookSourceName: '停用源',
            enabled: Value(false),
          ),
        );

        final enabledSources = await database.getBookSources(enabled: true);
        final disabledSources = await database.getBookSources(enabled: false);

        expect(enabledSources, hasLength(1));
        expect(disabledSources, hasLength(1));
        expect(enabledSources.first.bookSourceUrl, 'demo://source/1');
        expect(disabledSources.first.bookSourceUrl, 'demo://source/2');
      });

      test('书源按 customOrder 排序并支持置顶置底', () async {
        await database.upsertBookSource(
          BookSourcesCompanion.insert(
            bookSourceUrl: 'demo://source/a',
            bookSourceName: 'A源',
            customOrder: const Value(10),
          ),
        );
        await database.upsertBookSource(
          BookSourcesCompanion.insert(
            bookSourceUrl: 'demo://source/b',
            bookSourceName: 'B源',
            customOrder: const Value(20),
          ),
        );
        await database.upsertBookSource(
          BookSourcesCompanion.insert(
            bookSourceUrl: 'demo://source/c',
            bookSourceName: 'C源',
            customOrder: const Value(30),
          ),
        );

        final initial = await database.getBookSources();
        expect(
          initial.map((item) => item.bookSourceUrl).toList(growable: false),
          ['demo://source/a', 'demo://source/b', 'demo://source/c'],
        );

        final minOrder = await database.getBookSourceMinOrder();
        final maxOrder = await database.getBookSourceMaxOrder();
        expect(minOrder, 10);
        expect(maxOrder, 30);

        await database.updateBookSourceOrder(
          sourceUrl: 'demo://source/c',
          customOrder: (minOrder ?? 0) - 1,
        );
        await database.updateBookSourceOrder(
          sourceUrl: 'demo://source/a',
          customOrder: (maxOrder ?? 0) + 1,
        );

        final moved = await database.getBookSources();
        expect(
          moved.map((item) => item.bookSourceUrl).toList(growable: false),
          ['demo://source/c', 'demo://source/b', 'demo://source/a'],
        );
      });
    },
  );
}
