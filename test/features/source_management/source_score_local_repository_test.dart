import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/core/storage/database/app_database.dart';
import 'package:soupbag/features/source_management/data/local/source_score_local_repository.dart';

const bool _enableNativeDbTests = bool.fromEnvironment(
  'ENABLE_NATIVE_DB_TESTS',
);

void main() {
  group(
    'SourceScoreLocalRepository',
    skip: _enableNativeDbTests
        ? false
        : '当前运行环境 sqlite 版本不兼容，默认跳过原生 Drift FFI 测试',
    () {
      late AppDatabase database;
      late SourceScoreLocalRepository repository;

      setUp(() {
        database = AppDatabase.test(NativeDatabase.memory());
        repository = SourceScoreLocalRepository(database);
      });

      tearDown(() async {
        await database.close();
      });

      test('首次评分会累计到书源评分', () async {
        await repository.setBookScore(
          sourceUrl: 'mock://a',
          name: '测试书',
          author: '作者A',
          score: 1,
        );

        expect(
          await repository.getBookScore(
            sourceUrl: 'mock://a',
            name: '测试书',
            author: '作者A',
          ),
          1,
        );
        expect(await repository.getSourceScore('mock://a'), 1);
      });

      test('重复评分会按差值修正书源评分', () async {
        await repository.setBookScore(
          sourceUrl: 'mock://a',
          name: '测试书',
          author: '作者A',
          score: 1,
        );
        await repository.setBookScore(
          sourceUrl: 'mock://a',
          name: '测试书',
          author: '作者A',
          score: -1,
        );

        expect(
          await repository.getBookScore(
            sourceUrl: 'mock://a',
            name: '测试书',
            author: '作者A',
          ),
          -1,
        );
        expect(await repository.getSourceScore('mock://a'), -1);
      });

      test('清理来源评分会移除来源与书籍评分', () async {
        await repository.setBookScore(
          sourceUrl: 'mock://a',
          name: '测试书',
          author: '作者A',
          score: 1,
        );
        await repository.setBookScore(
          sourceUrl: 'mock://a',
          name: '测试书2',
          author: '作者A',
          score: -1,
        );

        await repository.clearSourceScores('mock://a');

        expect(
          await repository.getBookScore(
            sourceUrl: 'mock://a',
            name: '测试书',
            author: '作者A',
          ),
          0,
        );
        expect(
          await repository.getBookScore(
            sourceUrl: 'mock://a',
            name: '测试书2',
            author: '作者A',
          ),
          0,
        );
        expect(await repository.getSourceScore('mock://a'), 0);
      });
    },
  );
}
