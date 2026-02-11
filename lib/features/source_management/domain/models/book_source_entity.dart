class BookSourceEntity {
  const BookSourceEntity({
    required this.bookSourceUrl,
    required this.bookSourceName,
    this.bookSourceGroup,
    this.bookSourceType = 0,
    this.bookUrlPattern,
    this.customOrder = 0,
    this.enabled = true,
    this.enabledExplore = true,
    this.jsLib,
    this.enabledCookieJar = true,
    this.concurrentRate,
    this.header,
    this.loginUrl,
    this.loginUi,
    this.loginCheckJs,
    this.coverDecodeJs,
    this.bookSourceComment,
    this.variableComment,
    this.lastUpdateTime = 0,
    this.respondTime = 180000,
    this.weight = 0,
    this.exploreUrl,
    this.exploreScreen,
    this.ruleExplore,
    this.searchUrl,
    this.ruleSearch,
    this.ruleBookInfo,
    this.ruleToc,
    this.ruleContent,
    this.ruleReview,
  });

  final String bookSourceUrl;
  final String bookSourceName;
  final String? bookSourceGroup;
  final int bookSourceType;
  final String? bookUrlPattern;
  final int customOrder;
  final bool enabled;
  final bool enabledExplore;
  final String? jsLib;
  final bool enabledCookieJar;
  final String? concurrentRate;
  final String? header;
  final String? loginUrl;
  final String? loginUi;
  final String? loginCheckJs;
  final String? coverDecodeJs;
  final String? bookSourceComment;
  final String? variableComment;
  final int lastUpdateTime;
  final int respondTime;
  final int weight;
  final String? exploreUrl;
  final String? exploreScreen;
  final String? ruleExplore;
  final String? searchUrl;
  final String? ruleSearch;
  final String? ruleBookInfo;
  final String? ruleToc;
  final String? ruleContent;
  final String? ruleReview;
}
