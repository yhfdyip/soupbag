part of 'router.dart';

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  int _currentIndex(String location) {
    if (location.startsWith('/discovery')) return 1;
    if (location.startsWith('/reader')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _currentIndex(location);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: child),
          CupertinoTabBar(
            currentIndex: index,
            onTap: (value) {
              switch (value) {
                case 0:
                  context.go('/bookshelf');
                  break;
                case 1:
                  context.go('/discovery');
                  break;
                case 2:
                  context.go('/reader');
                  break;
                case 3:
                  context.go('/settings');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book),
                label: '书架',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
                label: '发现',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book_circle),
                label: '阅读',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: '设置',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
