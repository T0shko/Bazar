import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Typography base
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final palette = _Palette(brightness);
    final colorScheme = palette.colorScheme;

    final baseTextColor = colorScheme.onBackground;
    final secondaryTextColor = colorScheme.onSurface.withValues(alpha: 0.72);
    final tertiaryTextColor = colorScheme.onSurface.withValues(alpha: 0.56);

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: baseTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: baseTextColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: baseTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: baseTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: baseTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: secondaryTextColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: baseTextColor,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: tertiaryTextColor,
        height: 1.4,
      ),
      labelLarge: button.copyWith(color: colorScheme.onPrimary),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: secondaryTextColor,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: tertiaryTextColor,
        letterSpacing: 0.4,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: palette.navBarColor,
        indicatorColor: palette.navIndicator,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium!.copyWith(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.65),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurface,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: palette.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: palette.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
        filled: true,
        fillColor: palette.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing20,
          vertical: spacing16,
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        prefixIconColor: colorScheme.onSurface.withValues(alpha: 0.55),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: palette.divider,
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(colorScheme.primary),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }

  static AppGradients gradients(BuildContext context) =>
      AppGradients(Theme.of(context).colorScheme, Theme.of(context).brightness);

  static GlassStyle glassStyle(BuildContext context) =>
      GlassStyle.fromTheme(Theme.of(context));

  static Color elevatedSurface(BuildContext context) {
    final palette = _Palette(Theme.of(context).brightness);
    return palette.surfaceElevated;
  }

  static Color successColor(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;
  static Color errorColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;
  static Color warningColor(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  static TextStyle heading1(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge!;

  static TextStyle heading2(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!;

  static TextStyle heading3(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!;

  static TextStyle bodyLarge(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!;

  static TextStyle bodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static TextStyle bodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!;

  // Static color properties for convenience (use light theme defaults)
  static const Color primaryColor = Color(0xFF5B5CEB);
  static const Color secondaryColor = Color(0xFF00B5D1);
  static const Color accentOrange = Color(0xFFFF6F3C);
  static const Color accentPink = Color(0xFFFF8FA2);
  static const Color backgroundLight = Color(0xFFF4F4FF);
  static const Color textPrimary = Color(0xFF121441);
  static const Color error = Color(0xFFEA3D4D);
  static const Color success = Color(0xFF00B5D1);
  static const Color info = Color(0xFF5B5CEB);
  static const Color secondaryLight = Color(0xFFD6F7FF);

  // Static gradient properties
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B5CEB), Color(0xFF4E8FDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00B5D1), Color(0xFF0095C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6F3C), Color(0xFFFF8FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Static shadow properties
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowColored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppGradients {
  final ColorScheme colorScheme;
  final Brightness brightness;

  AppGradients(this.colorScheme, this.brightness);

  LinearGradient get primary => LinearGradient(
        colors: [
          colorScheme.primary,
          Color.lerp(colorScheme.primary, colorScheme.secondary, 0.35)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get secondary => LinearGradient(
        colors: [
          colorScheme.secondary,
          Color.lerp(colorScheme.secondary, colorScheme.primary, 0.25)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get warm => LinearGradient(
        colors: [
          colorScheme.tertiary,
          Color.lerp(colorScheme.tertiary, colorScheme.primary, 0.4)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get success => LinearGradient(
        colors: [
          colorScheme.secondaryContainer,
          colorScheme.secondary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class GlassStyle {
  final Gradient gradient;
  final Color overlay;
  final BoxBorder border;
  final List<BoxShadow> shadows;

  const GlassStyle({
    required this.gradient,
    required this.overlay,
    required this.border,
    required this.shadows,
  });

  factory GlassStyle.fromTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final surfaceTint = theme.colorScheme.surfaceTint;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : theme.colorScheme.primary.withValues(alpha: 0.12);

    return GlassStyle(
      gradient: LinearGradient(
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.05),
              ]
            : [
                Colors.white.withValues(alpha: 0.85),
                Colors.white.withValues(alpha: 0.60),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      overlay: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.50),
      border: Border.all(
        color: borderColor,
        width: isDark ? 1.1 : 1.5,
      ),
      shadows: [
        BoxShadow(
          color: primary.withValues(alpha: isDark ? 0.08 : 0.10),
          blurRadius: isDark ? 24 : 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: surfaceTint.withValues(alpha: isDark ? 0.10 : 0.06),
          blurRadius: isDark ? 18 : 15,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _Palette {
  final Brightness brightness;
  late final Color background;
  late final Color surface;
  late final Color surfaceElevated;
  late final Color fieldFill;
  late final Color fieldBorder;
  late final Color navBarColor;
  late final Color navIndicator;
  late final Color divider;
  late final ColorScheme colorScheme;

  _Palette(this.brightness) {
    final isDark = brightness == Brightness.dark;

    if (isDark) {
      background = const Color(0xFF050512);
      surface = const Color(0xFF101125);
      surfaceElevated = const Color(0xFF181A31);
      fieldFill = const Color(0x1FFFFFFF);
      fieldBorder = const Color(0x40FFFFFF);
      navBarColor = const Color(0xCC080811);
      navIndicator = const Color(0x332E37FF);
      divider = const Color(0x1AFFFFFF);

      colorScheme = ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF8B8CFF),
        onPrimary: Colors.black,
        primaryContainer: const Color(0xFF3436A8),
        onPrimaryContainer: const Color(0xFFE1E2FF),
        secondary: const Color(0xFF38E5D0),
        onSecondary: Colors.black,
        secondaryContainer: const Color(0xFF245A63),
        onSecondaryContainer: const Color(0xFFBEFFF3),
        tertiary: const Color(0xFFFF8FA2),
        onTertiary: Colors.black,
        tertiaryContainer: const Color(0xFF5A1C2B),
        onTertiaryContainer: const Color(0xFFFFD9E0),
        error: const Color(0xFFFF6B6B),
        onError: Colors.black,
        errorContainer: const Color(0xFF8C1D1D),
        onErrorContainer: const Color(0xFFFFDAD6),
        background: background,
        onBackground: const Color(0xFFE9EBFF),
        surface: surface,
        onSurface: const Color(0xFFC7CCFF),
        surfaceVariant: const Color(0xFF1F223D),
        onSurfaceVariant: const Color(0xFF9AA0CA),
        outline: const Color(0xFF3A3F6A),
        outlineVariant: const Color(0x332E37FF),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: const Color(0xFFE9EBFF),
        onInverseSurface: const Color(0xFF111427),
        inversePrimary: const Color(0xFF3A3DA5),
        surfaceTint: const Color(0xFF7F82FF),
      );
    } else {
      // Modern Light Mode with vibrant colors
      background = const Color(0xFFFAFAFF);
      surface = const Color(0xFFFFFFFF);
      surfaceElevated = const Color(0xFFF5F6FF);
      fieldFill = const Color(0xFFF8F9FF);
      fieldBorder = const Color(0xFFDFE1F5);
      navBarColor = const Color(0xFFFFFFFF);
      navIndicator = const Color(0x1A5B5CEB);
      divider = const Color(0xFFE8E9F6);

      colorScheme = ColorScheme(
        brightness: Brightness.light,
        primary: const Color(0xFF5B5CEB),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE8E9FF),
        onPrimaryContainer: const Color(0xFF0D0E29),
        secondary: const Color(0xFF00C9E0),
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFCCF8FF),
        onSecondaryContainer: const Color(0xFF002733),
        tertiary: const Color(0xFFFF7043),
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFFFE5DE),
        onTertiaryContainer: const Color(0xFF2C0800),
        error: const Color(0xFFE63946),
        onError: Colors.white,
        errorContainer: const Color(0xFFFFE6E8),
        onErrorContainer: const Color(0xFF3B0003),
        background: background,
        onBackground: const Color(0xFF0F1035),
        surface: surface,
        onSurface: const Color(0xFF1A1B3A),
        surfaceVariant: const Color(0xFFE3E5FA),
        onSurfaceVariant: const Color(0xFF464866),
        outline: const Color(0xFFBABDD6),
        outlineVariant: const Color(0xFFDDE0F5),
        shadow: const Color(0x14000000),
        scrim: const Color(0x66000000),
        inverseSurface: const Color(0xFF2E2F4F),
        onInverseSurface: const Color(0xFFF1F2FF),
        inversePrimary: const Color(0xFFB6B8FF),
        surfaceTint: const Color(0xFF5B5CEB),
      );
    }
  }
}

