import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/legado/model/web_book/book_list.dart';

void main() {
  group('LegadoBookListAnalyzer', () {
    const analyzer = LegadoBookListAnalyzer();

    test('支持 JSON 规则解析并补全链接', () {
      const response = '''
      {
        "docs": [
          {
            "title": "三体",
            "author_name": ["刘慈欣"],
            "key": "/works/OL1W",
            "cover": "/covers/1.jpg",
            "first_sentence": "地球往事",
            "kind": ["科幻", "长篇"],
            "wordCount": "88万字"
          }
        ]
      }
      ''';

      final rules = analyzer.decodeRules(
        jsonEncode({
          'bookList': 'docs',
          'name': 'title',
          'author': 'author_name[0]',
          'bookUrl': 'key',
          'coverUrl': 'cover',
          'intro': 'first_sentence',
          'kind': 'kind',
          'wordCount': 'wordCount',
        }),
      );

      final books = analyzer.parse(
        responseBody: response,
        rules: rules,
        pageUrl: 'https://openlibrary.org/search?q=test',
      );

      expect(books, hasLength(1));
      expect(books.first.name, '三体');
      expect(books.first.author, '刘慈欣');
      expect(books.first.bookUrl, 'https://openlibrary.org/works/OL1W');
      expect(books.first.coverUrl, 'https://openlibrary.org/covers/1.jpg');
      expect(books.first.kind, '科幻,长篇');
      expect(books.first.wordCount, '88万字');
    });

    test('支持 HTML 规则解析并支持反转列表', () {
      const response = '''
      <html><body>
        <ul>
          <li class="book">
            <a class="name" href="/book/1">A书</a>
            <span class="author">作者A</span>
          </li>
          <li class="book">
            <a class="name" href="/book/2">B书</a>
            <span class="author">作者B</span>
          </li>
        </ul>
      </body></html>
      ''';

      final rules = analyzer.decodeRules(
        jsonEncode({
          'bookList': '-.book',
          'name': '.name',
          'author': '.author',
          'bookUrl': '.name@href',
        }),
      );

      final books = analyzer.parse(
        responseBody: response,
        rules: rules,
        pageUrl: 'https://example.com/search?key=abc',
      );

      expect(books, hasLength(2));
      expect(books.first.name, 'B书');
      expect(books.first.bookUrl, 'https://example.com/book/2');
      expect(books.last.name, 'A书');
    });
  });
}
