import 'package:material_ui/material_ui.dart';

/// Semantic colors for Home components that adapt to the active app theme.
class HomeTheme {
  HomeTheme._();

  static ColorScheme scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color surface(BuildContext context) => scheme(context).surface;

  static Color elevatedSurface(BuildContext context) =>
      scheme(context).surfaceContainer;

  static Color subtleSurface(BuildContext context) =>
      scheme(context).surfaceContainerHighest;

  static Color border(BuildContext context) => scheme(context).outlineVariant;

  static Color text(BuildContext context) => scheme(context).onSurface;

  static Color muted(BuildContext context) => scheme(context).onSurfaceVariant;

  static Color accent(BuildContext context) => scheme(context).primary;

  static Color accentSurface(BuildContext context) =>
      scheme(context).primaryContainer;

  static Color successSurface(BuildContext context) => isDark(context)
      ? const Color(0xFF17351F)
      : const Color(0xFFE9F5DA);
}
