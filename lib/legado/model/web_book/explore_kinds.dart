import 'dart:convert';

class LegadoFlexChildStyle {
  const LegadoFlexChildStyle({
    this.layoutFlexGrow = 0,
    this.layoutFlexShrink = 1,
    this.layoutAlignSelf = 'auto',
    this.layoutFlexBasisPercent = -1,
    this.layoutWrapBefore = false,
  });

  final double layoutFlexGrow;
  final double layoutFlexShrink;
  final String layoutAlignSelf;
  final double layoutFlexBasisPercent;
  final bool layoutWrapBefore;

  static const defaultStyle = LegadoFlexChildStyle();

  static LegadoFlexChildStyle? parse(dynamic raw) {
    if (raw is! Map) {
      return null;
    }

    return LegadoFlexChildStyle(
      layoutFlexGrow: _asDouble(raw['layout_flexGrow'], fallback: 0),
      layoutFlexShrink: _asDouble(raw['layout_flexShrink'], fallback: 1),
      layoutAlignSelf: _asText(raw['layout_alignSelf']) ?? 'auto',
      layoutFlexBasisPercent: _asDouble(
        raw['layout_flexBasisPercent'],
        fallback: -1,
      ),
      layoutWrapBefore: _asBool(raw['layout_wrapBefore'], fallback: false),
    );
  }

  static double _asDouble(dynamic value, {required double fallback}) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    return fallback;
  }

  static String? _asText(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    return null;
  }
}

class LegadoExploreKind {
  const LegadoExploreKind({required this.title, this.url, this.style});

  final String title;
  final String? url;
  final LegadoFlexChildStyle? style;

  LegadoExploreKind copyWith({
    String? title,
    String? url,
    LegadoFlexChildStyle? style,
  }) {
    return LegadoExploreKind(
      title: title ?? this.title,
      url: url ?? this.url,
      style: style ?? this.style,
    );
  }
}

class LegadoExploreKindsAnalyzer {
  const LegadoExploreKindsAnalyzer();

  List<LegadoExploreKind> parse({required String rawExploreUrl}) {
    final raw = rawExploreUrl.trim();
    if (raw.isEmpty) {
      return const [];
    }

    if (_isJsRule(raw)) {
      return const [];
    }

    if (raw.startsWith('[') || raw.startsWith('{')) {
      final fromJson = _parseJson(raw);
      if (fromJson.isNotEmpty) {
        return fromJson;
      }
    }

    return _parseText(raw);
  }

  Map<String, LegadoFlexChildStyle> parseScreenStyles({
    required String? rawExploreScreen,
  }) {
    final raw = (rawExploreScreen ?? '').trim();
    if (raw.isEmpty || (!raw.startsWith('[') && !raw.startsWith('{'))) {
      return const {};
    }

    try {
      final decoded = jsonDecode(raw);
      final styles = <String, LegadoFlexChildStyle>{};

      if (decoded is List) {
        for (final item in decoded) {
          final itemStyle = _parseScreenItem(item);
          if (itemStyle != null) {
            styles[itemStyle.$1] = itemStyle.$2;
          }
        }
      } else if (decoded is Map) {
        decoded.forEach((key, value) {
          final style = LegadoFlexChildStyle.parse(value);
          final normalizedKey = '$key'.trim();
          if (style != null && normalizedKey.isNotEmpty) {
            styles[normalizedKey] = style;
            return;
          }

          final itemStyle = _parseScreenItem(value);
          if (itemStyle != null) {
            styles[itemStyle.$1] = itemStyle.$2;
          }
        });
      }

      return styles;
    } catch (_) {
      return const {};
    }
  }

  bool _isJsRule(String raw) {
    final lower = raw.toLowerCase();
    return lower.startsWith('<js>') || lower.startsWith('@js:');
  }

  List<LegadoExploreKind> _parseJson(String raw) {
    try {
      final decoded = jsonDecode(raw);

      if (decoded is List) {
        final kinds = <LegadoExploreKind>[];
        for (final item in decoded) {
          final kind = _parseJsonItem(item);
          if (kind != null) {
            kinds.add(kind);
          }
        }
        return kinds;
      }

      if (decoded is Map) {
        final kind = _parseJsonItem(decoded);
        if (kind != null) {
          return [kind];
        }
      }
    } catch (_) {
      return const [];
    }

    return const [];
  }

  LegadoExploreKind? _parseJsonItem(dynamic item) {
    if (item is String) {
      final title = item.trim();
      if (title.isEmpty) {
        return null;
      }
      return LegadoExploreKind(title: title);
    }

    if (item is! Map) {
      return null;
    }

    final title = _asText(item['title']) ?? _asText(item['name']) ?? '';
    final url = _asText(item['url']);
    if (title.isEmpty && (url == null || url.isEmpty)) {
      return null;
    }

    final style = LegadoFlexChildStyle.parse(item['style']);

    return LegadoExploreKind(
      title: title.isEmpty ? url! : title,
      url: url,
      style: style,
    );
  }

  List<LegadoExploreKind> _parseText(String raw) {
    final parts = raw
        .split(RegExp(r'(&&|\r?\n)+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);

    final kinds = <LegadoExploreKind>[];
    for (final part in parts) {
      final cfg = part.split('::');
      final title = cfg.first.trim();
      if (title.isEmpty) {
        continue;
      }

      final url = cfg.length > 1 ? cfg.sublist(1).join('::').trim() : null;
      kinds.add(
        LegadoExploreKind(
          title: title,
          url: (url == null || url.isEmpty) ? null : url,
        ),
      );
    }

    return kinds;
  }

  (String, LegadoFlexChildStyle)? _parseScreenItem(dynamic item) {
    if (item is! Map) {
      return null;
    }

    final title = _asText(item['title']) ?? _asText(item['name']) ?? '';
    final style = LegadoFlexChildStyle.parse(item['style']);
    if (title.isNotEmpty && style != null) {
      return (title, style);
    }

    if (item.length == 1) {
      final entry = item.entries.first;
      final nestedStyle = LegadoFlexChildStyle.parse(entry.value);
      final nestedTitle = _asText(entry.key);
      if (nestedTitle != null &&
          nestedTitle.isNotEmpty &&
          nestedStyle != null) {
        return (nestedTitle, nestedStyle);
      }
    }

    return null;
  }

  String? _asText(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    return null;
  }
}
