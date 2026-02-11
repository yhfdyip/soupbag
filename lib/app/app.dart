import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:soupbag/app/router.dart';
import 'package:soupbag/app/theme/app_theme.dart';

class SoupbagApp extends StatelessWidget {
  const SoupbagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      appBuilder: (context) {
        return CupertinoApp.router(
          title: 'Soupbag',
          theme: CupertinoTheme.of(context),
          routerConfig: appRouter,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('zh', 'CN')],
          builder: (context, child) {
            return ShadAppBuilder(
              child: SafeArea(
                top: false,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
