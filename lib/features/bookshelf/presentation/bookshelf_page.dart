import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BookshelfPage extends StatelessWidget {
  const BookshelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          largeTitle: Text('书架'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ShadCard(
              title: Text('欢迎', style: theme.textTheme.h4),
              description: const Text('这里将展示你的书籍与阅读进度。'),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('P0 壳页面已就绪，下一步实现书架数据。'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
