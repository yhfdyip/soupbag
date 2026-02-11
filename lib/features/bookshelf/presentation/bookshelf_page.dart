import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/core/bootstrap/app_services.dart';
import 'package:soupbag/features/bookshelf/data/local/bookshelf_local_repository.dart';
import 'package:soupbag/features/bookshelf/domain/models/book_entity.dart';
import 'package:soupbag/features/bookshelf/domain/repositories/bookshelf_repository.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  late final BookshelfRepository _bookshelfRepository;

  String? _statusMessage;
  String? _removingBookUrl;

  @override
  void initState() {
    super.initState();
    _bookshelfRepository = BookshelfLocalRepository(
      AppServices.instance.database,
    );
  }

  Future<void> _openReader(BookEntity book) async {
    context.go(
      '/reader',
      extra: {
        'sourceUrl': book.origin,
        'bookUrl': book.bookUrl,
        'bookName': book.name,
      },
    );
  }

  Future<void> _confirmRemove(BookEntity book) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        return CupertinoActionSheet(
          title: const Text('移除书籍'),
          message: Text('确认从书架移除《${book.name}》？'),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(popupContext).pop();
                setState(() {
                  _removingBookUrl = book.bookUrl;
                });

                await _bookshelfRepository.removeBook(book.bookUrl);
                if (!mounted) {
                  return;
                }

                setState(() {
                  _removingBookUrl = null;
                  _statusMessage = '已移除《${book.name}》';
                });
              },
              child: const Text('确认移除'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(popupContext).pop(),
            child: const Text('取消'),
          ),
        );
      },
    );
  }

  String _progressText(BookEntity book) {
    final currentChapter = book.durChapterIndex + 1;
    if (book.totalChapterNum > 0) {
      return '阅读进度：第 $currentChapter / ${book.totalChapterNum} 章';
    }
    return '阅读进度：第 $currentChapter 章';
  }

  String _subtitle(BookEntity book) {
    final author = book.author.isEmpty ? '未知作者' : book.author;
    final source = book.originName.isEmpty ? book.origin : book.originName;
    return '$author · $source';
  }

  String _formatLastRead(int timestamp) {
    if (timestamp <= 0) {
      return '最近阅读：暂无';
    }
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '最近阅读：${dateTime.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return StreamBuilder<List<BookEntity>>(
      stream: _bookshelfRepository.watchBookshelf(),
      builder: (context, snapshot) {
        final books = snapshot.data ?? const <BookEntity>[];

        return CustomScrollView(
          slivers: [
            const CupertinoSliverNavigationBar(largeTitle: Text('书架')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ShadCard(
                  title: Text('我的书架', style: theme.textTheme.h4),
                  description: Text('共 ${books.length} 本，按最近阅读排序'),
                  child: _statusMessage == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_statusMessage!),
                        ),
                ),
              ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: ShadCard(
                    title: Text('正在加载'),
                    description: Text('读取本地书架数据中...'),
                    child: SizedBox.shrink(),
                  ),
                ),
              ),
            if (!snapshot.hasData || books.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ShadCard(
                    title: const Text('暂无书籍'),
                    description: const Text('先去发现页搜索并“加入书架并阅读”'),
                    footer: ShadButton(
                      onPressed: () => context.go('/discovery'),
                      child: const Text('去发现页'),
                    ),
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
            SliverList.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                final removing = _removingBookUrl == book.bookUrl;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: ShadCard(
                    title: Text(book.name),
                    description: Text(_subtitle(book)),
                    footer: Row(
                      children: [
                        Expanded(
                          child: ShadButton(
                            onPressed: removing
                                ? null
                                : () => _openReader(book),
                            child: const Text('继续阅读'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ShadButton.outline(
                            onPressed: removing
                                ? null
                                : () => _confirmRemove(book),
                            child: Text(removing ? '移除中...' : '移除'),
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_progressText(book)),
                        const SizedBox(height: 4),
                        Text(_formatLastRead(book.durChapterTime)),
                        if (book.intro != null &&
                            book.intro!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            book.intro!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }
}
