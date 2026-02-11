import 'package:drift/drift.dart';
import 'package:soupbag/core/storage/database/app_database.dart';
import 'package:soupbag/features/source_management/domain/models/book_source_entity.dart';
import 'package:soupbag/features/source_management/domain/repositories/book_source_repository.dart';

class BookSourceLocalRepository implements BookSourceRepository {
  BookSourceLocalRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<BookSourceEntity>> watchBookSources({bool? enabled}) {
    return _database
        .watchBookSources(enabled: enabled)
        .map((rows) => rows.map(_toEntity).toList(growable: false));
  }

  @override
  Future<List<BookSourceEntity>> getBookSources({bool? enabled}) async {
    final rows = await _database.getBookSources(enabled: enabled);
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<BookSourceEntity?> findBookSourceByUrl(String sourceUrl) async {
    final row = await _database.findBookSourceByUrl(sourceUrl);
    if (row == null) {
      return null;
    }
    return _toEntity(row);
  }

  @override
  Future<void> saveBookSource(BookSourceEntity source) {
    return _database.upsertBookSource(_toCompanion(source));
  }

  @override
  Future<void> saveBookSources(List<BookSourceEntity> sources) async {
    final companions = sources.map(_toCompanion).toList(growable: false);
    await _database.upsertBookSourcesBatch(companions);
  }

  @override
  Future<void> removeBookSource(String sourceUrl) async {
    await _database.removeBookSourceByUrl(sourceUrl);
  }

  @override
  Future<void> setBookSourceEnabled(String sourceUrl, bool enabled) {
    return _database.setBookSourceEnabled(sourceUrl, enabled);
  }

  @override
  Future<void> moveBookSourceToTop(String sourceUrl) async {
    final minOrder = await _database.getBookSourceMinOrder();
    final nextOrder = (minOrder ?? 0) - 1;
    await _database.updateBookSourceOrder(
      sourceUrl: sourceUrl,
      customOrder: nextOrder,
    );
  }

  @override
  Future<void> moveBookSourceToBottom(String sourceUrl) async {
    final maxOrder = await _database.getBookSourceMaxOrder();
    final nextOrder = (maxOrder ?? 0) + 1;
    await _database.updateBookSourceOrder(
      sourceUrl: sourceUrl,
      customOrder: nextOrder,
    );
  }

  BookSourceEntity _toEntity(BookSource row) {
    return BookSourceEntity(
      bookSourceUrl: row.bookSourceUrl,
      bookSourceName: row.bookSourceName,
      bookSourceGroup: row.bookSourceGroup,
      bookSourceType: row.bookSourceType,
      bookUrlPattern: row.bookUrlPattern,
      customOrder: row.customOrder,
      enabled: row.enabled,
      enabledExplore: row.enabledExplore,
      jsLib: row.jsLib,
      enabledCookieJar: row.enabledCookieJar,
      concurrentRate: row.concurrentRate,
      header: row.header,
      loginUrl: row.loginUrl,
      loginUi: row.loginUi,
      loginCheckJs: row.loginCheckJs,
      coverDecodeJs: row.coverDecodeJs,
      bookSourceComment: row.bookSourceComment,
      variableComment: row.variableComment,
      lastUpdateTime: row.lastUpdateTime,
      respondTime: row.respondTime,
      weight: row.weight,
      exploreUrl: row.exploreUrl,
      exploreScreen: row.exploreScreen,
      ruleExplore: row.ruleExplore,
      searchUrl: row.searchUrl,
      ruleSearch: row.ruleSearch,
      ruleBookInfo: row.ruleBookInfo,
      ruleToc: row.ruleToc,
      ruleContent: row.ruleContent,
      ruleReview: row.ruleReview,
    );
  }

  BookSourcesCompanion _toCompanion(BookSourceEntity source) {
    return BookSourcesCompanion(
      bookSourceUrl: Value(source.bookSourceUrl),
      bookSourceName: Value(source.bookSourceName),
      bookSourceGroup: Value(source.bookSourceGroup),
      bookSourceType: Value(source.bookSourceType),
      bookUrlPattern: Value(source.bookUrlPattern),
      customOrder: Value(source.customOrder),
      enabled: Value(source.enabled),
      enabledExplore: Value(source.enabledExplore),
      jsLib: Value(source.jsLib),
      enabledCookieJar: Value(source.enabledCookieJar),
      concurrentRate: Value(source.concurrentRate),
      header: Value(source.header),
      loginUrl: Value(source.loginUrl),
      loginUi: Value(source.loginUi),
      loginCheckJs: Value(source.loginCheckJs),
      coverDecodeJs: Value(source.coverDecodeJs),
      bookSourceComment: Value(source.bookSourceComment),
      variableComment: Value(source.variableComment),
      lastUpdateTime: Value(source.lastUpdateTime),
      respondTime: Value(source.respondTime),
      weight: Value(source.weight),
      exploreUrl: Value(source.exploreUrl),
      exploreScreen: Value(source.exploreScreen),
      ruleExplore: Value(source.ruleExplore),
      searchUrl: Value(source.searchUrl),
      ruleSearch: Value(source.ruleSearch),
      ruleBookInfo: Value(source.ruleBookInfo),
      ruleToc: Value(source.ruleToc),
      ruleContent: Value(source.ruleContent),
      ruleReview: Value(source.ruleReview),
    );
  }
}
