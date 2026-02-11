import 'dart:convert';

class MockLegadoApi {
  const MockLegadoApi._();

  static String respond(Uri uri) {
    switch (uri.host) {
      case 'search':
        return _search(uri);
      case 'explore':
        return _explore(uri);
      case 'explore-hot':
        return _exploreHot(uri);
      case 'book-info':
        return _bookInfo(uri);
      case 'toc':
        return _toc(uri);
      case 'content':
        return _content(uri);
      default:
        return jsonEncode({'error': 'unknown mock endpoint'});
    }
  }

  static String _search(Uri uri) {
    final key = uri.queryParameters['key']?.trim();
    final keyword = key == null || key.isEmpty ? '示例' : key;

    final books = [
      {
        'name': '$keyword 的冒险',
        'author': 'Mock作者A',
        'bookUrl': 'mock-book-1',
        'coverUrl': 'https://placehold.co/240x320?text=Mock+A',
        'intro': '这是一本用于验证 legado 搜索规则的示例小说。',
      },
      {
        'name': '$keyword 纪元',
        'author': 'Mock作者B',
        'bookUrl': 'mock-book-2',
        'coverUrl': 'https://placehold.co/240x320?text=Mock+B',
        'intro': '用于验证目录与正文抓取链路。',
      },
    ];
    return jsonEncode({'books': books});
  }

  static String _explore(Uri uri) {
    final page = int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
    return jsonEncode({'books': _buildExploreBooks(page: page, tag: '推荐')});
  }

  static String _exploreHot(Uri uri) {
    final page = int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
    return jsonEncode({'books': _buildExploreBooks(page: page, tag: '热门')});
  }

  static List<Map<String, Object>> _buildExploreBooks({
    required int page,
    required String tag,
  }) {
    final tagKey = tag == '热门' ? 'hot' : 'recommend';

    return [
      {
        'name': '$tag 榜单 $page-A',
        'author': '$tag作者A',
        'bookUrl': 'mock-$tagKey-$page-1',
        'coverUrl': 'https://placehold.co/240x320?text=$tag+$page+A',
        'intro': '$tag 分类推荐书籍 A。',
        'kind': ['发现', tag],
      },
      {
        'name': '$tag 榜单 $page-B',
        'author': '$tag作者B',
        'bookUrl': 'mock-$tagKey-$page-2',
        'coverUrl': 'https://placehold.co/240x320?text=$tag+$page+B',
        'intro': '$tag 分类推荐书籍 B。',
        'kind': ['发现', tag],
      },
    ];
  }

  static String _bookInfo(Uri uri) {
    final book = uri.queryParameters['book'] ?? 'mock-book-1';
    final number = book.endsWith('2') ? 2 : 1;

    return jsonEncode({
      'name': number == 1 ? 'Mock 冒险（详情）' : 'Mock 纪元（详情）',
      'author': number == 1 ? 'Mock作者A' : 'Mock作者B',
      'intro': '这是 $book 的详情页简介，用于验证 ruleBookInfo 主流程。',
      'kind': ['轻小说', '冒险'],
      'wordCount': number == 1 ? '52万字' : '66万字',
      'lastChapter': number == 1 ? '第520章 归来' : '第661章 回声',
      'updateTime': '2026-02-11 14:00:00',
      'coverUrl': 'https://placehold.co/240x320?text=Mock+$number',
      'tocUrl': 'mock://toc?book=$book',
    });
  }

  static String _toc(Uri uri) {
    final book = uri.queryParameters['book'] ?? 'mock-book-1';

    final chapters = List.generate(12, (index) {
      final chapter = index + 1;
      return {
        'title': '第$chapter章',
        'url': 'mock://content?book=$book&chapter=$chapter',
      };
    });

    return jsonEncode({'chapters': chapters});
  }

  static String _content(Uri uri) {
    final book = uri.queryParameters['book'] ?? 'mock-book-1';
    final chapter = uri.queryParameters['chapter'] ?? '1';

    return jsonEncode({
      'content':
          '《$book》\n\n这是第 $chapter 章的正文示例。\n\n'
          '这段内容由 mock:// 接口返回，用于验证 legado 正文解析和阅读器展示流程。',
    });
  }
}
