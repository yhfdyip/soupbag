import 'dart:math';

import 'package:soupbag/core/storage/database/app_database.dart';

class SourceScoreLocalRepository {
  SourceScoreLocalRepository(this._database);

  final AppDatabase _database;

  static const _sourcePrefix = 'source.score.';
  static const _bookPrefix = 'source.book_score.';

  String _sourceScoreKey(String sourceUrl) => '$_sourcePrefix$sourceUrl';

  String _bookScoreKey({
    required String sourceUrl,
    required String name,
    required String author,
  }) {
    return '$_bookPrefix$sourceUrl\u0000$name\u0000$author';
  }

  Future<int> getSourceScore(String sourceUrl) async {
    final row = await _database.getReaderPreference(_sourceScoreKey(sourceUrl));
    return int.tryParse(row?.value ?? '') ?? 0;
  }

  Future<int> getBookScore({
    required String sourceUrl,
    required String name,
    required String author,
  }) async {
    final row = await _database.getReaderPreference(
      _bookScoreKey(sourceUrl: sourceUrl, name: name, author: author),
    );
    return int.tryParse(row?.value ?? '') ?? 0;
  }

  Future<void> setBookScore({
    required String sourceUrl,
    required String name,
    required String author,
    required int score,
  }) async {
    final sanitizedScore = max(-1, min(1, score));
    final previousScore = await getBookScore(
      sourceUrl: sourceUrl,
      name: name,
      author: author,
    );
    final sourceScore = await getSourceScore(sourceUrl);
    final nextSourceScore = sourceScore + (sanitizedScore - previousScore);

    await _database.saveReaderPreference(
      key: _sourceScoreKey(sourceUrl),
      value: nextSourceScore.toString(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _database.saveReaderPreference(
      key: _bookScoreKey(sourceUrl: sourceUrl, name: name, author: author),
      value: sanitizedScore.toString(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> clearSourceScores(String sourceUrl) async {
    final escapedSource = sourceUrl
        .replaceAll(r'\\', r'\\\\')
        .replaceAll('%', r'\\%')
        .replaceAll('_', r'\\_');
    await _database.removeReaderPreference(_sourceScoreKey(sourceUrl));
    await _database.removeReaderPreferencesByPrefix(
      '$_bookPrefix$escapedSource\u0000',
    );
  }
}
