# Flutter + Shadcn 小说阅读器重构计划（参考 legado）

## 1. 项目目标

- 在当前目录从零重建一套 **Flutter 架构** 的小说阅读器。
- 以同级项目 `../legado` 的能力为功能基线，分阶段实现。
- UI 体系统一采用 `shadcn_ui`，宿主仅使用 `CupertinoApp`（不使用 Material）。
- 先实现 MVP（可用阅读链路），再补齐高级能力（规则引擎、订阅、Web API、同步等）。

---

## 2. 参考输入

### 2.1 legado 能力基线（已抽样）

从 `../legado` 目录结构和核心文件提炼：

- 领域对象（`data/entities`）：`Book`、`BookChapter`、`BookSource`、`Bookmark`、`ReadRecord`、`ReplaceRule`、`RssSource` 等。
- 数据层（`data/dao` + Room）：多实体本地持久化、迁移历史长、读写频繁。
- 规则链路（`model/webBook` + `help/source`）：书源搜索/详情/目录/正文解析。
- 阅读器（`ui/book/read`）：分页、样式、TTS、替换净化、配置面板。
- 首页体系（`ui/main/*`）：书架、发现、RSS、我的。
- 对外能力（`api/controller` + `web`）：本地 Web API / WebSocket / 内容导入导出。

### 2.2 shadcn_ui 文档要点（llms.txt）

来源：`https://mariuti.com/flutter-shadcn-ui/llms.txt`

- 安装：`flutter pub add shadcn_ui`
- 推荐集成：`ShadApp.custom` + `CupertinoApp`/`CupertinoApp.router` + `ShadAppBuilder`
- 国际化委托：补齐 `DefaultMaterialLocalizations`、`DefaultCupertinoLocalizations`、`DefaultWidgetsLocalizations`
- 主题策略：`ShadThemeData` + 亮/暗主题 + `ShadColorScheme`
- 组件覆盖：表单、弹层、导航、表格、Tabs、Toast、Sheet、Dialog、Select、Input、Slider 等，足以覆盖阅读器配置和书源管理场景。

---

## 3. 总体架构设计

## 3.1 架构原则

- **Feature First**：按业务域拆分模块，而非纯按技术层拆分。
- **Clean + Vertical Slice**：每个 feature 内含 `presentation/domain/data`，降低跨目录跳转成本。
- **可替换基础设施**：数据库、JS 引擎、网络层都通过抽象接口隔离。
- **兼容优先**：优先兼容 legado 书源 JSON 结构与核心规则字段。

### 3.2 建议目录（目标态）

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  bootstrap/
    bootstrap.dart
  core/
    constants/
    errors/
    utils/
    network/
    storage/
    parser/
    js_engine/
  shared/
    widgets/
    extensions/
  features/
    bookshelf/
      presentation/
      domain/
      data/
    source_management/
      presentation/
      domain/
      data/
    discovery_search/
      presentation/
      domain/
      data/
    reader/
      presentation/
      domain/
      data/
    rss/
    settings/
    import_export/
    sync_api/
```

### 3.3 技术选型（首选）

- UI：`shadcn_ui`（主）+ `Cupertino`（宿主）
- 状态管理：`riverpod`（建议 `flutter_riverpod` + `riverpod_generator`）
- 路由：`go_router`
- 网络：`dio`
- 本地数据库：`drift`（SQLite，支持迁移与复杂查询）
- JSON 序列化：`freezed` + `json_serializable`
- 本地缓存：`shared_preferences` / `hive`（轻量配置）
- 文本/规则解析：`html`、XPath/JsonPath 对应 Dart 库（需 PoC 验证）
- JS 执行：QuickJS/flutter_js 候选（需 PoC 验证与性能压测）

> 说明：规则引擎（XPath/JsonPath/JS）是技术风险最高模块，必须在 P1 阶段完成可行性验证再大规模推进。

---

## 4. legado 到 Flutter 的模块映射

| legado 模块 | Flutter 对应模块 | 说明 |
|---|---|---|
| `data/entities/*` | `features/*/domain/models` + `data/dtos` | 保持领域模型稳定，DTO 做兼容转换 |
| `data/dao/*` + Room | `features/*/data/local` + Drift | 按 feature 拆表与 DAO |
| `model/webBook/*` | `features/discovery_search/domain/services` | 搜索、书籍详情、目录、正文抓取 |
| `help/source/*` | `core/parser` + `core/js_engine` | 规则解析和执行内核 |
| `ui/main/bookshelf` | `features/bookshelf/presentation` | 书架、分组、排序、最近阅读 |
| `ui/book/read/*` | `features/reader/presentation` | 阅读页、翻页、样式、菜单、TTS |
| `ui/book/source` | `features/source_management/presentation` | 书源增删改查、分组、导入 |
| `api/controller/*` + `web/*` | `features/sync_api` | 本地 API / WebSocket（后置阶段） |

---

## 5. 分阶段实施计划（Plan Mode）

## P0：工程初始化（1-2 天）

目标：得到可运行的 Flutter 项目骨架 + Shadcn 主题基座

- 初始化工程、目录、环境配置（dev/prod）
- 接入 `shadcn_ui`，使用 `ShadApp.custom + CupertinoApp.router`
- 建立主题系统（亮/暗、字体、基础 token）
- 建立路由与壳层页面（书架/发现/阅读/设置空页面）

交付标准：

- `flutter run` 可启动
- 主题切换可用
- 路由跳转可用

## P1：基础能力层（3-5 天）

目标：构建长期可维护底座

- 网络层（Dio + 拦截器 + 错误模型）
- 本地存储（Drift 表结构 v1：Book、BookSource、BookChapter、ReadRecord、Bookmark）
- 配置中心（阅读设置、主题设置、实验开关）
- 规则引擎 PoC（HTML/XPath/JsonPath/JS 最小闭环）

交付标准：

- 能从本地样例规则解析出书名、目录、正文
- 表结构可迁移（至少 1 次 migration 演练）

## P2：书源与搜索（4-7 天）

目标：打通“找书”链路

- 书源管理：导入、启停、分组、编辑
- 搜索页：关键词搜索、来源筛选、结果聚合
- 书籍详情：简介、目录预览、加入书架
- 错误可观测：超时、规则异常、解析失败提示

交付标准：

- 至少 1-2 个真实书源可稳定搜索/拉取目录
- 加入书架后可离线保留元数据

## P3：阅读核心（5-8 天）

目标：打通“看书”链路

- 阅读页：章节加载、进度保存、上下章跳转
- 阅读配置：字体/行距/边距/主题/翻页模式
- 文本净化：替换规则启停、预览
- 书签与阅读历史

交付标准：

- 书架 -> 阅读 -> 退出 -> 恢复进度完整闭环
- 阅读配置实时生效

## P4：增强能力（并行/后续）

- 本地 TXT/EPUB 导入
- RSS 订阅与阅读
- TTS 朗读（平台能力 + 可扩展引擎）
- WebDAV/云同步
- 本地 Web API / WebSocket（兼容 legado 常用接口）

---

## 6. Shadcn 组件落位建议

- 书架：`ShadTabs` + `ShadCard` + `ShadContextMenu`
- 搜索：`ShadInput` + `ShadSelect` + `ShadButton` + `ShadTable`
- 阅读设置：`ShadSheet` + `ShadSlider` + `ShadSwitch` + `ShadRadioGroup`
- 弹窗交互：`ShadDialog` / `ShadPopover` / `ShadToast`
- 表单场景（书源编辑）：`ShadForm` + 校验规则

---

## 7. 风险与对策

- 规则引擎兼容风险高：先做最小规则子集（搜索/目录/正文），逐步扩展。
- Flutter 端 JS 性能与安全：限制脚本执行超时、内存、并发；加入熔断与降级。
- 多源聚合稳定性：请求并发上限、重试、断路器、源健康评分。
- 阅读体验细节复杂：先保核心（分页/进度/样式），高级动效后置。

---

## 8. 近期执行清单（下一步）

1. 初始化 Flutter 工程与目录骨架。
2. 接入 `shadcn_ui` 并完成 `ShadApp.custom + CupertinoApp.router` 主入口。
3. 建立 `go_router` 路由壳层（书架/发现/阅读/设置）。
4. 落地 Drift v1 表结构与仓储接口。
5. 完成规则引擎 PoC（以 1 个 legado 书源为样本）。

---

## 9. 验收基线（MVP）

- 可导入书源并搜索到书。
- 可加入书架并打开阅读。
- 可保存/恢复阅读进度。
- 可修改阅读主题和文本样式。
- 核心页面全部采用 shadcn 风格组件。
