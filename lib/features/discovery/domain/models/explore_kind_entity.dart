class ExploreKindStyleEntity {
  const ExploreKindStyleEntity({
    required this.layoutFlexGrow,
    required this.layoutFlexShrink,
    required this.layoutAlignSelf,
    required this.layoutFlexBasisPercent,
    required this.layoutWrapBefore,
  });

  final double layoutFlexGrow;
  final double layoutFlexShrink;
  final String layoutAlignSelf;
  final double layoutFlexBasisPercent;
  final bool layoutWrapBefore;
}

class ExploreKindEntity {
  const ExploreKindEntity({required this.title, this.exploreUrl, this.style});

  final String title;
  final String? exploreUrl;
  final ExploreKindStyleEntity? style;
}

class ExploreSourceKindsEntity {
  const ExploreSourceKindsEntity({
    required this.sourceUrl,
    required this.sourceName,
    required this.kinds,
  });

  final String sourceUrl;
  final String sourceName;
  final List<ExploreKindEntity> kinds;
}
