import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/core/parser/legado_search_rule_parser.dart';

void main() {
  group('LegadoSearchRuleParser', () {
    final parser = LegadoSearchRuleParser();

    test('支持 JSON 规则解析', () {
      const response = '''
      {
        "docs": [
          {
            "title": "三体",
            "author_name": ["刘慈欣"],
            "key": "/works/OL1W",
            "first_sentence": "地球往事"
          }
        ]
      }
      ''';

      final ruleSearch = jsonEncode({
        'bookList': 'docs',
        'name': 'title',
        'author': 'author_name[0]',
        'bookUrl': 'key',
        'intro': 'first_sentence',
      });

      final books = parser.parse(
        responseBody: response,
        ruleSearchJson: ruleSearch,
      );

      expect(books, hasLength(1));
      expect(books.first.name, '三体');
      expect(books.first.author, '刘慈欣');
      expect(books.first.bookUrl, '/works/OL1W');
      expect(books.first.intro, '地球往事');
    });

    test('支持 HTML 规则解析', () {
      const response = '''
      <html><body>
        <ul>
          <li class="book">
            <a class="name" href="/book/1">诡秘之主</a>
            <span class="author">爱潜水的乌贼</span>
          </li>
        </ul>
      </body></html>
      ''';

      final ruleSearch = jsonEncode({
        'bookList': '.book',
        'name': '.name',
        'author': '.author',
        'bookUrl': '.name@href',
      });

      final books = parser.parse(
        responseBody: response,
        ruleSearchJson: ruleSearch,
      );

      expect(books, hasLength(1));
      expect(books.first.name, '诡秘之主');
      expect(books.first.author, '爱潜水的乌贼');
      expect(books.first.bookUrl, '/book/1');
    });
  });
}
