import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  AppTheme._();

  static final ShadThemeData light = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadSlateColorScheme.light(),
  );

  static final ShadThemeData dark = ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadSlateColorScheme.dark(),
  );
}
