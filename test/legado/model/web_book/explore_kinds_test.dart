import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/legado/model/web_book/explore_kinds.dart';

void main() {
  group('LegadoExploreKindsAnalyzer', () {
    const analyzer = LegadoExploreKindsAnalyzer();

    test('支持 JSON 数组分类格式并解析 style', () {
      final kinds = analyzer.parse(
        rawExploreUrl: jsonEncode([
          {
            'title': '推荐',
            'url': 'mock://explore?page={{page}}',
            'style': {
              'layout_flexBasisPercent': 0.5,
              'layout_wrapBefore': true,
              'layout_alignSelf': 'center',
            },
          },
          {'title': '热门', 'url': 'mock://explore-hot?page={{page}}'},
        ]),
      );

      expect(kinds, hasLength(2));
      expect(kinds.first.title, '推荐');
      expect(kinds.first.url, 'mock://explore?page={{page}}');
      expect(kinds.first.style, isNotNull);
      expect(kinds.first.style!.layoutFlexBasisPercent, 0.5);
      expect(kinds.first.style!.layoutWrapBefore, isTrue);
      expect(kinds.first.style!.layoutAlignSelf, 'center');
      expect(kinds.last.title, '热门');
      expect(kinds.last.url, 'mock://explore-hot?page={{page}}');
    });

    test('支持 title::url + && + 换行格式', () {
      const raw =
          '推荐::mock://explore?page={{page}}&&热门::mock://explore-hot?page={{page}}\n完结::mock://explore-finish?page={{page}}';

      final kinds = analyzer.parse(rawExploreUrl: raw);

      expect(kinds, hasLength(3));
      expect(kinds[0].title, '推荐');
      expect(kinds[0].url, 'mock://explore?page={{page}}');
      expect(kinds[1].title, '热门');
      expect(kinds[1].url, 'mock://explore-hot?page={{page}}');
      expect(kinds[2].title, '完结');
      expect(kinds[2].url, 'mock://explore-finish?page={{page}}');
    });

    test('支持 exploreScreen 样式映射解析', () {
      final styles = analyzer.parseScreenStyles(
        rawExploreScreen: jsonEncode([
          {
            'title': '推荐',
            'style': {
              'layout_alignSelf': 'flex_end',
              'layout_flexBasisPercent': 0.8,
            },
          },
        ]),
      );

      expect(styles.keys, contains('推荐'));
      expect(styles['推荐']!.layoutAlignSelf, 'flex_end');
      expect(styles['推荐']!.layoutFlexBasisPercent, 0.8);
    });

    test('纯 URL 文本保持 legado 兼容行为', () {
      const raw = 'mock://explore?page={{page}}';
      final kinds = analyzer.parse(rawExploreUrl: raw);

      expect(kinds, hasLength(1));
      expect(kinds.first.title, raw);
      expect(kinds.first.url, isNull);
    });

    test('JS 分类规则暂不解析', () {
      final kinds = analyzer.parse(
        rawExploreUrl: '@js:return "推荐::https://a.com"',
      );

      expect(kinds, isEmpty);
    });
  });
}
